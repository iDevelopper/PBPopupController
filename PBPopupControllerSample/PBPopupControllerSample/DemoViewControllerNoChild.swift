//
//  DemoViewControllerNoChild.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 11/09/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class DemoViewControllerNoChild: UIViewController, PBPopupControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.systemBackground
        }
        else {
            self.view.backgroundColor = .white
        }
        
        let topLabel = UILabel()
        //topLabel.text = "Top"
        topLabel.text = self.title
        
        if #available(iOS 13.0, *) {
            topLabel.textColor = UIColor.label
        }
        self.view.addSubview(topLabel)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        topLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        
        let bottomLabel = UILabel()
        bottomLabel.text = "Bottom"
        
        if #available(iOS 13.0, *) {
            bottomLabel.textColor = UIColor.label
        }
        self.view.addSubview(bottomLabel)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        bottomLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        
        let presentButton = UIButton(type: .system)
        presentButton.setTitle("Present", for: .normal)
        presentButton.addTarget(self, action: #selector(presentPopupBar(_:)), for: .touchUpInside)
        let bottomSheetButton = UIButton(type: .system)
        bottomSheetButton.setTitle("Present Popup", for: .normal)
        bottomSheetButton.addTarget(self, action: #selector(presentBottomSheet(_:)), for: .touchUpInside)
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [presentButton, bottomSheetButton, dismissButton, closeButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presentPopupBar(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    @objc func close(_ sender: Any) {
        self.dismissPopupBar(animated: true) {
            PBLog("Popup Bar Dismissed")
            self.dismiss(animated: true, completion: nil)
            
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.restoreInitialRootViewControllerIfNeeded()
        }
    }
    
    @objc func dismiss(_ sender: Any) {
        self.dismissPopupBar(animated: true) {
            PBLog("Popup Bar Dismissed")
        }
    }
    
    @objc func presentPopupBar(_ sender: Any) {
        self.dismissPopupBar(animated: false) {
            self.popupBar.image = UIImage(named: String(format: "Cover%02d", Int.random(in: 1...23)))
            self.popupBar.title = LoremIpsum.title
            self.popupBar.subtitle = LoremIpsum.sentence
            self.popupContentView.popupCloseButtonStyle = .chevron
            self.popupContentView.popupIgnoreDropShadowView = false
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let contentVC = storyboard.instantiateViewController(withIdentifier: "PopupContentViewController") as? PopupContentViewController {
                contentVC.backgroundView = UIImageView(image: self.popupBar.image)
                contentVC.albumArtImage = self.popupBar.image
                contentVC.albumTitle = self.popupBar.title
                contentVC.songTitle = self.popupBar.subtitle
                
                if #available(iOS 13.0, *) {
                    let scaleConfig = UIImage.SymbolConfiguration(scale: .large)
                    let weightConfig = UIImage.SymbolConfiguration(weight: .semibold)
                    let config = scaleConfig.applying(weightConfig)
                    
                    var image: UIImage!
                    image = UIImage(systemName: "play.fill", withConfiguration: config)?.withAlignmentRectInsets(.zero).imageWithoutBaseline()
                    let playItem = UIBarButtonItem(image: image, style: .plain, target: contentVC, action: #selector(PopupContentViewController.playPauseAction(_:)))
                    playItem.width = 50
                    image = UIImage(systemName: "xmark", withConfiguration: config)?.withAlignmentRectInsets(.zero).imageWithoutBaseline()
                    let closeItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.close(_:)))
                    self.popupBar.rightBarButtonItems = [playItem, closeItem]
                }
                else {
                    let closeItem = UIBarButtonItem(image: UIImage(named: "close-small"), style: .plain, target: self, action: #selector(self.close(_:)))
                    let playItem = UIBarButtonItem(image: UIImage(named: "play-small"), style: .plain, target: contentVC, action: #selector(PopupContentViewController.playPauseAction(_:)))
                    playItem.width = 50
                    self.popupBar.rightBarButtonItems = [playItem, closeItem]
                }
                
                DispatchQueue.main.async {
                    self.presentPopupBar(withPopupContentViewController: contentVC, animated: true) {
                        PBLog("Popup Bar Presented")
                    }
                }
            }
        }
    }
    
    @objc func presentBottomSheet(_ sender: UIButton) {
        self.dismissPopupBar(animated: false) {
            let viewController = DemoBottomSheetViewController()
            self.popupController.delegate = self
            /*
            self.presentPopup(withPopupContentViewController: viewController, size: CGSize(width: self.view.bounds.width - 40, height: 300), animated: true) {
                //
            }
            */
            if UIDevice.current.userInterfaceIdiom == .pad, self.modalPresentationStyle == .pageSheet {
                self.popupContentView.additionalFloatingBottomInset = 8.0
            }
            self.presentPopup(withPopupContentViewController: viewController, animated: true) {
                PBLog("Popup Presented (Bottom Sheet)")
            }
            
        }
    }
    
    func popupControllerPanGestureShouldBegin(_ popupController: PBPopupController, state: PBPopupPresentationState) -> Bool {
        return false
    }
}
