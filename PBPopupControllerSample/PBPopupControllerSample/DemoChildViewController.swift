//
//  DemoChildViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 22/10/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class DemoChildViewController: UIViewController, PBPopupControllerDelegate, PBPopupControllerDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            #if compiler(>=5.1)
            self.view.tintColor = UIColor.white
            #else
            self.view.tintColor = UIColor.white
            #endif
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismissPopup()
        self.performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    // MARK: - Actions
    
    @IBAction func presentPopupBar(_ sender: UIButton) {
        if let containerVC = self.containerController {
            containerVC.dismissPopupBar(animated: false) {
                self.presentPopup()
            }
        }

    }
    
    @IBAction func presentCustomPopupBar(_ sender: UIButton) {
        if let containerVC = self.containerController {
            containerVC.dismissPopupBar(animated: false) {
                self.presentCustomPopup()
            }
        }
    }
    
    @IBAction func dismissPopupBar(_ sender: UIButton) {
        self.dismissPopup()
    }
    
    func presentCustomPopup() {
        if let containerVC = self.containerController {
            let customYTBar = self.storyboard?.instantiateViewController(withIdentifier: "CustomPopupBarViewController") as! CustomPopupBarViewController
            customYTBar.view.backgroundColor = .clear
            containerVC.popupController.dataSource = self
            containerVC.popupBar.isTranslucent = false
            containerVC.popupBar.inheritsVisualStyleFromBottomBar = false
            containerVC.popupBar.customPopupBarViewController = customYTBar
            containerVC.popupContentView.popupCloseButtonStyle = .round
            containerVC.popupContentView.popupEffectView.effect = nil
            let popupContentController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupContentViewController") as! PopupContentViewController
            containerVC.popupBar.image = customYTBar.imageView.image
            containerVC.popupBar.title = customYTBar.titleLabel.text
            containerVC.popupBar.subtitle = customYTBar.subtitleLabel.text
            DispatchQueue.main.async {
                containerVC.presentPopupBar(withPopupContentViewController: popupContentController, animated: true) {
                    PBLog("Custom Popup Bar Presented")
                }
            }
        }
    }
    
    func presentPopup() {
        if let containerVC = self.containerController {
            containerVC.popupBar.inheritsVisualStyleFromBottomBar = false
            let popupContentController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupContentViewController") as! PopupContentViewController
            containerVC.popupController.dataSource = self
            containerVC.popupBar.image = UIImage(named: "Cover22")
            containerVC.popupBar.title = LoremIpsum.title
            
            containerVC.popupContentView.popupEffectView.effect = nil
            //containerVC.popupContentView.popupPresentationDuration = 6
            
            DispatchQueue.main.async {
                containerVC.presentPopupBar(withPopupContentViewController: popupContentController, animated: true) {
                    PBLog("Popup Bar Presented")
                }
            }
        }
    }
    
    func dismissPopup() {
        if let containerVC = self.containerController {
            containerVC.dismissPopupBar(animated: true) {
                PBLog("Popup Bar Dismissed")
            }
        }
    }
    
    // MARK: - PBPopupController dataSource
    
    func bottomBarView(for popupController: PBPopupController) -> UIView? {
        return self.containerController?.bottomBarView
    }
    
    func popupController(_ popupController: PBPopupController, defaultFrameFor bottomBarView: UIView) -> CGRect {
        return self.containerController?.bottomBarView.frame ?? CGRect.zero
    }
    
    func popupController(_ popupController: PBPopupController, insetsFor bottomBarView: UIView) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
}

