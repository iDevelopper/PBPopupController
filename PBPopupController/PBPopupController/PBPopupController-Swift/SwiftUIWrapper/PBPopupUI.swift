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
    /**
     :nodoc:
     */
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
    
    /// Presents a popup bar with popup content.
    /// - Parameters:
    ///   - isPresented: A binding to whether the popup bar is presented.
    ///   - isOpen: A binding to whether the popup is open. (optional)
    ///   - isHidden: A binding to whether the popup is hidden. (optional)
    ///   - onPresent: A closure executed when the popup bar is presented. (optional)
    ///   - onDismiss: A closure executed when the popup bar is dismissed. (optional)
    ///   - onOpen: A closure executed when the popup opens. (optional)
    ///   - onClose: A closure executed when the popup closes. (optional)
    ///   - popupContent: A closure returning the content of the popup.
    /// - Returns: A popup bar view.
    func popup<PopupContent>(isPresented: Binding<Bool>, isOpen: Binding<Bool>? = nil, isHidden: Binding<Bool>? = nil, onPresent: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil, onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil, willPresent: (() -> Void)? = nil, willDismiss: (() -> Void)? = nil, willOpen: (() -> Void)? = nil, willClose: (() -> Void)? = nil, @ViewBuilder popupContent: @escaping () -> PopupContent) -> some View where PopupContent : View {
        return PBPopupViewWrapper<Self, PopupContent>(isPresented: isPresented, isOpen: isOpen ?? Binding.constant(false), isHidden: isHidden ?? Binding.constant(false), onPresent: onPresent, onDismiss: onDismiss, onOpen: onOpen, onClose: onClose, willPresent: willPresent, willDismiss: willDismiss, willOpen: willOpen, willClose: willClose, popupControllerPanGestureShouldBegin: nil, popupContent: popupContent) {
            self
        }.edgesIgnoringSafeArea(.all)
    }
    
    /// Presents a popup bar with UIKit popup content view controller.
    /// - Parameters:
    ///   - isPresented: A binding to whether the popup bar is presented.
    ///   - isOpen: A binding to whether the popup is open. (optional)
    ///   - isHidden: A binding to whether the popup is hidden. (optional)
    ///   - onPresent: A closure executed when the popup bar is presented. (optional)
    ///   - onDismiss: A closure executed when the popup bar is dismissed. (optional)
    ///   - onOpen: A closure executed when the popup opens. (optional)
    ///   - onClose: A closure executed when the popup closes. (optional)
    ///   - popupContentController: A UIKit view controller to use as the popup content controller.
    /// - Returns: A popup bar view.
    func popup(isPresented: Binding<Bool>, isOpen: Binding<Bool>? = nil, isHidden: Binding<Bool>? = nil, onPresent: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil, onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil, willPresent: (() -> Void)? = nil, willDismiss: (() -> Void)? = nil, willOpen: (() -> Void)? = nil, willClose: (() -> Void)? = nil, popupContentController: UIViewController) -> some View {
        return PBPopupViewWrapper<Self, EmptyView>(isPresented: isPresented, isOpen: isOpen ?? Binding.constant(false), isHidden: isHidden ?? Binding.constant(false), onPresent: onPresent, onDismiss: onDismiss, onOpen: onOpen, onClose: onClose, willPresent: willPresent, willDismiss: willDismiss, willOpen: willOpen, willClose: willClose, popupControllerPanGestureShouldBegin: nil, popupContentController: popupContentController) {
            self
        }.edgesIgnoringSafeArea(.all)
    }
    
    /// Sets the popup close button style.
    /// - Parameter style: The popup close button style.
    /// - SeeAlso: `PBPopupCloseButtonStyle`.
    
    func popupCloseButtonStyle(_ style: PBPopupCloseButtonStyle) -> some View {
        return environment(\.popupCloseButtonStyle, style)
    }
    
    /// Sets the popup bar style (see PBPopupBarStyle).
    /// - Parameter style: The popup bar style.
    /// - SeeAlso: `PBPopupBarStyle`.
    func popupBarStyle(_ style: PBPopupBarStyle) -> some View {
        return environment(\.popupBarStyle, style)
    }
    
    /// Sets the bar style of the popup bar toolbar..
    /// - Parameter style: The bar style.
    func barStyle(_ style: UIBarStyle) -> some View {
        return environment(\.barStyle, style)
    }
    
    /// Sets the popup bar background style that specifies its visual effect appearance.
    /// - Parameter style: The blur style of the effect.
    func backgroundStyle(_ style: UIBlurEffect.Style) -> some View {
        return environment(\.backgroundStyle, style)
    }
    
    /// Sets the custom popup bar's background effect. Use `nil` to use the most appropriate background style for the environment.
    /// - Parameter effect: The popup bar's background effect.
    func backgroundEffect(_ effect: UIBlurEffect) -> some View {
        return environment(\.backgroundEffect, effect)
    }
    
    /// If `true`, the popup bar will automatically inherit its style from the bottom bar.
    /// - Parameter inherits: inherit style from the bottom bar.
    func inheritsVisualStyleFromBottomBar(_ inherits: Bool) -> some View {
        return environment(\.inheritsVisualStyleFromBottomBar, inherits)
    }
    
    /// A Boolean value that indicates whether the popup bar is translucent.
    func isTranslucent(_ translucent: Bool) -> some View {
        return environment(\.isTranslucent, translucent)
    }

    /// The background color of the popup bar toolbar.
    func backgroundColor(_ color: UIColor) -> some View {
        return environment(\.backgroundColor, color)
    }
    
    /// The bar tint color of the popup bar toolbar.
    //func barTintColor(_ color: UIColor) -> some View {
    //    return environment(\.barTintColor, color)
    //}
    
    /// The tint color of the popup bar toolbar.
    func tintColor(_ color: UIColor) -> some View {
        return environment(\.tintColor, color)
    }
    
    /// Sets the popup bar's progress view style.
    /// - Parameter style: the popup bar's progress view style.
    /// - SeeAlso: `PBPopupBarProgressViewStyle`.
    func popupBarProgressViewStyle(_ style: PBPopupBarProgressViewStyle) -> some View {
        return environment(\.popupBarProgressViewStyle, style)
    }
    
    /// Sets the popup bar's border view style.
    /// Usefull for iPad when the popup bar is the neighbour of another object.
    /// - Parameter style: The popup bar's border view style.
    /// - SeeAlso: `PBPopupBarBorderViewStyle`.
    func popupBarBorderViewStyle(_ style: PBPopupBarBorderViewStyle) -> some View {
        return environment(\.popupBarBorderViewStyle, style)
    }
    
    /// Sets the popup content view presentation style.
    /// Default presentation style is deck, was fullScreen for iOS 9 and above, otherwise deck.
    /// - Parameter style: The popup content view presentation style.
    /// - SeeAlso: `PBPopupPresentationStyle`.
    func popupPresentationStyle(_ style: PBPopupPresentationStyle) -> some View {
        return environment(\.popupPresentationStyle, style)
    }
    
    /// The popup content view presentation duration when presenting from closed to open state.
    /// - Parameter duration: The total duration of the animations, measured in seconds.
    func popupPresentationDuration(_ duration: TimeInterval) -> some View {
        return environment(\.popupPresentationDuration, duration)
    }
    
    /// The popup content view dismissal duration when dismissing from open to closed state.
    /// - Parameter duration: The total duration of the animations, measured in seconds.
    func popupDismissalDuration(_ duration: TimeInterval) -> some View {
        return environment(\.popupDismissalDuration, duration)
    }
    
    /// The threshold value used to open or close the popup content view when dragging ends.
    /// - Parameter threshold: The amount of progress.
    func popupCompletionThreshold(_ threshold: CGFloat) -> some View {
        return environment(\.popupCompletionThreshold, threshold)
    }
    
    /// The popup content view size when popupPresentationStyle is set to custom.
    /// - Parameter size: The popup content view size.
    func popupContentSize(_ size: CGSize) -> some View {
        return environment(\.popupContentSize, size)
    }
    
    /// If `true`, tells the popup content view presentation to ignore the form sheet presentation by default.
    /// - Parameter ignore: Default is `true`.
    func popupIgnoreDropShadowView(_ ignore: Bool) -> some View {
        return environment(\.popupIgnoreDropShadowView, ignore)
    }
    
    /// Set this property to `true` if you want the custom popup bar extend under the safe area, to the bottom of the screen.
    ///  When a popup bar is presented on a view controller with the system bottom docking view, or a navigation controller with hidden toolbar, the popup bar's background view will extend under the safe area.
    /// - Parameter should: Extend the popup bar under safe area.
    func shouldExtendCustomBarUnderSafeArea(_ should: Bool) -> some View {
        return environment(\.shouldExtendCustomBarUnderSafeArea, should)
    }
    
    /// Sets a custom popup bar view, instead of the default system-provided bars.
    /// - Parameter popupBarContent: A closure returning the content of the popup bar custom view.
    func popupBarCustomView<PopupBarContent>(@ViewBuilder popupBarContent: @escaping () -> PopupBarContent) -> some View where PopupBarContent : View {
        return environment(\.popupBarCustomBarView, PBPopupBarCustomView(popupBarCustomBarView: AnyView(popupBarContent())))
    }
    
    /// Gives a low-level access to the `PBPopupBar` object for customization, beyond what is exposed by LNPopupUI.
    ///
    ///    The popup bar customization closure is called after all other popup bar modifiers have been applied.
    ///
    /// - Parameters:
    ///   - customizer: A customizing closure that is called to customize the popup bar object.
    ///   - popupBar: The popup bar to customize.
    func popupBarCustomizer(_ customizer: @escaping (_ popupBar: PBPopupBar) -> Void) -> some View {
        return environment(\.popupBarCustomizer, customizer)
    }
}

