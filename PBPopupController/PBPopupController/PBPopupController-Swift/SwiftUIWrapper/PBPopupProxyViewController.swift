//
//  PBPopupProxyViewController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 06/10/2020.
//  Copyright © 2020-2022 Patrick BODET. All rights reserved.
//

import UIKit
import SwiftUI

@available(iOS 14.0, *)
internal class PBPopupImageViewController<Content>: UIHostingController<Content> where Content: View {
    @objc dynamic var cornerRadius: CGFloat = 0.0
    @objc dynamic var shadowColor: UIColor = UIColor.black
    @objc dynamic var shadowOffset: CGSize = .zero
    @objc dynamic var shadowOpacity: Float = 0.0
    @objc dynamic var shadowRadius: CGFloat = 0.0
    
    init(rootView: Content, cornerRadius: CGFloat = 0.0, shadowColor: UIColor = UIColor.black, shadowOffset: CGSize = .zero, shadowOpacity: Float = 0.0, shadowRadius: CGFloat = 0.0) {
        super.init(rootView: rootView)
        
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 14.0, *)
internal class PBPopupProxyViewController<Content, PopupContent> : UIHostingController<Content>, PBPopupControllerDelegate, PBPopupBarDataSource where Content: View, PopupContent: View {
    
    var currentPopupState: PBPopupState<PopupContent>! = nil
    var popupViewController: UIViewController?
    
    var popupImageViewController: UIHostingController<AnyView>? = nil
    var leadingBarItemsController: UIHostingController<AnyView>? = nil
    var trailingBarItemsController: UIHostingController<AnyView>? = nil
    var leadingBarButtonItem: UIBarButtonItem? = nil
    var trailingBarButtonItem: UIBarButtonItem? = nil
    
    var readyForHandling = false {
        didSet {
            if let waitingStateHandle = waitingStateHandle {
                self.waitingStateHandle = nil
                waitingStateHandle(false)
            }
        }
    }
    var waitingStateHandle: ((Bool) -> Void)?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        readyForHandling = true
    }
    
    override func addChild(_ childController: UIViewController) {
        //print("Child: \(childController)")
        super.addChild(childController)
        
        //readyForHandling = true
    }
    
    fileprivate var target: UIViewController {
        //print("self.children: \(self.children)")
        return children.first ?? self
    }
    
    fileprivate func createOrUpdateHostingControllerForAnyView(_ vc: inout UIHostingController<AnyView>?, view: AnyView, barButtonItem: inout UIBarButtonItem?, targetBarButtons: ([UIBarButtonItem]) -> Void, leadSpacing: Bool, trailingSpacing: Bool) {
        if let vc = vc {
            vc.rootView = view
            vc.view.removeConstraints(vc.view.constraints)
            vc.view.setNeedsLayout()
            let size = vc.sizeThatFits(in: CGSize(width: .max, height: .max))
            NSLayoutConstraint.activate([
                vc.view.widthAnchor.constraint(equalToConstant: size.width),
                vc.view.heightAnchor.constraint(equalToConstant: size.height),
            ])
            
            barButtonItem!.customView = vc.view
        } else {
            vc = UIHostingController<AnyView>(rootView: view)
            vc!.view.backgroundColor = .clear
            vc!.view.translatesAutoresizingMaskIntoConstraints = false
            let size = vc!.sizeThatFits(in: CGSize(width: .max, height: .max))
            NSLayoutConstraint.activate([
                vc!.view.widthAnchor.constraint(equalToConstant: size.width),
                vc!.view.heightAnchor.constraint(equalToConstant: size.height),
            ])
            
            barButtonItem = UIBarButtonItem(customView: vc!.view)
            
            targetBarButtons([barButtonItem!])
        }
    }
    
    fileprivate func cast<T>(value: Any, to type: T) -> PBPopupUIContentController<T> where T: View {
        return value as! PBPopupUIContentController<T>
    }
    
