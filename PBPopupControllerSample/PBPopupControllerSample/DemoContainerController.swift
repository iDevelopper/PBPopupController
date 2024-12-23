//
//  DemoContainerController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 22/10/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class DemoContainerController: UIViewController, UITabBarDelegate, PBPopupControllerDataSource, PBPopupControllerDelegate {
    
    var constraintsForBottomBar: [NSLayoutConstraint]!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var tabBar: UITabBar! {
        didSet {
            self.popupController.delegate = self
            self.additionalSafeAreaInsetsBottomForContainer = self.tabBar.frame.height
            tabBar.delegate = self
        }
    }
    
    var viewControllers = [UIViewController?]()
    var selectedIndex: Int = 0
    var currentChildVC: UIViewController!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let userInterfaceStyle = self.traitCollection.userInterfaceStyle
        return userInterfaceStyle == .light ? .darkContent : .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupConstraintsForBottomBar()
        
        if let childVC1 = self.storyboard?.instantiateViewController(withIdentifier: "DemoChildViewController") as? DemoChildViewController {
            childVC1.view.backgroundColor = UIColor.PBRandomAdaptiveColor()
            childVC1.childTitle.text = self.tabBar.items![0].title
            self.viewControllers.append(childVC1)
        }
        
        if let childVC2 = self.storyboard?.instantiateViewController(withIdentifier: "DemoChildViewController") as? DemoChildViewController {
            childVC2.view.backgroundColor = UIColor.PBRandomAdaptiveColor()
            childVC2.childTitle.text = self.tabBar.items![1].title
            self.viewControllers.append(childVC2)
        }
        
        if let childVC3 = self.storyboard?.instantiateViewController(withIdentifier: "DemoChildViewController") as? DemoChildViewController {
            childVC3.view.backgroundColor = UIColor.PBRandomAdaptiveColor()
            childVC3.childTitle.text = self.tabBar.items![2].title
            self.viewControllers.append(childVC3)
        }
        
        for controller in self.viewControllers {
            if let child = controller as? DemoChildViewController  {
                self.addChild(child)
            }
        }
        self.selectedIndex = 0
        
        self.tabBar.selectedItem = self.tabBar.items?.first
        
        self.presentChild()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    deinit {
        PBLog("deinit \(self)")
    }
    
    // MARK: - Navigation
    
    func presentChild() {
        self.popupController.delegate = self
        
        if let childVC = self.viewControllers[selectedIndex] {
            self.currentChildVC?.willMove(toParent: nil)
            childVC.view.frame = self.containerView.bounds
            self.containerView.addSubview(childVC.view)
            childVC.didMove(toParent: self)
            self.currentChildVC?.view.removeFromSuperview()
            self.currentChildVC = childVC
            
            self.view.backgroundColor = currentChildVC.view.backgroundColor
            self.containerView.backgroundColor = self.view.backgroundColor
        }
    }
    
    // MARK: - Layout
    
    func setupConstraintsForBottomBar() {
        self.bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        self.constraintsForBottomBar = [
            self.bottomBarView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.bottomBarView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.bottomBarView.heightAnchor.constraint(lessThanOrEqualToConstant: 83),
            self.bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            self.tabBar.leadingAnchor.constraint(equalTo: self.bottomBarView.leadingAnchor),
            self.tabBar.trailingAnchor.constraint(equalTo: self.bottomBarView.trailingAnchor),
            self.tabBar.topAnchor.constraint(equalTo: self.bottomBarView.topAnchor),
            self.tabBar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(self.constraintsForBottomBar)
    }
    
    func frameForBottomBar() -> CGRect {
        var height: CGFloat = 0
        height = self.bottomBarView.frame.height
        
        let frame = CGRect(x: 0, y: self.view.bounds.height - height, width: self.view.bounds.width, height: height)
        //PBLog(frame, error: true)
        return frame
    }
    
    // MARK: - UITabBar delegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag != self.selectedIndex {
            self.selectedIndex = item.tag
            self.presentChild()
        }
    }
    
    // MARK: - PBPopupController dataSource
    
    func bottomBarView(for popupController: PBPopupController) -> UIView? {
        return self.bottomBarView
    }
    
    func popupController(_ popupController: PBPopupController, defaultFrameFor bottomBarView: UIView) -> CGRect {
        return self.frameForBottomBar()
    }
    
    func popupController(_ popupController: PBPopupController, insetsFor bottomBarView: UIView) -> UIEdgeInsets {
        return .zero
    }
    
    // MARK: - PBPopupController delegate
    
    func popupControllerTapGestureShouldBegin(_ popupController: PBPopupController, state: PBPopupPresentationState) -> Bool {
        return true
    }
    
    func popupControllerPanGestureShouldBegin(_ popupController: PBPopupController, state: PBPopupPresentationState) -> Bool {
        if self.popupContentViewController is DemoBottomSheetViewController {
            return false
        }
        return true
    }
    
    func popupController(_ popupController: PBPopupController, shouldOpen popupContentViewController: UIViewController) -> Bool {
        if popupContentViewController is DemoBottomSheetViewController {
            return true
        }
        switch self.selectedIndex {
        case 0:
            self.popupContentView.popupPresentationStyle = .deck
        case 1:
            self.popupContentView.popupPresentationStyle = .fullScreen
            
        default:
            self.popupContentView.popupPresentationStyle = .custom
            let height = self.view.bounds.height * (self.traitCollection.verticalSizeClass == .compact ? 0.90 : 0.75)
            self.popupContentView.popupContentSize = CGSize(width: -1, height: height)
        }
        return true
    }
    
    func additionalAnimationsForOpening(popupController: PBPopupController, popupContentViewController: UIViewController, isInteractive: Bool) -> (() -> Void)? {
        PBLog("additionalAnimationsForOpening")
        if isInteractive {
            popupContentViewController.view.alpha = 1.0
            return nil
        }
        
        popupContentViewController.view.alpha = 0.0
        return {
            popupContentViewController.view.alpha = 1.0
        }
    }
    
    func additionalAnimationsForClosing(popupController: PBPopupController, popupContentViewController: UIViewController, isInteractive: Bool) -> (() -> Void)? {
        PBLog("additionalAnimationsForClosing")
        if let nc = popupContentViewController as? UINavigationController, let popupContent = nc.topViewController as? PopupContentViewController {
            return {
                popupContent.view.alpha = 0.0
            }
        }
        else {
            return {
                popupContentViewController.view.alpha = 0.0
            }
        }
    }
    
    func popupController(_ popupController: PBPopupController, didClose popupContentViewController: UIViewController) {
        PBLog("didClose - state: \(popupController.popupPresentationState.description)")
        
        popupContentViewController.view.alpha = 1.0
    }
}
