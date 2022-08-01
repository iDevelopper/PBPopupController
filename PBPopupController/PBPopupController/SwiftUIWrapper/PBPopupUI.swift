//
//  PBPopupUI.swift
//  PBPopupController
//
//  Created by Patrick BODET on 06/10/2020.
//  Copyright © 2020-2022 Patrick BODET. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
public class RoundShadowImageView: PBPopupRoundShadowImageView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let popupContentView = self.popupContentView {
            popupContentView.popupImageModule = self
            popupContentView.popupImageView = self.imageView
        }
    }
}

@available(iOS 14.0, *)
public struct RoundShadowImage: UIViewRepresentable {
    var image: UIImage!
    var cornerRadius: CGFloat
    var shadowColor: UIColor
    var shadowOffset: CGSize
    var shadowOpacity: Float
    var shadowRadius: CGFloat
    
    public init(image: UIImage, cornerRadius: CGFloat = 3.0, shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 0.0, height: 3.0), shadowOpacity: Float = 0.5, shadowRadius: CGFloat = 3.0) {
        self.image = image
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
    }
    
    public func makeUIView(context: Context) -> RoundShadowImageView {
        return RoundShadowImageView()
    }
    
    public func updateUIView(_ uiView: RoundShadowImageView, context: Context) {
        uiView.image = image
        uiView.cornerRadius = cornerRadius
        uiView.shadowColor = shadowColor
        uiView.shadowOffset = shadowOffset
        uiView.shadowOpacity = shadowOpacity
        uiView.shadowRadius = shadowRadius
    }
    
    public typealias UIViewType = RoundShadowImageView
}

@available(iOS 14.0, *)
public extension RoundShadowImage {
    func cornerRadius(_ cornerRadius: CGFloat) -> RoundShadowImage {
        var view = self
        view.cornerRadius = cornerRadius
        return view
    }

    func shadowColor(_ shadowColor: UIColor) -> RoundShadowImage {
        var view = self
        view.shadowColor = shadowColor
        return view
    }
    
    func shadowOffset(_ shadowOffset: CGSize) -> RoundShadowImage {
        var view = self
        view.shadowOffset = shadowOffset
        return view
    }
    
    func shadowOpacity(_ shadowOpacity: Float) -> RoundShadowImage {
        var view = self
        view.shadowOpacity = shadowOpacity
        return view
    }

    func shadowRadius(_ shadowRadius: CGFloat) -> RoundShadowImage {
        var view = self
        view.shadowRadius = shadowRadius
        return view
    }
}

@available(iOS 14.0, *)
public extension View {
    func popup<PopupContent>(isPresented: Binding<Bool>, isOpen: Binding<Bool>? = nil, isHidden: Binding<Bool>? = nil, onPresent: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil, onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil, @ViewBuilder popupContent: @escaping () -> PopupContent) -> some View where PopupContent : View {
        return PBPopupViewWrapper<Self, PopupContent>(isPresented: isPresented, isOpen: isOpen ?? Binding.constant(false), isHidden: isHidden ?? Binding.constant(false), onPresent: onPresent, onDismiss: onDismiss, onOpen: onOpen, onClose: onClose, popupContent: popupContent) {
            self
        }.edgesIgnoringSafeArea(.all)
    }
    
    func popup(isPresented: Binding<Bool>, isOpen: Binding<Bool>? = nil, isHidden: Binding<Bool>? = nil, onPresent: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil, onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil, popupContentController: UIViewController) -> some View {
        return PBPopupViewWrapper<Self, EmptyView>(isPresented: isPresented, isOpen: isOpen ?? Binding.constant(false), isHidden: isHidden ?? Binding.constant(false), onPresent: onPresent, onDismiss: onDismiss, onOpen: onOpen, onClose: onClose, popupContentController: popupContentController) {
            self
        }.edgesIgnoringSafeArea(.all)
    }
    
    func popupCloseButtonStyle(_ style: PBPopupCloseButtonStyle) -> some View {
        return environment(\.popupCloseButtonStyle, style)
    }
    
    func popupBarStyle(_ style: PBPopupBarStyle) -> some View {
        return environment(\.popupBarStyle, style)
    }
    
    func popupBarProgressViewStyle(_ style: PBPopupBarProgressViewStyle) -> some View {
        return environment(\.popupBarProgressViewStyle, style)
    }
    
