//
//  PBPopupUICustomBarViewController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 11/10/2020.
//  Copyright © 2020-2022 Patrick BODET. All rights reserved.
//

import SwiftUI
import UIKit

internal class PBPopupUICustomBarViewController : UIViewController {
    fileprivate let hostingChild: UIHostingController<AnyView>
    
    func setAnyView(_ anyView: AnyView) {
        hostingChild.rootView = anyView
        
        hostingChild.view.layoutIfNeeded()
        
        self.updatePreferredContentSize()
    }
    
    required init(anyView: AnyView) {
        hostingChild = UIHostingController(rootView: anyView)
        
        super.init(nibName: nil, bundle: nil)
        
        addChild(hostingChild)
        hostingChild.view.backgroundColor = nil
        hostingChild.view.autoresizingMask = [.flexibleWidth]
        var frame = view.bounds
        frame.size.height = hostingChild.sizeThatFits(in: CGSize.zero).height
        hostingChild.view.frame = frame
        view.addSubview(hostingChild.view)
        hostingChild.didMove(toParent: self)
        
        hostingChild.view.layoutIfNeeded()

        self.updatePreferredContentSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.preservesSuperviewLayoutMargins = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.updatePreferredContentSize()
    }
    
    fileprivate func updatePreferredContentSize() {
        var size = CGSize.zero
        size.width = hostingChild.view.frame.size.width
        self.preferredContentSize = hostingChild.sizeThatFits(in: size)
    }
}
