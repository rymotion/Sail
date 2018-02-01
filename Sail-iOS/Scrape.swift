    //
//  Scrape.swift
//  Sail-iOS
//
//  Created by Ryan Paglinawan on 12/6/17.
//  Copyright © 2017 Ryan Paglinawan. All rights reserved.
//

import UIKit
import Foundation
import JavaScriptCore
import SwiftSoup
import Alamofire

enum HandlerError: Error {
    case nullPointer
    case noConnection
}

class Scrape: NSObject {
    
    var headingTitle : (([Element]) -> Void)?
    var bodyInformation : (([Element]) -> Void)?
    var decodeURL : (([Element]) -> ([Element]))?
    var pageHTML : ((DataResponse<String>) -> Void)?
    var doc : Document!
    let myGroup = DispatchGroup()
    //    MARK: URLs to parse
    fileprivate var baseURL = "https://www.csusb.edu/sail"
    var mainURLs: (([Element]) -> Void)?
    var actionURLs: (([Element]) -> [Element])?
    
    func addMore(concat: String) {
        baseURL += concat
    }
    
    func qaCheck() throws {
        var handle: Bool = false
        myGroup.enter()
        Alamofire.request(baseURL).responseString {
            response in print("\(response.result.isSuccess)")
            switch response.result.value{
            case nil:
                handle = true
                break
            default:
                self.pageHTML!(response)
                handle = false
                break
            }
            self.myGroup.leave()
        }
        
        if handle {
            throw HandlerError.noConnection
        }
        
        myGroup.notify(queue: .main) {
            print("Finished all requests in qaCheck.")
        }
    }
    
    func parseHTML(select: String) throws {
        
        var handle: Bool = false
        myGroup.enter()
        Alamofire.request(baseURL).responseString {
            response in print("\(response.result.isSuccess)")
            if let result = response.result.value{
                self.parsePage(select: select, html: result)
                handle = false
            } else {
                handle = true
            }
            self.myGroup.leave()
        }
        
        if handle {
            throw HandlerError.noConnection
        }
        
        myGroup.notify(queue: .main) {
            print("Finished all requests in parse.")
        }
        
    }
    
    func setAction() throws {
        var handle: Bool = true
        myGroup.enter()
        Alamofire.request(baseURL).responseString{
            response in print("\(response.result.isSuccess)")
            if let result = response.result.value{
                self.actionParse(html: result)
                handle = false
            } else {
                handle = true
            }
            self.myGroup.leave()
        }
        
        if handle {
            throw HandlerError.nullPointer
        }
        
        myGroup.notify(queue: .main) {
            print("Finished all requests in set.")
        }
    }
    
    func parsePage(select: String, html: String) -> Void {
        do {
            myGroup.enter()
            doc = try SwiftSoup.parse(html)
            let string = try doc.select(select).array()
            let ouput = string
            print("\n\(ouput)\n")
            headingTitle!(ouput)
//            print("End page.\n")
//            print(try doc.text())
            myGroup.leave()
        } catch Exception.Error(type: _ , Message: let message){
            print(message)
        } catch {
            print("Error in page parse")
        }
        
        myGroup.notify(queue: .main) {
            print("Finished all requests in page.")
        }
    }
    
    func priMenu (response: String) throws {
//        var some: [Element]?
        
        do {
            let doc : Document = try SwiftSoup.parse(response)
            let div = try doc.select("ul").array()
            for subDiv in div {
//                subDiv = try doc.getElementsByClass("menu nav").array()
                for divSec in try! subDiv.getElementsByClass("menu nav").array() {
//                    print("\ndivSec:\(divSec)\n")
                    let htmlLine = try! divSec.select("a").array()
                    //                    debug test
                    if try! htmlLine[0].text() == "Home" {
//                        print("\ndivSec:\(divSec)\n")
                        self.mainURLs?(htmlLine)
                        myGroup.leave()
                    }
                }
            }
        } catch Exception.Error(type: _ , Message: let message){
            print(message)
            throw HandlerError.nullPointer
        } catch {
            print("Error in page parse")
            throw HandlerError.noConnection
        }
        myGroup.notify(queue: .main, execute: {print("left menu primer")})
    }
    
    func actionParse(html: String) -> Void {
        
            do {
                let doc : Document = try SwiftSoup.parse(html)
                let link = try! doc.select("a").array()
                
                //            MARK: Reads out elements in HTML parse
                for x in link {
    //                print("\n\(x)\n")
    //                print("\n\(try! x.attr("href"))\n")
    //                print("\n\(try! x.text())\n")
                }
        } catch Exception.Error(type: _ , Message: let message) {
            print("\n\(message)\n")
        } catch {
            print("Error in action parse")
        }
    }
}
