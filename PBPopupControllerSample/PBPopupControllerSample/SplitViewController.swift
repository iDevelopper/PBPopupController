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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        preferredDisplayMode = .allVisible
        #if targetEnvironment(macCatalyst)
            self.primaryBackgroundStyle = .sidebar
        #endif
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        if let nc1 = primaryViewController as? UINavigationController, let nc2 = secondaryViewController as? UINavigationController {
            if let primaryVC = nc1.topViewController as? FirstTableViewController, let secondaryVC = nc2.topViewController as? DemoTableViewController {
                primaryVC.containerVC = globalIsContainer ? self : masterIsContainer ? nc1 : nc2
                secondaryVC.firstVC = primaryVC
                secondaryVC.title = "DemoTableViewController"
                primaryVC.loadViewIfNeeded()
            }
        }
        return false
    }
}
