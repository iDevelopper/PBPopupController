//
//  MainTableViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 20/06/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import SwiftUI

class MainTableViewController: UITableViewController {
    
    let items = ["TabBar + Navigation Controllers", "Tab Bar Controller", "Navigation Controller", "Navigation Controller + Toolbar", "View Controller (With Child)", "View Controller (Without Child)" , "Split View Controller (Master)", "Split View Controller (Detail)", "Split View Controller (Global)", "Custom Container", "Custom Container (iPad Only)", "SwiftUI Demo (iOS 14+)"]
    let identifiers = ["TabBarNavController", "TabBarController", "NavController", "NavController", "ViewController", "", "SplitViewController", "SplitViewController", "SplitViewController", "DemoContainerController","DemoContainerController_iPad", "SwiftUIDemo"]

    var presentationStyle: UIModalPresentationStyle!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            #if compiler(>=5.1)
            self.tableView.backgroundColor = UIColor.systemBackground
            #endif
            
            self.presentationStyle = .fullScreen
            let presentation = UIBarButtonItem(title: "Page Sheet", style: .plain, target: self, action: #selector(presentationChanged(_:)))
            self.navigationItem.rightBarButtonItem = presentation
        }
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Navigation
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        print("\(self) \(#function) \(sourceViewController)")
        let destinationViewController = unwindSegue.destination
        print("\(self) \(#function) \(destinationViewController)")
    }

    @IBAction func presentationChanged(_ sender: Any) {
        if let presentation = sender as? UIBarButtonItem {
            self.presentationStyle = self.presentationStyle == .fullScreen ? .pageSheet : .fullScreen
            presentation.title = self.presentationStyle == .fullScreen ? "Page Sheet" : "Full Screen"
        }
    }
    
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

    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        //
        return UIContextMenuConfiguration(identifier: "Preview" as NSCopying, previewProvider: { () -> UIViewController? in
            let vc = self.viewControllerForIndexPath(indexPath)
            if indexPath.row == 4 {
                vc?.loadViewIfNeeded()
            }
            return vc
        }, actionProvider: nil)
    }
    
    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if let vc = animator.previewViewController {
            vc.modalPresentationStyle = .fullScreen
            #if compiler(>=5.1)
            vc.isModalInPresentation = true
            #endif
            
            animator.addCompletion {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let vc = self.viewControllerForIndexPath(indexPath) {
            vc.modalPresentationStyle = .fullScreen
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                vc.modalPresentationStyle = self.presentationStyle
                vc.isModalInPresentation = true
            }
            #endif
            
            self.present(vc, animated: true, completion: nil)
            // TODO: for internal tests (comment the line above & decomment the 2 lines below)
            //let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            //appDelegate.replaceRootViewControllerWith(controller: vc)
        }
    }

    func viewControllerForIndexPath(_ indexPath: IndexPath) -> UIViewController? {
        if indexPath.row == 11 {
            if #available(iOS 14.0, *) {
                let contentView = SceneSelection() {
                    self.dismiss(animated: true, completion: nil)
                }
                let vc = UIHostingController(rootView: contentView)
                return vc
            }
            return nil
        }
        if indexPath.row == 10 {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let vc = UIStoryboard(name: "Custom", bundle: nil).instantiateViewController(withIdentifier: self.identifiers[indexPath.row])
                vc.title = items[indexPath.row]
                return vc
            }
        }
        else if indexPath.row == 9 {
            let vc = UIStoryboard(name: "Custom", bundle: nil).instantiateViewController(withIdentifier: self.identifiers[indexPath.row])
            vc.title = items[indexPath.row]
            return vc
        }
        else if indexPath.row == 5 {
            let vc = DemoViewControllerNoChild()
            vc.view.backgroundColor = .white
            return vc
        }
        else if let vc = self.storyboard?.instantiateViewController(withIdentifier: self.identifiers[indexPath.row]) {
            if vc is UISplitViewController {
                let svc = vc as! SplitViewController
                if indexPath.row == 6 { // master
                    svc.masterIsContainer = true
                }
                if indexPath.row == 7 { // detail
                    svc.masterIsContainer = false
                }
                if indexPath.row == 8 { // global
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
            return vc
        }
        return nil
    }
}
