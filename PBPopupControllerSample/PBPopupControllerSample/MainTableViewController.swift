//
//  MainTableViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 20/06/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import WebKit
import SwiftUI

class MainPopupNavigationController: UINavigationController
{
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let container = self.popupContainerViewController else { return .default }
        guard let popupController = container.popupController else { return .default }
        
        let popupStatusBarStyle = popupController.popupStatusBarStyle
        return popupStatusBarStyle
    }
}
class MainWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate
{
    private let webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        guard let url = URL(string: "https://github.com/iDevelopper/PBPopupController") else { return }
        
        webView.isHidden = true
        webView.load(URLRequest(url: url))

        if #available(iOS 17.0, *) {
            self.registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                guard let containerVC = self.navigationController?.popupContainerViewController else { return }
                guard let popupController = containerVC.popupController else { return }
                
                let userInterfaceStyle = self.traitCollection.userInterfaceStyle
                popupController.popupPreferredStatusBarStyle = userInterfaceStyle == .light ? .darkContent : .lightContent

                self.navigationController?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard let containerVC = self.navigationController?.popupContainerViewController else { return }
        guard let popupController = containerVC.popupController else { return }
        
        let userInterfaceStyle = self.traitCollection.userInterfaceStyle
        popupController.popupPreferredStatusBarStyle = userInterfaceStyle == .light ? .darkContent : .lightContent

        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        webView.isHidden = false
    }
}

extension MainWebViewController: UIGestureRecognizerDelegate
{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let containerVC = self.navigationController?.popupContainerViewController else { return false }
        guard let popupController = containerVC.popupController else { return false }

        if gestureRecognizer == popupController.popupContentPanGestureRecognizer && NSStringFromClass(type(of: otherGestureRecognizer.view!).self).contains("WKScrollView") {
            let scrollView = otherGestureRecognizer.view as! UIScrollView
            //print("contentOffset: \(scrollView.contentOffset.y)")
            if scrollView.contentOffset.y <= 0 {
                return false
            }
            return true
        }
        return false
    }
}

class MainTableViewController: UITableViewController {
    
    let items = ["TabBar + Navigation Controllers", "Tab Bar Controller", "Navigation Controller", "Navigation Controller + Toolbar", "View Controller (With Child)", "View Controller (Without Child)" , "Split View Controller (Master)", "Split View Controller (Detail)", "Split View Controller (Global)", "Custom Container", "Custom Container (iPad Only)", "SwiftUI Demo (iOS 14+)"]
    let identifiers = ["TabBarNavController", "TabBarController", "NavController", "NavController", "ViewController", "", "SplitViewController", "SplitViewController", "SplitViewController", "DemoContainerController","DemoContainerController_iPad", "SwiftUIDemo"]

    var presentationStyle: UIModalPresentationStyle!
    var enableColorsDebug: Bool = false
    
    // MARK: - View lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let userInterfaceStyle = self.traitCollection.userInterfaceStyle
        return userInterfaceStyle == .light ? .darkContent : .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.systemBackground
        
        self.presentationStyle = .fullScreen
        let presentation = UIBarButtonItem(title: "Page Sheet", style: .plain, target: self, action: #selector(presentationChanged(_:)))
        self.navigationItem.rightBarButtonItem = presentation
        let enableColors = UIBarButtonItem(image: UIImage(systemName: "circle.hexagongrid.fill"), style: .plain, target: self, action: #selector(enableColorsDebug(_:)))
        self.navigationItem.leftBarButtonItem = enableColors
        
        self.tableView.tableFooterView = UIView()
        
        self.setupPopupBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.navigationController?.popupController.popupPresentationState == .hidden {
            let vc = MainWebViewController()
            let nc = MainPopupNavigationController(rootViewController: vc)
            vc.view.backgroundColor = .systemBackground
            self.navigationController?.presentPopupBar(withPopupContentViewController: nc, animated: true, completion: {
                print("Popup Bar Presented!")
                //self.navigationController?.popupController.popupContentPanGestureRecognizer.delegate = vc
            })
        }
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

    // MARK: - PopupBar setup
    
    func setupPopupBar() {
        if let popupBar = self.navigationController?.popupBar {
            
            if #available(iOS 17.0, *) {
                popupBar.isFloating = true
            }
            
            popupBar.inheritsVisualStyleFromBottomBar = true
            popupBar.shadowImageView.shadowOpacity = 0
            popupBar.borderViewStyle = .none

            popupBar.image = UIImage(named: "AppImage")
            popupBar.title = NSLocalizedString("Welcome to PBPopupController!", comment: "")
            popupBar.image?.accessibilityLabel = NSLocalizedString("Welcome to PBPopupController!", comment: "")
                        
            if let popupContentView = self.navigationController?.popupContentView {
                popupContentView.popupIgnoreDropShadowView = true
                popupContentView.popupCanDismissOnPassthroughViews = true
                popupContentView.popupCloseButtonStyle = .chevron
                popupContentView.popupPresentationStyle = .fullScreen
            }
            
            self.navigationController?.popupController.containerPreferredStatusBarStyle = .default
            self.navigationController?.popupController.popupPreferredStatusBarStyle = self.traitCollection.userInterfaceStyle == .light ? .darkContent : .lightContent
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
            vc.enablePopupColorsDebug = self.enableColorsDebug
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
