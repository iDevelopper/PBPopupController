//
//  SplitViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 08/11/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    var masterIsContainer: Bool = false
    var globalIsContainer: Bool = false
    
    weak var containerVC: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Task { @MainActor in
            self.delegate = self
            self.preferredDisplayMode = .allVisible
            self.preferredPrimaryColumnWidthFraction = 0.4
#if targetEnvironment(macCatalyst)
            self.primaryBackgroundStyle = .sidebar
#else
            if #available(iOS 14.0, *) {
                self.preferredSplitBehavior = .tile
            }
#endif
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        if #available(iOS 14.0, *) {
            if self.viewControllers.count > 1 {
                if let vc1 = viewControllers[0] as? NavigationController, let vc2 = viewControllers[1] as? UINavigationController {
                    vc1.topViewController?.title = "Master"
                    vc2.topViewController?.title = "Detail"
                    self.containerVC = globalIsContainer ? self : masterIsContainer ? vc1 : vc2
                }
            }
        }
    }
    
    deinit {
        PBLog("Deinit: \(self)")
    }    
    
#if !targetEnvironment(macCatalyst)
    @available(iOS 14.0, *)
    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return globalIsContainer ? .primary: masterIsContainer ? .primary : .secondary
    }
#endif
}
