//
//  HarborViewController.swift
//  Sail-iOS
//
//  Created by Ryan Paglinawan on 12/9/17.
//  Copyright © 2017 Ryan Paglinawan. All rights reserved.
//

import UIKit
import SwiftSoup
import Alamofire

struct CusButtLayout {
    var name: String!
    var reqURL: String!
    var target: Any?
}

var buttData: [CusButtLayout]!

class HarborViewController: UIViewController {
    
    let scrapeSite = Scrape()
    var mainURL: [String]!
    fileprivate var dataSource: [Data] = [Data]()
    let currView = UIView()
    let containedView = CustomTableController()
    let customButton = CustomButton()

    @IBAction func OpenSideMenu(_ sender: Any) {
        
//        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        if let window = UIApplication.shared.keyWindow{
            currView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(currView)
            currView.frame = view.frame
            currView.alpha = 0
            
            currView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dissmissHandler)))
//            let orinPoint: CGPoint = self.view.frame.origin
            let displayWidth: CGFloat = (self.view.frame.width)
            let displayHeight: CGFloat = self.view.frame.height
            
            containedView.view.frame = CGRect(x: 0, y: 0, width: displayHeight, height: displayWidth)
            currView.addSubview(containedView.tableViewer)
            
            let width: CGFloat = 200
            let x = window.frame.width - width
            
            containedView.tableViewer.frame = CGRect(x: x, y: 0, width: displayWidth, height: displayHeight)
            containedView.didMove(toParentViewController: self)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.currView.alpha = 1
                self.containedView.tableViewer.frame = CGRect(x: x, y: 0, width: self.containedView.tableViewer.frame.width, height: self.containedView.tableViewer.frame.height)
            })
        }
        
    }
    
    @objc func dissmissHandler() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            if let window = UIApplication.shared.keyWindow {
                self.currView.alpha = 0
                self.containedView.tableViewer.frame = CGRect(x: window.frame.width, y: 0, width: self.containedView.tableViewer.frame.width, height: self.containedView.tableViewer.frame.height)
            }
        })
    }
    var screenView: FirstViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: TableView Controller
class CustomTableController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let scrapeSite = Scrape()
    var menuArray: [CusButtLayout] = []
    
    var tableViewer : UITableView! = UITableView()
    
    let group = DispatchGroup()
    var tableCell : CustomButton!
    
    func loadArray(response: String) -> [CusButtLayout] {
        var temp: [CusButtLayout] = []
        var eleTemp: [Element] = []
        
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
                if response != " " {
                    try! self.scrapeSite.priMenu(response: response)
                    self.scrapeSite.mainURLs = {
                        x in eleTemp = x
                        print(eleTemp)
                    }
                    self.group.leave()
                }
                    /*
                     self.scrapeSite.mainURLs = {
                     x in eleTemp = x
                     print("\n\(eleTemp)\n")
                     var iter = eleTemp.startIndex
                     let cap = eleTemp.capacity
                     print("\(iter)\n")
                     print("\(eleTemp[iter])\n")
                     print("\(eleTemp)\n")
                     let filler = CusButtLayout(name: " ", reqURL: " ", target: AnyClass.self)
                     temp.resize(cap, fillWith: filler)
                     if iter < (eleTemp.endIndex - 1) {
                     temp.append(CusButtLayout(name: try! eleTemp[iter].text(), reqURL: try! eleTemp[iter].attr("href"), target: AnyClass.self))
                     iter = iter.advanced(by: 1)
                     }
                     */
//            self.group.leave()
        }
        
        group.wait()
        group.notify(queue: .main){
            print("Finish loading.\n")
        }
        print("temp ele:\(temp)\n")
        return temp
    }
    
    @objc private func pressRowFunc( _ sender: UIButton){
        print("pressed a button")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Menu"
        do {
            try scrapeSite.qaCheck()
            var response : String = " "
            
            do{
                self.scrapeSite.pageHTML = {
                    HTMLresponse in response = HTMLresponse.result.value!
                    //                    print("\nresponse: \(response)\n")
                    
                    self.menuArray = self.loadArray(response: response)
                    
                    print("menu array:\(self.menuArray)")
                }
            }
            
        }  catch HandlerError.nullPointer {
            print("\nnothing here\n")
        } catch HandlerError.noConnection {
            print("\nno connection to server\n")
        } catch {
            print("\nsomething else is wrong\n")
        }
        
//        lockData(data: menuArray)
        self.tableViewer.register(CustomButton.self, forCellReuseIdentifier: "myCellIdentifier")
        self.tableViewer.reloadData()
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CustomTableController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCellIdentifier", for: indexPath) as! CustomButton
        
        return cell
    }
}

class CustomButton: UITableViewCell {
    
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
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        
        
    }
}

// Mark: resize the array if needed
extension RangeReplaceableCollection{
    public mutating func resize(_ size: IndexDistance, fillWith value: Iterator.Element){
        let c = size
        if c < size {
            append(contentsOf: repeatElement(value, count: c.distance(to: size)))
        } else if c > size{
            let newEnd = index(startIndex, offsetBy: size)
            removeSubrange(newEnd ..< endIndex)
        }
    }
}


