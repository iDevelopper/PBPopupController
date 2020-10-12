//
//  PBPopupUICustomBarViewController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 11/10/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import SwiftUI
import UIKit

@available(iOS 13.0, *)
internal class PBPopupUICustomBarViewController : UIViewController {
    fileprivate let hostingChild: UIHostingController<AnyView>
    
    func setAnyView(_ anyView: AnyView) {
        hostingChild.rootView = anyView
        
        hostingChild.view.layoutIfNeeded()
        self.preferredContentSize = hostingChild.sizeThatFits(in: CGSize.zero)
    }
    
    required init(anyView: AnyView) {
        hostingChild = UIHostingController(rootView: anyView)
        
        super.init(nibName: nil, bundle: nil)
        
        addChild(hostingChild)
        hostingChild.view.backgroundColor = nil
        hostingChild.view.translatesAutoresizingMaskIntoConstraints = true
        hostingChild.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingChild.view.frame = view.bounds
        view.addSubview(hostingChild.view)
        hostingChild.didMove(toParent: self)
        
        hostingChild.view.layoutIfNeeded()
        self.preferredContentSize = hostingChild.sizeThatFits(in: CGSize.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
