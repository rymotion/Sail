//
//  CustomTableViewController.swift
//  Sail-iOS
//
//  Created by Ryan Paglinawan on 2/26/18.
//  Copyright © 2018 Ryan Paglinawan. All rights reserved.
//

import UIKit
import SwiftSoup
import Alamofire
import WebKit

//MARK: TableView Controller
class CustomTableController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var homeController: HarborViewController?
    
    let scrapeSite = Scrape()
    var menuArray: [CusButtLayout] = []{
        didSet{
            if check {
                self.tableViewer.reloadData()
            } else {
                print("init")
                check = true
            }
        }
    }
    
    var check = false
    
    var currView: String = " "
    
    let identifier: String = "myCellIdentifier"
    
    let tableViewer : UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        return tv
    }()
    //    http://csusb.mywconline.net/
    //    var loginHTML = "<b>First Visit?<a href=\"http://csusb.mywconline.net/register.php\">Click here</a></b>to register.<b>Returning?</b>Log in below<form name =\"loginform\" method=\"post\" action=“https://csusb.mywonline.net/index.php”><p>Email Address:<br><input type=“text” name=“email” size=“30”><br><br>Password:<br><input type=“password” name=“password” size=“30” /> <br> <br> <input type=“submit” name=“login” value=“Log In”><input type=“hidden” name=“resume” value=“” /> </p></form>"
    
    let group = DispatchGroup()
    var tableCell : CustomButton!
    
    
    func loadArray(response: String) {
        var temp: [CusButtLayout] = [] {
            didSet{
                self.menuArray = temp
            }
        }
        var eleTemp: [Element] = []
        
        group.enter()
        DispatchQueue.global(qos: .background).async {
            if response != " " {
                do {
                    try! self.scrapeSite.priMenu(response: response)
                    self.scrapeSite.mainURLs = {
                        x in eleTemp.append(contentsOf: x)
                        
                        print("in eleTemp:\(eleTemp)\narray count:\(eleTemp.count)\n")
                        
                        temp.resize(eleTemp.count, fillWith: CusButtLayout(name: " ", reqURL: " ", target: AnyClass.self))
                        print("delay: \(temp), \(temp.count), \(temp.capacity)", separator: "\n")
                        for var z in temp {
                            var i = 0
                            for y in eleTemp{
                                z.name = try! y.text()
                                z.reqURL = try! y.attr("href")
                                z.target = AnyClass.self
                                print("\(z)\n")
                                temp[i] = z
                                i = i + 1
                            }
                        }
                        temp.append(CusButtLayout(name: "Login", reqURL: "http://csusb.mywconline.net/", target: AnyClass.self))
                        print("delay: \(temp), \(temp.count), \(temp.capacity)", separator: "\n")
                    }
                    try! self.scrapeSite.parseHTML(select:"", flaggedClass: "", classifier: "")
                }
                self.group.leave()
            }
        }
        
        group.wait()
        group.notify(queue: .main){
            print("Finish loading.\n")
        }
        print("\n\(temp)\n")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuArray.append(CusButtLayout(name: "Home", reqURL: "/home", target: AnyClass?.self))
        do {
            try scrapeSite.qaCheck()
            var response : String = " "
            
            do {
                self.scrapeSite.pageHTML = {
                    HTMLresponse in response = HTMLresponse.result.value!
                    
                    self.loadArray(response: response)
                    try! self.scrapeSite.subMenu(response: response)
                }
            }
            
        }  catch HandlerError.nullPointer {
            print("\nnothing here\n")
        } catch HandlerError.noConnection {
            print("\nno connection to server\n")
        } catch {
            print("\nsomething else is wrong\n")
        }
        
        tableViewer.register(CustomButton.self, forCellReuseIdentifier: identifier)
        
        tableViewer.delegate = self
        tableViewer.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CustomTableController {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selection = menuArray[indexPath.row]
        let cell = tableViewer.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CustomButton
        cell.nameLabel.text = selection.name
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
        }, completion: {(completed: Bool) in
            let selection = self.menuArray[indexPath.row]
            self.homeController?.openSelection(selection: selection)
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
        }, completion: {(completed: Bool) in
            let selection = self.menuArray[indexPath.row]
            self.homeController?.openSelection(selection: selection)
        })
    }
}

extension CustomTableController: CustomButtonDelegate {
    @objc func didTapAction(url: String) {
        print(url)
    }
}

protocol CustomButtonDelegate {
    func didTapAction(url: String)
}

class CustomButton: UITableViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.darkGray : UIColor.white
        }
    }
    
    var delegate: CustomButtonDelegate?
    var cusArray: [CusButtLayout] = []
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    let nameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "Sample Item"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    func setupViews() {
        self.contentView.addSubview(nameLabel)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
}