    func viewHandler(_ state: PBPopupState<PopupContent>) -> (() -> Void) {
        let view = {
            return self.currentPopupState.popupContent!()
                .onPreferenceChange(PBPopupTitlePreferenceKey.self) { [weak self] titleData in
                    self?.target.popupBar.title = titleData?.title
                    self?.target.popupBar.subtitle = titleData?.subtitle
                }
                .onPreferenceChange(PBPopupLabelPreferenceKey.self) { [weak self] labelData in
                    if self?.target.popupBar.dataSource == nil {
                        self?.target.popupBar.dataSource = self
                    }
                    if self?.target.popupBar.titleLabel == nil {
                        if let label = labelData?.label {
                            self?.target.popupBar.titleLabel = label
                        }
                    }
                    if self?.target.popupBar.subtitleLabel == nil {
                        if let sublabel = labelData?.sublabel {
                            self?.target.popupBar.subtitleLabel = sublabel
                        }
                    }
                }
                .onPreferenceChange(PBPopupRoundShadowImagePreferenceKey.self) { [weak self] imageData in
                    if let imageData = imageData {
                        self?.target.popupBar.image = imageData.image
                        self?.target.popupBar.shadowImageView.cornerRadius = imageData.cornerRadius
                        self?.target.popupBar.shadowImageView.shadowColor = imageData.shadowColor
                        self?.target.popupBar.shadowImageView.shadowOffset = imageData.shadowOffset
                        self?.target.popupBar.shadowImageView.shadowOpacity = imageData.shadowOpacity
                        self?.target.popupBar.shadowImageView.shadowRadius = imageData.shadowRadius
                    }
                }
                .onPreferenceChange(PBPopupImagePreferenceKey.self) { [weak self] image in
                    //print("Image: \(String(describing: image))")
                    if image != nil {
                        if let imageController = self?.target.popupBar.swiftUIImageController as? UIHostingController<Image?> {
                            imageController.rootView = image
                        } else {
                            self?.target.popupBar.swiftUIImageController = PBPopupImageViewController(rootView: image)
                        }
                    }
                }
                .onPreferenceChange(PBPopupProgressPreferenceKey.self) { [weak self] progress in
                    self?.target.popupBar.progress = progress ?? 0.0
                }
                .onPreferenceChange(PBPopupLeadingBarItemsPreferenceKey.self) { [weak self] view in
                    if let self = self, let anyView = view?.anyView, let popupBar = self.target.popupBar {
                        self.createOrUpdateHostingControllerForAnyView(&self.leadingBarItemsController, view: anyView, barButtonItem: &self.leadingBarButtonItem, targetBarButtons: { popupBar.leftBarButtonItems = $0 }, leadSpacing: false, trailingSpacing: false)
                    }
                }
                .onPreferenceChange(PBPopupTrailingBarItemsPreferenceKey.self) { [weak self] view in
                    if let self = self, let anyView = view?.anyView, let popupBar = self.target.popupBar {
                        self.createOrUpdateHostingControllerForAnyView(&self.trailingBarItemsController, view: anyView, barButtonItem: &self.trailingBarButtonItem, targetBarButtons: { popupBar.rightBarButtonItems = $0 }, leadSpacing: false, trailingSpacing: false)
                    }
                }
        }()
        return {
            if self.popupViewController == nil {
                self.popupViewController = PBPopupUIContentController(rootView: view)
            } else {
                self.cast(value: self.popupViewController!, to: view.self).rootView = view
            }
        }
    }
    
    func viewControllerHandler(_ state: PBPopupState<PopupContent>) -> (() -> Void) {
        let viewController = state.popupContentViewController!
        
        return {
            self.popupViewController = viewController
        }
    }
    