    func popupBarBorderViewStyle(_ style: PBPopupBarBorderViewStyle) -> some View {
        return environment(\.popupBarBorderViewStyle, style)
    }
    
    func popupPresentationStyle(_ style: PBPopupPresentationStyle) -> some View {
        return environment(\.popupPresentationStyle, style)
    }
    
    func popupPresentationDuration(_ duration: TimeInterval) -> some View {
        return environment(\.popupPresentationDuration, duration)
    }
    
    func popupDismissalDuration(_ duration: TimeInterval) -> some View {
        return environment(\.popupDismissalDuration, duration)
    }
    
    func popupCompletionThreshold(_ threshold: CGFloat) -> some View {
        return environment(\.popupCompletionThreshold, threshold)
    }
    
    func popupContentSize(_ size: CGSize) -> some View {
        return environment(\.popupContentSize, size)
    }

    func popupIgnoreDropShadowView(_ ignore: Bool) -> some View {
        return environment(\.popupIgnoreDropShadowView, ignore)
    }
}

@available(iOS 14.0, *)
public extension View {
    func popupBarCustomView<PopupBarContent>(@ViewBuilder popupBarContent: @escaping () -> PopupBarContent) -> some View where PopupBarContent : View {
        return environment(\.popupBarCustomBarView, PBPopupBarCustomView(popupBarCustomBarView: AnyView(popupBarContent())))
    }
}

@available(iOS 14.0, *)
public extension View {
    func popupTitle<S>(_ localizedTitleKey: S, subtitle localizedSubtitleKey: S? = nil) -> some View where S : StringProtocol {
        let subtitle: String?
        if let localizedSubtitleKey = localizedSubtitleKey {
            subtitle = NSLocalizedString(String(localizedSubtitleKey), comment: "")
        } else {
            subtitle = nil
        }
        
        return popupTitle(verbatim: NSLocalizedString(String(localizedTitleKey), comment: ""), subtitle: subtitle)
    }
    
    func popupTitle<S>(verbatim title: S, subtitle: S? = nil) -> some View where S : StringProtocol {
        return popupTitle(verbatim: String(title), subtitle: subtitle == nil ? nil : String(subtitle!))
    }
    
    func popupTitle(verbatim title: String, subtitle: String? = nil) -> some View {
        return self.preference(key: PBPopupTitlePreferenceKey.self, value: PBPopupTitleData(title: title, subtitle: subtitle))
    }
    
    func popupLabel(_ label: UILabel? = nil, sublabel: UILabel? = nil) -> some View {
        return self.preference(key: PBPopupLabelPreferenceKey.self, value: PBPopupLabelData(label: label, sublabel: sublabel))
    }
    
    func popupRoundShadowImage(_ image: UIImage, cornerRadius: CGFloat = 3.0, shadowColor: UIColor = UIColor.black, shadowOffset: CGSize = CGSize(width: 0.0, height: 3.0), shadowOpacity: Float = 0.5, shadowRadius: CGFloat = 3.0) -> some View {
        return self.preference(key: PBPopupRoundShadowImagePreferenceKey.self, value: PBPopupRoundShadowImageData(image: image, cornerRadius: cornerRadius, shadowColor: shadowColor, shadowOffset: shadowOffset, shadowOpacity: shadowOpacity, shadowRadius: shadowRadius))
    }
    
    func popupImage(_ image: Image) -> some View {
        return self.preference(key: PBPopupImagePreferenceKey.self, value: image)
    }

    func popupProgress(_ progress: Float) -> some View {
        return self.preference(key: PBPopupProgressPreferenceKey.self, value: progress)
    }
    
    func popupBarItems<LeadingContent>(@ViewBuilder leading: () -> LeadingContent) -> some View where LeadingContent: View {
        return self
            .preference(key: PBPopupLeadingBarItemsPreferenceKey.self, value: PBPopupAnyViewWrapper(anyView: AnyView(leading())))
    }
    
    /// Sets the bar button items to display on the popup bar.
    ///
    /// - Parameter trailing: A view that appears on the trailing edge of the popup bar.
    func popupBarItems<TrailingContent>(@ViewBuilder trailing: () -> TrailingContent) -> some View where TrailingContent: View {
        return self
            .preference(key: PBPopupTrailingBarItemsPreferenceKey.self, value: PBPopupAnyViewWrapper(anyView: AnyView(trailing())))
    }
}

