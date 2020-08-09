//
//  SplitViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 08/11/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    var masterIsContainer: Bool = false
    var globalIsContainer: Bool = false
    
    weak var containerVC: UIViewController!
    weak var detailVC: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        preferredDisplayMode = .allVisible
        if #available(iOS 14.0, *) {
            preferredSplitBehavior = .tile
        }
        #if targetEnvironment(macCatalyst)
            self.primaryBackgroundStyle = .sidebar
        #endif
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 14.0, *) {
            if self.viewControllers.count > 1 {
                if let vc1 = viewControllers[0] as? UINavigationController, let vc2 = viewControllers[1] as? UINavigationController {
                    if let primaryVC = vc1.topViewController as? FirstTableViewController {
                        self.containerVC = globalIsContainer ? self : masterIsContainer ? vc1 : vc2
                        self.detailVC = vc2
                        primaryVC.title = globalIsContainer ? "Split View Controller (Global)": masterIsContainer ? "Split View Controller (Master)" : "Split View Controller (Detail)"
                        primaryVC.loadViewIfNeeded()
                    }
                }
            }
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        if let vc1 = primaryViewController as? UINavigationController, let vc2 = secondaryViewController as? DemoViewController {
            if let primaryVC = vc1.topViewController as? FirstTableViewController {
                self.containerVC = globalIsContainer ? self : masterIsContainer ? vc1 : vc2
                self.detailVC = vc2
                primaryVC.title = globalIsContainer ? "Split View Controller (Global)": masterIsContainer ? "Split View Controller (Master)" : "Split View Controller (Detail)"
                primaryVC.loadViewIfNeeded()
            }
        }
        return globalIsContainer ? true: masterIsContainer ? true : false
    }
}