    func handlePopupState(_ state: PBPopupState<PopupContent>) {
        currentPopupState = state
        
        let popupContentHandler = state.popupContent != nil ? viewHandler(state) : viewControllerHandler(state)
        
        let handler : (Bool) -> Void = { animated in
            if self.target.popupBar.popupBarStyle != .custom {
                self.target.popupBar.popupBarStyle = self.currentPopupState.popupBarStyle
            }
            self.target.popupBar.barStyle = self.currentPopupState.barStyle
            self.target.popupBar.backgroundStyle = self.currentPopupState.backgroundStyle
            self.target.popupBar.inheritsVisualStyleFromBottomBar = self.currentPopupState.inheritsVisualStyleFromBottomBar
            self.target.popupBar.isTranslucent = self.currentPopupState.isTranslucent
            self.target.popupBar.backgroundColor = self.currentPopupState.backgroundColor
            //self.target.popupBar.barTintColor = self.currentPopupState.barTintColor
            self.target.popupBar.tintColor = self.currentPopupState.tintColor
            self.target.popupBar.progressViewStyle = self.currentPopupState.progressViewStyle
            self.target.popupBar.borderViewStyle = self.currentPopupState.borderViewStyle
            self.target.popupContentView.popupCloseButtonStyle = self.currentPopupState.closeButtonStyle
            self.target.popupContentView.popupPresentationStyle = self.currentPopupState.popupPresentationStyle
            self.target.popupContentView.popupPresentationDuration = self.currentPopupState.popupPresentationDuration
            self.target.popupContentView.popupDismissalDuration = self.currentPopupState.popupDismissalDuration
            self.target.popupContentView.popupCompletionThreshold = self.currentPopupState.popupCompletionThreshold
            self.target.popupContentView.popupCompletionFlickMagnitude = self.currentPopupState.popupCompletionFlickMagnitude
            self.target.popupContentView.popupContentSize = self.currentPopupState.popupContentSize
            self.target.popupContentView.popupIgnoreDropShadowView = self.currentPopupState.popupIgnoreDropShadowView
            self.target.popupBar.shouldExtendCustomBarUnderSafeArea = self.currentPopupState.shouldExtendCustomBarUnderSafeArea
            if let customBarView = self.currentPopupState.customBarView {
                let rv: PBPopupUICustomBarViewController
                if let customController = self.target.popupBar.customPopupBarViewController as? PBPopupUICustomBarViewController {
                    rv = customController
                    rv.setAnyView(customBarView.popupBarCustomBarView)
                    self.target.popupBar.backgroundEffect = self.currentPopupState.backgroundEffect
                } else {
                    rv = PBPopupUICustomBarViewController(anyView: customBarView.popupBarCustomBarView)
                    self.target.popupBar.customPopupBarViewController = rv
                }
            } else {
                self.target.popupBar.customPopupBarViewController = nil
                self.target.popupBar.popupBarStyle = self.currentPopupState.popupBarStyle
            }
            
            self.currentPopupState.barCustomizer?(self.target.popupBar)

            self.target.popupController.delegate = self
            
            if self.currentPopupState.isPresented == true {
                popupContentHandler()
                
                let presentationState = self.target.popupController.popupPresentationState
                if presentationState == .hidden || presentationState == .dismissed {
                    self.target.presentPopupBar(withPopupContentViewController: self.popupViewController, openPopup: self.currentPopupState.isOpen, animated: animated, completion: nil)
                }
                else {
                    if self.currentPopupState.isOpen == true {
                        self.target.openPopup(animated: true, completion: nil)
                    }
                    else {
                        self.target.closePopup(animated: true, completion: nil)
                    }
                    if self.currentPopupState.isHidden == true {
                        if !self.target.popupBarIsHidden {
                            self.target.hidePopupBar(animated: true)
                        }
                    }
                    else {
                        if self.target.popupBarIsHidden {
                            self.target.showPopupBar(animated: true)
                        }
                    }
                }
            } else {
                print("state: \(self.target.popupController.popupPresentationState.description)")
                self.target.dismissPopupBar(animated: animated, completion: nil)
            }
        }
        if readyForHandling {
            handler(true)
        } else {
            waitingStateHandle = handler
        }
    }
    
    //MARK: PBPopupBarDatasource
    
    func titleLabel(for popupBar: PBPopupBar) -> UILabel? {
        return popupBar.titleLabel
    }
    
    func subtitleLabel(for popupBar: PBPopupBar) -> UILabel? {
        return popupBar.subtitleLabel
    }
    
    //MARK: PBPopupControllerDelegate
    
    func popupController(_ popupController: PBPopupController, willOpen popupContentViewController: UIViewController) {
        currentPopupState?.willOpen?()
    }
    
    func popupController(_ popupController: PBPopupController, willClose popupContentViewController: UIViewController) {
        currentPopupState?.willClose?()
    }
    
    func popupController(_ popupController: PBPopupController, willDismiss popupBar: PBPopupBar) {
        currentPopupState?.willDismiss?()
    }
    
    func popupController(_ popupController: PBPopupController, willPresent popupBar: PBPopupBar) {
        currentPopupState?.willPresent?()
    }
    
    func popupController(_ popupController: PBPopupController, didPresent popupBar: PBPopupBar) {
        currentPopupState?.isPresented = true
        
        currentPopupState?.onPresent?()
    }
    
    func popupController(_ popupController: PBPopupController, didDismiss popupBar: PBPopupBar) {
        currentPopupState?.isPresented = false
        
        currentPopupState?.onDismiss?()
    }
    
    func popupController(_ popupController: PBPopupController, didOpen popupContentViewController: UIViewController) {
        currentPopupState?.isOpen = true
        
        currentPopupState?.onOpen?()
    }
    
    func popupController(_ popupController: PBPopupController, didClose popupContentViewController: UIViewController) {
        currentPopupState?.isOpen = false
        
        currentPopupState?.onClose?()
    }
    
    func popupControllerPanGestureShouldBegin(_ popupController: PBPopupController, state: PBPopupPresentationState) -> Bool {
        return currentPopupState?.checkPopupControllerPanGestureShouldBegin?(popupController, state) ?? true;
    }
}
