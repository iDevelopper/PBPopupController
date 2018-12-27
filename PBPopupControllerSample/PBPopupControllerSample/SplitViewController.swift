//
//  SplitViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 08/11/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {

    var masterIsContainer: Bool = false
    var globalIsContainer: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = .automatic
    }
}
