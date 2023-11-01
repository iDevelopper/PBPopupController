//
//  DemoViewControllerNoChild.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 11/09/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class DemoViewControllerNoChild: UIViewController {

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
                image = UIImage(systemName: "xmark", withConfiguration: config)?.withAlignmentRectInsets(.zero).imageWithoutBaseline()
                let closeItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(close(_:)))
                self.popupBar.rightBarButtonItems = [playItem, closeItem]
            }
            else {
                let closeItem = UIBarButtonItem(image: UIImage(named: "close-small"), style: .plain, target: self, action: #selector(close(_:)))
                let playItem = UIBarButtonItem(image: UIImage(named: "play-small"), style: .plain, target: contentVC, action: #selector(PopupContentViewController.playPauseAction(_:)))
                self.popupBar.rightBarButtonItems = [playItem, closeItem]
            }
            
            DispatchQueue.main.async {
                self.presentPopupBar(withPopupContentViewController: contentVC, animated: true) {
                    PBLog("Popup Bar Presented")
                }
            }
        }
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
}
