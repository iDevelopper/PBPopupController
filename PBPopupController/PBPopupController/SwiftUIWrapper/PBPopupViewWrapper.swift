//
//  PBPopupViewWrapper.swift
//  PBPopupController
//
//  Created by Patrick BODET on 07/10/2020.
//  Copyright © 2020-2022 Patrick BODET. All rights reserved.
//

import SwiftUI
import UIKit

@available(iOS 14.0, *)
internal struct PBPopupViewWrapper<Content, PopupContent>: UIViewControllerRepresentable where Content: View, PopupContent: View {
    @Binding private var isPresented: Bool
    @Binding private var isOpen: Bool
    @Binding private var isHidden: Bool
    private let passthroughContent: () -> Content
    private let popupContent: (() -> PopupContent)?
    private let popupContentController: UIViewController?
    private let onPresent: (() -> Void)?
    private let onDismiss: (() -> Void)?
    private let onOpen: (() -> Void)?
    private let onClose: (() -> Void)?
    
    @Environment(\.popupCloseButtonStyle) var popupCloseButtonStyle: PBPopupCloseButtonStyle
    @Environment(\.popupBarStyle) var popupBarStyle: PBPopupBarStyle
    @Environment(\.barStyle) var barStyle: UIBarStyle
    @Environment(\.backgroundStyle) var backgroundStyle: UIBlurEffect.Style
    @Environment(\.backgroundEffect) var backgroundEffect: UIBlurEffect?
    @Environment(\.inheritsVisualStyleFromBottomBar) var inheritsVisualStyleFromBottomBar: Bool
    @Environment(\.isTranslucent) var isTranslucent: Bool
    @Environment(\.backgroundColor) var backgroundColor: UIColor?
    @Environment(\.barTintColor) var barTintColor: UIColor?
    @Environment(\.popupBarProgressViewStyle) var popupBarProgressViewStyle: PBPopupBarProgressViewStyle
    @Environment(\.popupBarBorderViewStyle) var popupBarBorderViewStyle: PBPopupBarBorderViewStyle
    @Environment(\.popupPresentationStyle) var popupPresentationStyle: PBPopupPresentationStyle
    @Environment(\.popupPresentationDuration) var popupPresentationDuration: TimeInterval
    @Environment(\.popupDismissalDuration) var popupDismissalDuration: TimeInterval
    @Environment(\.popupCompletionThreshold) var popupCompletionThreshold: CGFloat
    @Environment(\.popupCompletionFlickMagnitude) var popupCompletionFlickMagnitude: CGFloat
    @Environment(\.popupContentSize) var popupContentSize: CGSize
    @Environment(\.popupIgnoreDropShadowView) var popupIgnoreDropShadowView: Bool
    @Environment(\.shouldExtendCustomBarUnderSafeArea) var shouldExtendCustomBarUnderSafeArea: Bool
    @Environment(\.popupBarCustomBarView) var popupBarCustomBarView: PBPopupBarCustomView?
    
    init(isPresented: Binding<Bool>, isOpen: Binding<Bool>, isHidden: Binding<Bool>, onPresent: (() -> Void)?, onDismiss: (() -> Void)?, onOpen: (() -> Void)?, onClose: (() -> Void)?, popupContent: (() -> PopupContent)? = nil, popupContentController: UIViewController? = nil, @ViewBuilder content: @escaping () -> Content) {
        self._isPresented = isPresented
        self._isOpen = isOpen
        self._isHidden = isHidden
        self.passthroughContent = content
        self.popupContent = popupContent
        self.popupContentController = popupContentController
        self.onPresent = onPresent
        self.onDismiss = onDismiss
        self.onOpen = onOpen
        self.onClose = onClose
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PBPopupViewWrapper>) -> PBPopupProxyViewController<Content, PopupContent> {
        return PBPopupProxyViewController(rootView: passthroughContent())
    }
    
    func updateUIViewController(_ uiViewController: PBPopupProxyViewController<Content, PopupContent>, context: UIViewControllerRepresentableContext<PBPopupViewWrapper>) {
        
        uiViewController.rootView = passthroughContent()
        
        let state = PBPopupState(isPresented: _isPresented,
                                 isOpen: _isOpen,
                                 isHidden: _isHidden,
                                 closeButtonStyle: popupCloseButtonStyle,
                                 popupBarStyle: popupBarStyle,
                                 barStyle: barStyle,
                                 backgroundStyle: backgroundStyle,
                                 backgroundEffect: backgroundEffect,
                                 inheritsVisualStyleFromBottomBar: inheritsVisualStyleFromBottomBar,
                                 isTranslucent: isTranslucent,
                                 backgroundColor: backgroundColor,
                                 barTintColor: barTintColor,
                                 progressViewStyle: popupBarProgressViewStyle,
                                 borderViewStyle: popupBarBorderViewStyle,
                                 shouldExtendCustomBarUnderSafeArea: shouldExtendCustomBarUnderSafeArea,
                                 customBarView: popupBarCustomBarView,
                                 popupPresentationStyle: popupPresentationStyle,
                                 popupPresentationDuration: popupPresentationDuration,
                                 popupDismissalDuration: popupDismissalDuration,
                                 popupCompletionThreshold: popupCompletionThreshold,
                                 popupCompletionFlickMagnitude: popupCompletionFlickMagnitude,
                                 popupContentSize: popupContentSize,
                                 popupIgnoreDropShadowView: popupIgnoreDropShadowView,
                                 popupContent: popupContent,
                                 popupContentViewController: popupContentController,
                                 onPresent: onPresent,
                                 onDismiss: onDismiss,
                                 onOpen: onOpen,
                                 onClose: onClose)
        
        uiViewController.handlePopupState(state)
    }
}


