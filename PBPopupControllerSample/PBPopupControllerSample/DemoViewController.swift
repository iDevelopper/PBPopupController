//
//  DemoViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 14/11/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationController == nil {
            self.presentationController?.delegate = self
        }
        if let firstVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstTableViewController") as? FirstTableViewController {
            addChild(firstVC)
            firstVC.view.frame = self.containerView.bounds
            self.containerView.addSubview(firstVC.view)
            firstVC.didMove(toParent: self)

            self.view.backgroundColor = firstVC.view.backgroundColor
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        PBLog("deinit \(self)")
    }
}

extension DemoViewController: UIAdaptivePresentationControllerDelegate
{
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        print("presentationControllerShouldDismiss: \(presentationController.frameOfPresentedViewInContainerView)")
        return true
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        print("presentationControllerWillDismiss")
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("presentationControllerDidDismiss: \(presentationController.frameOfPresentedViewInContainerView)")
        if let firstVC = self.children[0] as? FirstTableViewController {
            firstVC.dismiss(self)
        }
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("presentationControllerDidAttemptToDismiss: \(presentationController.frameOfPresentedViewInContainerView)")
    }
}

extension DemoViewController: UINavigationControllerDelegate
{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            if let firstVC = self.children[0] as? FirstTableViewController {
                firstVC.dismiss(self)
            }
        }
        return nil
    }
}
