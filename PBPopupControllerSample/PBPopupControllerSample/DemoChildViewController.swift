//
//  DemoChildViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 22/10/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class DemoChildViewController: UIViewController, PBPopupControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
    }
    
    override public func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    deinit {
        PBLog("deinit \(self)")
    }

    // MARK: - Navigation
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismissPopup()
        self.performSegue(withIdentifier: "unwindToHome", sender: self)

        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.restoreInitialRootViewControllerIfNeeded()
    }
    
    // MARK: - Actions
    
    @IBAction func presentPopupBar(_ sender: UIButton) {
        if let containerVC = self.parent {
            containerVC.dismissPopupBar(animated: false) {
                self.presentPopup()
            }
        }
    }
    
    @IBAction func presentCustomPopupBar(_ sender: UIButton) {
        if let containerVC = self.parent {
            containerVC.dismissPopupBar(animated: false) {
                self.presentCustomPopup()
            }
        }
    }
    
    @IBAction func dismissPopupBar(_ sender: UIButton) {
        self.dismissPopup()
    }
    
    func presentCustomPopup() {
        if let containerVC = self.parent as? DemoContainerController {
            let customYTBar = self.storyboard?.instantiateViewController(withIdentifier: "CustomPopupBarViewController") as! CustomPopupBarViewController
            customYTBar.view.backgroundColor = .clear
            containerVC.popupController.dataSource = containerVC
            containerVC.popupBar.isTranslucent = false
            containerVC.popupBar.inheritsVisualStyleFromBottomBar = false
            containerVC.popupBar.customPopupBarViewController = customYTBar
            containerVC.popupBar.image = customYTBar.imageView.image
            containerVC.popupBar.title = customYTBar.titleLabel.text
            containerVC.popupBar.subtitle = customYTBar.subtitleLabel.text
            containerVC.popupContentView.popupCloseButtonStyle = .round
            //containerVC.popupContentView.popupPresentationStyle = .fullScreen
            //containerVC.popupContentView.popupEffectView.effect = nil
            let popupContentController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupContentViewController") as! PopupContentViewController
            popupContentController.albumArtImage = customYTBar.imageView.image!
            popupContentController.songTitle = customYTBar.titleLabel.text!
            popupContentController.albumTitle = customYTBar.subtitleLabel.text!
            if #available(iOS 14.0, *) {
                if containerVC.modalPresentationStyle == .pageSheet {
                    containerVC.popupContentView.popupPresentationStyle = .fullScreen
                }
            }
            DispatchQueue.main.async {
                containerVC.presentPopupBar(withPopupContentViewController: popupContentController, animated: true) {
                    PBLog("Custom Popup Bar Presented")
                }
            }
        }
    }
    
    func presentPopup() {
        if let containerVC = self.parent as? DemoContainerController {
            containerVC.popupController.dataSource = containerVC
            containerVC.popupBar.inheritsVisualStyleFromBottomBar = false
            containerVC.popupBar.image = UIImage(named: "Cover22")
            containerVC.popupBar.title = LoremIpsum.title
            containerVC.popupBar.subtitle = LoremIpsum.sentence
            containerVC.popupBar.shadowImageView.shadowOpacity = 0
            //containerVC.popupContentView.popupEffectView.effect = nil
            let popupContentController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupContentViewController") as! PopupContentViewController
            popupContentController.albumArtImage = UIImage(named: "Cover22")!
            popupContentController.songTitle = containerVC.popupBar.title!
            if #available(iOS 14.0, *) {
                if containerVC.modalPresentationStyle == .pageSheet {
                    containerVC.popupContentView.popupPresentationStyle = .fullScreen
                }
            }

            DispatchQueue.main.async {
                containerVC.presentPopupBar(withPopupContentViewController: popupContentController, animated: true) {
                    PBLog("Popup Bar Presented")
                }
            }
        }
    }
    
    func dismissPopup() {
        if let containerVC = self.parent {
            containerVC.dismissPopupBar(animated: true) {
                PBLog("Popup Bar Dismissed")
            }
        }
    }
}

