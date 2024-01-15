//
//  PBPopupUIContentController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 07/10/2020.
//  Copyright © 2020-2022 Patrick BODET. All rights reserved.
//

import SwiftUI
import UIKit

@available(iOS 14.0, *)
//internal class PBPopupUIContentController<Content> : UIHostingController<Content> where Content: View {
internal class PBPopupUIContentController: UIViewController {

    fileprivate let hostingChild: UIHostingController<AnyView>
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        guard let containerVC = self.popupContainerViewController else {return.default}
        guard let popupContentView = containerVC.popupContentView else {return .default}
        
        if popupContentView.popupPresentationStyle != .deck {
            return .default
        }
        return containerVC.popupController.popupStatusBarStyle
    }
    
    var backgroundView: UIView?
    @objc dynamic var swiftuiBackgroundView: UIView? {
        set {
            if let backgroundView = backgroundView {
                backgroundView.removeFromSuperview()
            }
            backgroundView = newValue
            if let backgroundView = backgroundView {
                hostingChild.view.backgroundColor = nil
                self.view.insertSubview(backgroundView, at: 0)
                backgroundView.frame = self.view.bounds
            }
            self.view.layoutIfNeeded()
        }
        get {
            return backgroundView
        }
    }
    
    func setAnyView(_ anyView: AnyView) {
        hostingChild.rootView = anyView
        
        hostingChild.view.layoutIfNeeded()
    }
    
    required init(anyView: AnyView) {
        hostingChild = UIHostingController(rootView: anyView)
        
        super.init(nibName: nil, bundle: nil)
        
        addChild(hostingChild)
        view.addSubview(hostingChild.view)
        
        hostingChild.view.translatesAutoresizingMaskIntoConstraints = false
        hostingChild.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
        hostingChild.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
        hostingChild.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
        hostingChild.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true

        hostingChild.didMove(toParent: self)
        
        hostingChild.view.layoutIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}
