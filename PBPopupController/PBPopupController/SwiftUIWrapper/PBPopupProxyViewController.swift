//
//  PBPopupProxyViewController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 06/10/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import UIKit
import SwiftUI

@available(iOS 13.0, *)
internal class PBPopupProxyViewController<Content, PopupContent> : UIHostingController<Content>, PBPopupControllerDelegate, PBPopupBarDataSource where Content: View, PopupContent: View {
    
    var currentPopupState: PBPopupState<PopupContent>! = nil
    var popupViewController: UIViewController?
    
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
            /*return */self.currentPopupState.popupContent!()
                .onPreferenceChange(PBPopupTitlePreferenceKey.self) { [weak self] titleData in
                    self?.target.popupBar.title = titleData?.title
                    self?.target.popupBar.subtitle = titleData?.subtitle
                }
                .onPreferenceChange(PBPopupLabelPreferenceKey.self) { [weak self] labelData in
                    if let label = labelData?.label {
                        self?.target.popupBar.titleLabel = label
                    }
                    if let sublabel = labelData?.sublabel {
                        self?.target.popupBar.subtitleLabel = sublabel
                    }
                    self?.target.popupBar.dataSource = self
                }
                .onPreferenceChange(PBPopupImagePreferenceKey.self) { [weak self] image in
                    if image != nil {
                        if let imageController = self?.target.popupBar.swiftImageController as? UIHostingController<Image?> {
                            imageController.rootView = image
                        } else {
                            self?.target.popupBar.swiftImageController = UIHostingController(rootView: image)
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
            self.target.popupContentView.popupCloseButtonStyle = self.currentPopupState.closeButtonStyle
            self.target.popupBar.progressViewStyle = self.currentPopupState.progressViewStyle
            self.target.popupBar.borderViewStyle = self.currentPopupState.borderViewStyle
            self.target.popupContentView.popupPresentationStyle = self.currentPopupState.popupPresentationStyle
            self.target.popupContentView.popupPresentationDuration = self.currentPopupState.popupPresentationDuration
            self.target.popupContentView.popupDismissalDuration = self.currentPopupState.popupDismissalDuration
            self.target.popupContentView.popupCompletionThreshold = self.currentPopupState.popupCompletionThreshold
            self.target.popupContentView.popupCompletionFlickMagnitude = self.currentPopupState.popupCompletionFlickMagnitude
            self.target.popupContentView.popupContentSize = self.currentPopupState.popupContentSize
            
            if let customBarView = self.currentPopupState.customBarView {
                let rv: PBPopupUICustomBarViewController
                if let customController = self.target.popupBar.customPopupBarViewController as? PBPopupUICustomBarViewController {
                    rv = customController
                    rv.setAnyView(customBarView.popupBarCustomBarView)
                } else {
                    rv = PBPopupUICustomBarViewController(anyView: customBarView.popupBarCustomBarView)
                    self.target.popupBar.customPopupBarViewController = rv
                }
            } else {
                self.target.popupBar.customPopupBarViewController = nil
                self.target.popupBar.popupBarStyle = self.currentPopupState.popupBarStyle
            }
            
            self.target.popupController.delegate = self
            
            if self.currentPopupState.isPresented == true {
                popupContentHandler()
                
                //DispatchQueue.main.async {
                    self.target.presentPopupBar(withPopupContentViewController: self.popupViewController, openPopup: self.currentPopupState.isOpen, animated: animated) {
                    //
                    }
                //}
            } else {
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
    
    //MARK: PBPopupControllerDelegate
    
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
}
