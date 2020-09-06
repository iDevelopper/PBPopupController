//
//  DemoContainerController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 22/10/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class DemoContainerController: UIViewController, UIToolbarDelegate, PBPopupControllerDataSource {
    
    let useConstraintsForBottomBar: Bool = false
    var constraintsForBottomBar: [NSLayoutConstraint]!
    var isFrameSetted: Bool = false
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomBarView: UIToolbar!
    
    var viewControllers = [UIViewController?]()
    var selectedIndex: Int = 0
    var currentChildVC: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.additionalSafeAreaInsetsBottomForContainer = self.frameForBottomBar().height

        self.bottomBarView.delegate = self
        
        if let childVC1 = self.storyboard?.instantiateViewController(withIdentifier: "DemoChildViewController") as? DemoChildViewController {
            if #available(iOS 13.0, *) {
                #if compiler(>=5.1)
                childVC1.view.backgroundColor = UIColor.PBRandomAdaptiveColor()
                #else
                childVC1.view.backgroundColor = UIColor.PBRandomExtraLightColor()
                #endif
            } else {
                childVC1.view.backgroundColor = UIColor.PBRandomExtraLightColor()
            }
            self.viewControllers.append(childVC1)
        }
        
        if let childVC2 = self.storyboard?.instantiateViewController(withIdentifier: "DemoChildViewController") as? DemoChildViewController {
            if #available(iOS 13.0, *) {
                #if compiler(>=5.1)
                childVC2.view.backgroundColor = UIColor.PBRandomAdaptiveColor()
                #else
                childVC2.view.backgroundColor = UIColor.PBRandomExtraLightColor()
                #endif
            } else {
                childVC2.view.backgroundColor = UIColor.PBRandomExtraLightColor()
            }
            self.viewControllers.append(childVC2)
        }
        if let childVC3 = self.storyboard?.instantiateViewController(withIdentifier: "DemoChildViewController") as? DemoChildViewController {
            if #available(iOS 13.0, *) {
                #if compiler(>=5.1)
                childVC3.view.backgroundColor = UIColor.PBRandomAdaptiveColor()
                #else
                childVC3.view.backgroundColor = UIColor.PBRandomExtraLightColor()
                #endif
            } else {
                childVC3.view.backgroundColor = UIColor.PBRandomExtraLightColor()
            }
            self.viewControllers.append(childVC3)
        }
        for controller in self.viewControllers {
            if let child = controller as? DemoChildViewController  {
                addChild(child)
            }
        }
        self.selectedIndex = 0
        
        self.presentChild()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        if let constraints = self.constraintsForBottomBar {
            NSLayoutConstraint.deactivate(constraints)
        }
        super.viewWillLayoutSubviews()
        
        if useConstraintsForBottomBar == true {
            self.setupConstraintsForBottomBar()
        }
        else {
            if !self.isFrameSetted {
                self.setupFrameForBottomBar()
                self.isFrameSetted.toggle()
            }
        }
    }

    deinit {
        PBLog("deinit \(self)")
    }
    
    // MARK: - Navigation
    
    @IBAction func dismiss(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    @IBAction func itemSelected(_ sender: UIBarButtonItem) {
        if sender.tag != self.selectedIndex {
            self.selectedIndex = sender.tag
            self.presentChild()
        }
    }

    func presentChild() {
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

    // MARK: - Frames
    
    func setupConstraintsForBottomBar() {
        var insets: UIEdgeInsets = .zero
        insets = self.view.superview?.safeAreaInsets ?? .zero
        
        self.bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        self.constraintsForBottomBar = [
            self.bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ]
        NSLayoutConstraint.activate(self.constraintsForBottomBar)
    }
    
    func setupFrameForBottomBar() {
        var frame = self.frameForBottomBar()
        frame.origin.y -= self.insetsForBottomBar().bottom
        self.bottomBarView.frame = frame
    }
    
    func frameForBottomBar() -> CGRect {
        var height: CGFloat = 0
        height = self.bottomBarView.frame.height
        
        let frame = CGRect(x: 0, y: self.view.bounds.height - height/* - insets.bottom*/, width: self.view.bounds.width, height: height)
        //PBLog(frame, error: true)
        return frame
    }
    
    func insetsForBottomBar() -> UIEdgeInsets {
        var insets: UIEdgeInsets = .zero
        insets = self.view.superview?.safeAreaInsets ?? .zero
        //PBLog(insets.bottom, error: true)
        return insets
    }
    
    // MARK: - UIToolbar delegate
    
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .bottom
    }
    
    // MARK: - PBPopupController dataSource
    
    func bottomBarView(for popupController: PBPopupController) -> UIView? {
        return self.bottomBarView
    }
    
    func popupController(_ popupController: PBPopupController, defaultFrameFor bottomBarView: UIView) -> CGRect {
        return self.frameForBottomBar()
    }
    
    func popupController(_ popupController: PBPopupController, insetsFor bottomBarView: UIView) -> UIEdgeInsets {
        return self.insetsForBottomBar()
    }
}
