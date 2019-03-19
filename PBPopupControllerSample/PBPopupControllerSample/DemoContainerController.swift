//
//  DemoContainerController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 22/10/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

public extension UIViewController {
    
    var containerController: DemoContainerController? {
        var current: UIViewController? = parent
        
        repeat {
            if current is DemoContainerController { return current as? DemoContainerController }
            current = current?.parent
        } while current != nil
        
        return nil
    }
}

public class DemoContainerController: UIViewController {
    
    let useConstraintsForBottomBar: Bool = true
    let useSafeAreaLayoutGuideForChild: Bool = true

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    var viewControllers: [UIViewController?]! {
        didSet {
            for controller in viewControllers {
                if controller != nil {
                    addChild(controller!)
                }
            }
        }
    }

    var selectedIndex: Int = 0
    var currentChildVC: UIViewController!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [UIViewController]()
        
        buttonsStackView.alignment = .fill
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 0
        
        for button in (self.buttonsStackView?.arrangedSubviews)! {
            (button as! UIButton).addTarget(self, action: #selector(self.tabButtonAction(button:)), for: .touchUpInside)
        }
        
        let childVC1 = self.storyboard?.instantiateViewController(withIdentifier: "ChildViewController") as? DemoChildViewController
        childVC1?.view.backgroundColor = UIColor.PBRandomExtraLightColor()
        
        let childVC2 = self.storyboard?.instantiateViewController(withIdentifier: "ChildViewController") as? DemoChildViewController
        childVC2?.view.backgroundColor = UIColor.PBRandomExtraLightColor()
        childVC2?.title = "ChildVC2"
        let nc = UINavigationController(rootViewController: childVC2!)
        nc.view.backgroundColor = childVC2?.view.backgroundColor

        let childVC3 = self.storyboard?.instantiateViewController(withIdentifier: "ChildViewController") as? DemoChildViewController
        childVC3?.view.backgroundColor = UIColor.PBRandomExtraLightColor()

        self.viewControllers = [childVC1, nc, childVC3]
        
        self.selectedIndex = 0
        
        self.presentChild()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    @objc func tabButtonAction(button: UIButton) {
        if let index = self.buttonsStackView.arrangedSubviews.index(of: button) {
            if index != self.selectedIndex {
                self.selectedIndex = index
                self.presentChild()
            }
        }
    }
    
    func presentChild() {
        if let childVC = self.viewControllers[selectedIndex] {
            self.containerView.addSubview(childVC.view)
            childVC.didMove(toParent: self)
            self.currentChildVC?.willMove(toParent: nil)
            self.currentChildVC?.view.removeFromSuperview()
            self.currentChildVC = childVC
            
            self.view.backgroundColor = currentChildVC.view.backgroundColor
            self.setupConstraintsForChildController()
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if useConstraintsForBottomBar == true {
            self.setupConstraintsForBottomBar()
        }
        else {
            self.setupFrameForBottomBar()
        }
        self.setupConstraintsForButtonsStackView()
        self.setupConstraintsForContainerView()
    }
    
    func setupConstraintsForContainerView() {
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo:(self.view.topAnchor)),
            self.containerView.leftAnchor.constraint(equalTo: (self.view.leftAnchor)),
            self.containerView.rightAnchor.constraint(equalTo: (self.view.rightAnchor)),
            self.containerView.bottomAnchor.constraint(equalTo: (self.bottomBarView.topAnchor))
            ])
    }
    
    func setupConstraintsForBottomBar() {
        var height: CGFloat = 50
        if #available(iOS 11.0, *) {
            height += self.view.superview?.safeAreaInsets.bottom ?? 0.0
        }
        NSLayoutConstraint.deactivate(self.bottomBarView.constraints)
        self.bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.bottomBarView.leadingAnchor.constraint(equalTo: (self.view.leadingAnchor)),
            self.bottomBarView.trailingAnchor.constraint(equalTo: (self.view.trailingAnchor)),
            self.bottomBarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.bottomBarView.heightAnchor.constraint(equalToConstant: height)
            ])
    }
    
    func setupConstraintsForButtonsStackView() {
        self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.buttonsStackView.topAnchor.constraint(equalTo: self.bottomBarView.topAnchor),
            self.buttonsStackView.leadingAnchor.constraint(equalTo: self.bottomBarView.leadingAnchor, constant: 0),
            self.buttonsStackView.trailingAnchor.constraint(equalTo: self.bottomBarView.trailingAnchor, constant: 0),
            self.buttonsStackView.heightAnchor.constraint(equalToConstant: 50)
            ])
    }
    
    func setupConstraintsForChildController() {
        currentChildVC.view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            self.currentChildVC.view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
            self.currentChildVC.view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
            self.currentChildVC.view.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
            if useSafeAreaLayoutGuideForChild == true {
                let guide = self.view.safeAreaLayoutGuide
                self.currentChildVC.view.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -50).isActive = true
            }
            else {
                self.currentChildVC.view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
            }
        } else {
            // Fallback on earlier versions
            self.currentChildVC.view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
            self.currentChildVC.view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
            self.currentChildVC.view.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
            self.currentChildVC.view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
        }
    }
    
    func setupFrameForBottomBar() {
        var height: CGFloat = 50
        if #available(iOS 11.0, *) {
            height += self.view.superview?.safeAreaInsets.bottom ?? 0.0
        }
        self.bottomBarView.frame = CGRect(x: 0, y: self.view.bounds.height - height, width: self.view.bounds.width, height: height)
    }
}
