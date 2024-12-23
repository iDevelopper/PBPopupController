//
//  PBUIKitPopupContentController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 11/10/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class PBUIKitPopupContentController : UIViewController {

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        guard let containerVC = self.popupContainerViewController else {return.default}
        //guard let popupContentView = containerVC.popupContentView else {return .default}
        
        return containerVC.popupController.popupStatusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "UIKit\nPopup Content Controller"
        label.font = .preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(label)
        NSLayoutConstraint.activate([
            self.view.centerXAnchor.constraint(equalTo: label.centerXAnchor),
            self.view.centerYAnchor.constraint(equalTo: label.centerYAnchor),
        ])
    }
}
