//
//  MainTableViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 20/06/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    let items = ["TabBar + Navigation Controllers", "Tab Bar Controller", "Navigation Controller", "Navigation Controller + Toolbar", "View Controller", "Split View Controller (Master)", "Split View Controller (Detail)", "Split View Controller (Global)", "Custom Container"]
    let identifiers = ["TabBarNavController", "TabBarController", "NavController", "NavController", "ViewController", "SplitViewController", "SplitViewController", "SplitViewController", "ContainerController"]

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Navigation
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = items[indexPath.row]

        return cell
    }
    

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 8 {
            let vc = UIStoryboard(name: "Custom", bundle: nil).instantiateViewController(withIdentifier: self.identifiers[indexPath.row])
            vc.title = items[indexPath.row]
            self.present(vc, animated: true) {
                //
                
            }
        }
        
        else if let vc = self.storyboard?.instantiateViewController(withIdentifier: self.identifiers[indexPath.row]) {
            if vc is UISplitViewController {
                let svc = vc as! SplitViewController
                if indexPath.row == 5 { // master
                    svc.masterIsContainer = true
                }
                if indexPath.row == 6 { // detail
                    svc.masterIsContainer = false
                }
                if indexPath.row == 7 { // global
                    svc.globalIsContainer = true
                }
            }
            if vc is UINavigationController {
                let nc = vc as! NavigationController
                nc.toolbarIsShown = false
                if indexPath.row == 3 {
                    nc.toolbarIsShown = true
                }
            }
            vc.title = items[indexPath.row]
            self.present(vc, animated: true) {
                //
                
            }
        }
    }
}
