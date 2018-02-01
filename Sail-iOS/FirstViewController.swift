//
//  FirstViewController.swift
//  Sail-iOS
//
//  Created by Ryan Paglinawan on 11/7/17.
//  Copyright © 2017 Ryan Paglinawan. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    let scrollView = UIScrollView()
    var refresher: UIRefreshControl!
    @IBOutlet weak var output: UILabel!
    
    var test = Scrape()
    
    func reloadData() {
        do {
            try test.parseHTML(select: "h2")
            test.headingTitle = { x in self.output.text = try! x[0].text() }
        } catch HandlerError.nullPointer {
            //            TODO: UIALERT
            let alert = UIAlertController(title: "🚨 ERROR 🚨", message: "You might be trying to access something that doesn't exist in FirstView", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } catch HandlerError.noConnection {
            //            TODO: UIALERT
            let alert = UIAlertController(title: "🚨 ERROR 🚨", message: "You might not have a connection. You should check your Wi-Fi settings.in firstview", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } catch {
            print("something else happened")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("First View will appear\n")
        output.adjustsFontSizeToFitWidth = true
        output.numberOfLines = 5
        reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.isScrollEnabled = true
        view.addSubview(scrollView)
        
//        refresher.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func refresh(_ refreshControl: UIRefreshControl) {
        reloadData()
        refreshControl.endRefreshing()
    }
}

