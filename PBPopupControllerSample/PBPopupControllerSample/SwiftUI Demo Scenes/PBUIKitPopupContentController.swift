//
//  PBUIKitPopupContentController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 11/10/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import UIKit

class PBUIKitPopupContentController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "UIKit Popup Content Controller"
        label.font = .preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(label)
        NSLayoutConstraint.activate([
            self.view.centerXAnchor.constraint(equalTo: label.centerXAnchor),
            self.view.centerYAnchor.constraint(equalTo: label.centerYAnchor),
        ])
    }
}
