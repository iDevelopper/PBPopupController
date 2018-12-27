//
//  DemoViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 14/11/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let firstVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstTableViewController") as? FirstTableViewController {
            addChild(firstVC)
            let tableView = firstVC.view as! UITableView
            tableView.dataSource = firstVC
            tableView.delegate = firstVC
            self.view.addSubview(firstVC.view)
            firstVC.didMove(toParent: self)
        }
    }
}
