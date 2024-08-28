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
    var enableColorsDebug: Bool = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.systemBackground
        
        self.presentationStyle = .fullScreen
        let presentation = UIBarButtonItem(title: "Page Sheet", style: .plain, target: self, action: #selector(presentationChanged(_:)))
        self.navigationItem.rightBarButtonItem = presentation
        let enableColors = UIBarButtonItem(image: UIImage(systemName: "circle.hexagongrid.fill"), style: .plain, target: self, action: #selector(enableColorsDebug(_:)))
        self.navigationItem.leftBarButtonItem = enableColors
        
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
    
    @IBAction func enableColorsDebug(_ sender: Any) {
        if let enableColors = sender as? UIBarButtonItem {
            self.enableColorsDebug.toggle()
            enableColors.image = self.enableColorsDebug ? UIImage(systemName: "circle.hexagongrid.fill")?.withRenderingMode(.alwaysOriginal) : UIImage(systemName: "circle.hexagongrid.fill")
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
    
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if let vc = animator.previewViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.isModalInPresentation = true
            
            animator.addCompletion {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let vc = self.viewControllerForIndexPath(indexPath) {
            vc.modalPresentationStyle = .fullScreen
            vc.modalPresentationStyle = self.presentationStyle
            vc.isModalInPresentation = true
            
            vc.enablePopupBarColorsDebug = self.enableColorsDebug
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
                vc.title = self.items[indexPath.row]
                return vc
            }
            return nil
        }
        if indexPath.row == 10 {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let vc = UIStoryboard(name: "Custom", bundle: nil).instantiateViewController(withIdentifier: self.identifiers[indexPath.row])
                vc.title = self.items[indexPath.row]
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
            vc.title = self.items[indexPath.row]
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
                svc.title = self.items[indexPath.row]
            }
            if vc is UINavigationController {
                let nc = vc as! NavigationController
                nc.toolbarIsShown = false
                if indexPath.row == 3 {
                    nc.toolbarIsShown = true
                }
                nc.title = self.items[indexPath.row]
            }
            if vc is UITabBarController {
               vc.title = self.items[indexPath.row]
            }
            return vc
        }
        return nil
    }
}
