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
    private let willPresent: (() -> Void)?
    private let onPresent: (() -> Void)?
    private let willDismiss: (() -> Void)?
    private let onDismiss: (() -> Void)?
    private let willOpen: (() -> Void)?
    private let onOpen: (() -> Void)?
    private let willClose: (() -> Void)?
    private let onClose: (() -> Void)?
    
    @Environment(\.popupCloseButtonStyle) var popupCloseButtonStyle: PBPopupCloseButtonStyle
    @Environment(\.isFloating) var isFloating: Bool
    @Environment(\.popupBarStyle) var popupBarStyle: PBPopupBarStyle
    @Environment(\.barStyle) var barStyle: UIBarStyle
    @Environment(\.backgroundStyle) var backgroundStyle: UIBlurEffect.Style
    @Environment(\.backgroundEffect) var backgroundEffect: UIBlurEffect?
    @Environment(\.floatingBackgroundEffect) var floatingBackgroundEffect: UIBlurEffect?
    @Environment(\.inheritsVisualStyleFromBottomBar) var inheritsVisualStyleFromBottomBar: Bool
    @Environment(\.isTranslucent) var isTranslucent: Bool
    @Environment(\.backgroundColor) var backgroundColor: UIColor?
    @Environment(\.floatingBackgroundColor) var floatingBackgroundColor: UIColor?
    @Environment(\.tintColor) var tintColor: UIColor?
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
    @Environment(\.popupBarCustomizer) var popupBarCustomizer: ((PBPopupBar) -> Void)?

    init(isPresented: Binding<Bool>, isOpen: Binding<Bool>, isHidden: Binding<Bool>, willPresent: (() -> Void)?, onPresent: (() -> Void)?, willDismiss: (() -> Void)?, onDismiss: (() -> Void)?, willOpen: (() -> Void)?, onOpen: (() -> Void)?, willClose: (() -> Void)?, onClose: (() -> Void)?, popupContent: (() -> PopupContent)? = nil, popupContentController: UIViewController? = nil, @ViewBuilder content: @escaping () -> Content) {
        self._isPresented = isPresented
        self._isOpen = isOpen
        self._isHidden = isHidden
        self.passthroughContent = content
        self.popupContent = popupContent
        self.popupContentController = popupContentController
        self.willPresent = willPresent
        self.onPresent = onPresent
        self.willDismiss = willDismiss
        self.onDismiss = onDismiss
        self.willOpen = willOpen
        self.onOpen = onOpen
        self.willClose = willClose
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
                                 isFloating: isFloating,
                                 popupBarStyle: popupBarStyle,
                                 barStyle: barStyle,
                                 backgroundStyle: backgroundStyle,
                                 backgroundEffect: backgroundEffect,
                                 floatingBackgroundEffect: floatingBackgroundEffect,
                                 inheritsVisualStyleFromBottomBar: inheritsVisualStyleFromBottomBar,
                                 isTranslucent: isTranslucent,
                                 backgroundColor: backgroundColor,
                                 floatingBackgroundColor: floatingBackgroundColor,
                                 tintColor: tintColor,
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
                                 barCustomizer: popupBarCustomizer,
                                 willPresent: willPresent,
                                 onPresent: onPresent,
                                 willDismiss: willDismiss,
                                 onDismiss: onDismiss,
                                 willOpen: willOpen,
                                 onOpen: onOpen,
                                 willClose: willClose,
                                 onClose: onClose)
        
        uiViewController.handlePopupState(state)
    }
}


