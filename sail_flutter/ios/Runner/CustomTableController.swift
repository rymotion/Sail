//
//  CustomTableController.swift
//  Sail-iOS
//
//  Created by Ryan Paglinawan on 1/20/18.
//  Copyright © 2018 Ryan Paglinawan. All rights reserved.
//

import UIKit

class CustomTableController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @objc private func pressRowFunc(){}
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CustomTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        <#code#>
    }
}