@available(iOS 14.0, *)
public extension View {
    
    /// Configures the view's popup bar title and subtitle.
    /// - Parameters:
    ///   - localizedTitleKey: The localized title key to display.
    ///   - localizedSubtitleKey: The localized subtitle key to display. Defaults to `nil`.
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
    
    /// Configures the view's popup bar with custom label and sublabel.
    /// - Parameters:
    ///   - label: A `UIlabel` object to be used instead of the default one.
    ///   - sublabel: A `UIlabel` object to be used instead of the default one.
    func popupLabel(_ label: UILabel? = nil, sublabel: UILabel? = nil) -> some View {
        return self.preference(key: PBPopupLabelPreferenceKey.self, value: PBPopupLabelData(label: label, sublabel: sublabel))
    }
    
    /// Configures the view's popup bar image.
    /// - Parameters:
    ///   - image: The image to use.
    ///   - cornerRadius: The radius to use when drawing rounded corners for the image.
    ///   - shadowColor: The color to use for the shadow.
    ///   - shadowOffset: The offset (in points) of the layer’s shadow.
    ///   - shadowOpacity: The opacity of the layer’s shadow.
    ///   - shadowRadius: The blur radius (in points) used to render the layer’s shadow.
    func popupRoundShadowImage(_ image: UIImage, cornerRadius: CGFloat = 3.0, shadowColor: UIColor = UIColor.black, shadowOffset: CGSize = CGSize(width: 0.0, height: 3.0), shadowOpacity: Float = 0.5, shadowRadius: CGFloat = 3.0) -> some View {
        return self.preference(key: PBPopupRoundShadowImagePreferenceKey.self, value: PBPopupRoundShadowImageData(image: image, cornerRadius: cornerRadius, shadowColor: shadowColor, shadowOffset: shadowOffset, shadowOpacity: shadowOpacity, shadowRadius: shadowRadius))
    }
    
    /// Configures the view's popup bar image.
    /// - Parameter image: The image to use.
    func popupImage(_ image: Image) -> some View {
        return self.preference(key: PBPopupImagePreferenceKey.self, value: image)
    }
    
    /// Configures the view's popup bar progress.
    /// The progress is represented by a floating-point value between 0.0 and 1.0, inclusive, where 1.0 indicates the completion of the task. The default value is 0.0. Values less than 0.0 and greater than 1.0 are pinned to those limits.
    /// - Parameter progress: The popup bar progress.
    func popupProgress(_ progress: Float) -> some View {
        return self.preference(key: PBPopupProgressPreferenceKey.self, value: progress)
    }
    
    /// Sets the bar button items to display on the popup bar.
    /// - Parameter leading: A view that appears on the leading edge of the popup bar.
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

