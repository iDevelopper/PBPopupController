//
//  NavigationController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 22/06/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class NavigationController: UINavigationController {

    var toolbarIsShown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        PBLog("Deinit: \(self)")
    }
}
