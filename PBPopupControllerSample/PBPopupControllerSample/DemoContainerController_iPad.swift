//
//  DemoContainerController_iPad.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 10/02/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class DemoContainerController_iPad: UIViewController, PBPopupControllerDataSource {

    @IBOutlet weak var tabBar: UIToolbar!
    @IBOutlet weak var bottomDockingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let vc = UIStoryboard(name: "Custom", bundle: nil).instantiateViewController(withIdentifier: "DemoChildViewController_iPad") as? DemoChildViewController_iPad {
            vc.containerController = self
            let nc = UINavigationController(rootViewController: vc)
            addChild(nc)
            self.view.addSubview(nc.view)
            self.view.sendSubviewToBack(nc.view)
            self.setupConstraintsForContainerView(nc.view)
            nc.didMove(toParent: self)
            self.commonSetup()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        #if !targetEnvironment(macCatalyst)
        let orientation = self.statusBarOrientation(for: self.view)
        self.popupContentView.popupContentSize = CGSize(width: -1, height: UIScreen.main.bounds.height * ((orientation == .portrait || orientation == .portraitUpsideDown) ? 2/3 : 9/10))
        #else
        self.popupContentView.popupContentSize = CGSize(width: -1, height: self.view.bounds.height * 9/10)
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.presentPopup()
    }
    
    deinit {
        PBLog("deinit \(self)")
    }
    
    func commonSetup() {
        self.popupController.wantsAdditionalSafeAreaInsetBottom = false
        self.popupController.dataSource = self
        self.popupContentView.popupPresentationStyle = .custom
        self.popupBar.inheritsVisualStyleFromBottomBar = false
        self.popupBar.barStyle = self.tabBar.barStyle
        self.popupBar.barTintColor = self.tabBar.barTintColor
        self.popupBar.isTranslucent = self.tabBar.isTranslucent
        self.popupBar.shadowImageView.shadowOpacity = 0
        self.popupBar.borderViewStyle = .left
    }
    
    func statusBarOrientation(for view: UIView) -> UIInterfaceOrientation {
        var statusBarOrientation: UIInterfaceOrientation = .unknown
        #if !targetEnvironment(macCatalyst)
        if #available(iOS 13.0, *) {
            statusBarOrientation = view.window?.windowScene?.interfaceOrientation ?? .unknown
        } else {
            statusBarOrientation = UIApplication.shared.statusBarOrientation
        }
        #else
        statusBarOrientation = view.window?.windowScene?.interfaceOrientation ?? .unknown
        #endif
        
        return statusBarOrientation
    }
    
    func presentPopup() {
        let popupContentController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupContentViewController") as! PopupContentViewController
        popupContentController.albumArtImage = self.popupBar.image!
        popupContentController.songTitle = self.popupBar.title!
        popupContentController.albumTitle = self.popupBar.subtitle!

        DispatchQueue.main.async {
            self.presentPopupBar(withPopupContentViewController: popupContentController, animated: true) {
                PBLog("Popup Bar Presented")
            }
        }
    }
    
    func dismissPopup() {
        self.dismissPopupBar(animated: true) {
            PBLog("Popup Bar Dismissed")
        }
    }

    func setupConstraintsForContainerView(_ containerView: UIView) {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo:self.view.topAnchor, constant: 0),
            containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
    }

    // MARK: - PBPopupController dataSource
    
    func bottomBarView(for popupController: PBPopupController) -> UIView? {
        return self.bottomDockingView
    }
    
    func popupController(_ popupController: PBPopupController, defaultFrameFor bottomBarView: UIView) -> CGRect {
        return self.bottomDockingView.frame
    }
    
    func popupController(_ popupController: PBPopupController, insetsFor bottomBarView: UIView) -> UIEdgeInsets {
        var insets: UIEdgeInsets = .zero
        insets = self.view.superview?.safeAreaInsets ?? .zero
        //PBLog(insets.bottom, error: true)
        return insets
    }
}
