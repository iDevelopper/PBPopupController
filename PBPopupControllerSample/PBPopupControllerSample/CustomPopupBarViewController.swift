//
//  CustomPopupBarViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 04/09/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

class CustomPopupBarViewController: UIViewController {
    @IBOutlet weak var barView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = CGSize(width: -1, height: 65)
        
        self.view.preservesSuperviewLayoutMargins = true
        
        barView.layer.shadowColor = UIColor.black.cgColor
        barView.layer.shadowOpacity = 0.5
        barView.layer.shadowRadius = 5
        barView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        barView.layer.cornerRadius = 2
    }
    
    @IBAction func playPause(_ sender: Any) {
        PBLog("Popup Bar playPause")
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.popupContainerViewController.dismissPopupBar(animated: true) {
            PBLog("Popup Bar Dismissed")
        }
    }
}
