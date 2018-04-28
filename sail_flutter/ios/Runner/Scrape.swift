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
    var tableContents : (([Element]) -> Void)?
    var decodeURL : (([Element]) -> ([Element]))?
    var pageHTML : ((DataResponse<String>) -> Void)?
    
    var doc : Document!
    let myGroup = DispatchGroup()
    //    MARK: URLs to parse
    fileprivate var originURL = "https://www.csusb.edu/sail"
    fileprivate var baseURL = "https://www.csusb.edu/sail" {
        didSet{
            print(baseURL)
        }
    }
    var mainURLs: (([Element]) -> Void)?
    var actionURLs: (([Element]) -> [Element])?
    
    func addMore(concat: String) {
        let newconcat = concat.replacingOccurrences(of: "/sail/", with: "/")
        baseURL = originURL + newconcat
    }
    
    func qaCheck() throws {
        var handle: Bool = false
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
            }        }
        
        if handle {
            throw HandlerError.noConnection
        }
    }
    
    func parseHTML(select: String, flaggedClass: String, classifier: String) throws{
     
        var handle: Bool = false
        myGroup.enter()
        Alamofire.request(baseURL).responseString {
            response in print("\(response.result.isSuccess)")
            if let result = response.result.value{
                self.parsePage(select: select, html: result, class: flaggedClass, classifier: classifier)
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
            if let _ = response.result.value{
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
    
    private var output: [Element] = []{
        didSet{
            print(output)
        }
    }
    
    func parsePage(select: String, html: String, class: String, classifier: String) -> Void {
        do {
            
            myGroup.enter()
            doc = try SwiftSoup.parse(html)
            let string = try doc.select(select).array()
            output = string
            print("\n\(output)\n")
            
            switch classifier {
                
            case "Head":
                parseHead()
            case "Body":
                parseBody()
            case "Table":
                parseTable()
            default:
                parseHead()
            }
            
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
    
    func parseTable() {
        tableContents!(output)
    }
    
    func parseHead() {
        headingTitle!(output)
    }
    
    func parseBody() {
        bodyInformation!(output)
    }
    
    func priMenu (response: String) throws {
        myGroup.enter()
        do {
            let doc : Document = try SwiftSoup.parse(response)
            let div = try doc.select("ul").array()
            for subDiv in div {
                for divSec in try! subDiv.getElementsByClass("menu nav").array() {
                    let htmlLine = try! divSec.select("a").array()
                    //                    debug test
                    if try! htmlLine[0].text() == "Home" {
                        getData(of: htmlLine, completion: { x in self.mainURLs?(x as! [Element])})
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
        myGroup.notify(queue: .main, execute: {print("left menu primer")
            self.mainURLs = { x in print(x)}
        })
    }
    
    func getData(of array: Array<Any>,completion: @escaping (Array<Any>) -> Void){
        DispatchQueue.global(qos: .background).async {
            let loader = array
            DispatchQueue.main.async {
                completion(loader)
            }
        }
    }
    
    func subMenu(response: String) throws {
        myGroup.enter()
        do {
            let doc: Document = try SwiftSoup.parse(response)
            let div = try doc.select("ul").array()
            for subDiv in div {
                for divSec in try! subDiv.getElementsByClass("menu nav").array() {
                    let htmlLine = try! divSec.select("li").array()
                    //                    debug test
                    if try! htmlLine[0].attr("class") == "first leaf menu-mlid-8831"{
                        print("\nhit from subMenu\(htmlLine)\n")
                    }
                }
            }

        } catch {
            print("No subMenu")
        }
        myGroup.notify(queue: .main, execute: {print("left menu primer")
            self.mainURLs = { x in print(x)}
        })
    }
}

    //    TODO: Add delimeter for "col-md-9 center-container", "region region-sidebar-first"

