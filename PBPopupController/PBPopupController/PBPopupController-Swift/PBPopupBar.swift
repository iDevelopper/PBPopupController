//
//  PBPopupBar.swift
//  PBPopupController
//
//  Created by Patrick BODET on 29/03/2018.
//  Copyright © 2018-2023 Patrick BODET. All rights reserved.
//

import UIKit
import ObjectiveC

/**
 Available styles for the popup bar.
 
 Use the most appropriate style for the current operating system version. Uses prominent style for iOS 10 and above, otherwise compact.
 
 */
@objc public enum PBPopupBarStyle : Int {
    
    /**
     Prominent bar style
     */
    case prominent
    
    /**
     Compact bar style
     */
    case compact
    
    /**
     Custom bar style
     
     - Note: Do not set this style directly. Instead set `PBPopupBar.customBarViewController` and the framework will use this style.
     */
    case custom
    
    /**
     Default style: prominent style for iOS 10 and above, otherwise compact.
     */
    public static let `default`: PBPopupBarStyle = {
        return .prominent
    }()
}

extension PBPopupBarStyle
{
    /**
     An array of human readable strings for the popup bar styles.
     */
    public static let strings = ["prominent", "compact", "custom"]
    
    private func string() -> NSString {
        return PBPopupBarStyle.strings[self.rawValue] as NSString
    }
    
    /**
     Return an human readable description for the popup bar style.
     */
    public var description: NSString {
        get {
            return string()
        }
    }
}

/**
 Available styles for the progress view.
 
 Use the most appropriate style for the current operating system version. Uses none for iOS 10 and above, otherwise bottom.
 */
@objc public enum PBPopupBarProgressViewStyle : Int {
    
    /**
     Progress view on bottom.
     */
    case bottom
    
    /**
     Progress view on top.
     */
    case top
    
    /**
     No progress view.
     */
    case none
    
    /**
     Default style: none for iOS 10 and above, otherwise bottom.
     */
    public static let `default`: PBPopupBarProgressViewStyle = {
        return .none
    }()
}

extension PBPopupBarProgressViewStyle
{
    /**
     An array of human readable strings for the progress view styles.
     */
    public static let strings = ["bottom", "top", "none"]
    
    private func string() -> NSString {
        return PBPopupBarProgressViewStyle.strings[self.rawValue] as NSString
    }
    
    /**
     Return an human readable description for the progress view style.
     */
    public var description:NSString {
        get {
            return string()
        }
    }
}

/**
 Available styles for the border view.
 */
@objc public enum PBPopupBarBorderViewStyle : Int {
    
    /**
     Border view on left.
     */
    case left
    
    /**
     Border view on right.
     */
    case right
    
    /**
     No border view.
     */
    case none
    
    /**
     Default style: none.
     */
    public static let `default`: PBPopupBarBorderViewStyle = {
        return .none
    }()
}

extension PBPopupBarBorderViewStyle
{
    /**
     An array of human readable strings for the border view styles.
     */
    public static let strings = ["left", "right", "none"]
    
    private func string() -> NSString {
        return PBPopupBarBorderViewStyle.strings[self.rawValue] as NSString
    }
    
    /**
     Return an human readable description for the progress view style.
     */
    public var description:NSString {
        get {
            return string()
        }
    }
}

// _UITAMICAdaptorView
private let itemClass11: AnyClass? = NSClassFromString(_PBPopupDecodeBase64String(base64String: "X1VJVEFNSUNBZGFwdG9yVmlldw==")!)
// _UIToolbarNavigationButton
private let itemClass10: AnyClass? = NSClassFromString(_PBPopupDecodeBase64String(base64String: "X1VJVG9vbGJhck5hdmlnYXRpb25CdXR0b24=")!)

internal let PBPopupBarHeightCompact: CGFloat = 48.0
//internal let PBPopupBarHeightProminent: CGFloat = 64.5
internal let PBPopupBarHeightProminent: CGFloat = 64.0
internal let PBPopupBarImageHeightProminent: CGFloat = 48.0
internal let PBPopupBarImageHeightCompact: CGFloat = 40.0
internal let PBPopupBarImageHeightFloating: CGFloat = 40.0

// MARK: - Public Protocols

/**
 The data source providing custom labels instances to the popup bar so they can be used instead of the default provided ones.
 */
@objc public protocol PBPopupBarDataSource: NSObjectProtocol {
    
    /**
     Returns a UIlabel subclass object to be used by the popup bar instead of the default title label (for example a MarqueeLabel instance).
     
     - Parameter popupBar: The popup bar object asking for a label.
     
     - returns: A `UIlabel` object to be used instead of the default one.
     */
    @objc optional func titleLabel(for popupBar: PBPopupBar) -> UILabel?
    
    /**
     Returns a UIlabel subclass object to be used by the popup bar instead of the default subtitle label (for example a MarqueeLabel instance).
     
     - Parameter popupBar: The popup bar object asking for a label.
     
     - returns: A `UIlabel` object to be used instead of the default one.
     */
    @objc optional func subtitleLabel(for popupBar: PBPopupBar) -> UILabel?
}

/**
 A set of methods used by the delegate to respond, with a preview view controller and a commit view controller, to the user pressing the popup bar object on the screen of a device that supports 3D Touch.
 */
@objc public protocol PBPopupBarPreviewingDelegate: NSObjectProtocol {
    /**
     Called when the user performs a peek action on the popup bar.
     
     The default implementation returns `nil` and no preview is displayed.
     
     - Parameter popupBar: The popup bar object.
     
     - returns: The view controller whose view you want to provide as the preview (peek), or `nil` to disable preview.
     */
    @objc optional func previewingViewControllerFor(_ popupBar: PBPopupBar) -> UIViewController?
    
    /**
     Called when the user performs a pop action on the popup bar.
     
     The default implementation does not commit the view controller.
     
     - Parameter popupBar:                  The popup bar object.
     - Parameter viewControllerToCommit:    The view controller to commit.
     */
    @objc optional func popupBar(_ popupBar: PBPopupBar, commit viewControllerToCommit: UIViewController)
}

/**
 A popup bar presented with a container view controller such as a `UITabBarController`, a `UINavigationController`, a `UIViewController` or a custom container view controller. The user can swipe or tap the popup bar at any point to present the popup content view controller. After presenting, the user dismisses the popup content view controller by either swiping or tapping an optional popup close button. The contents of the popup bar is built dynamically using its own properties. The popup bar may be a custom one if `PBPopupBar.customPopupBarViewController` is set.
 
 */
@objc public class PBPopupBar: UIView {
    
    // MARK: - Public Properties
    
    /**
     The data source of the PBPopupBar object.
     
     - SeeAlso: `PBPopupBarDataSource`.
     */
    @objc weak public var dataSource: PBPopupBarDataSource? {
        didSet {
            self.askForLabels = true
            self.removeTitleLabels()
            self.configureTitleLabels()
        }
    }
    
    /**
     The previewing delegate object mediates the presentation of views from the preview (peek) view controller and the commit (pop) view controller. In practice, these two are typically the same view controller. The delegate performs this mediation through your implementation of the methods of the `PBPopupBarPreviewingDelegate` protocol.
     
     - SeeAlso: `PBPopupBarPreviewingDelegate`.
     */
    @objc weak public var previewingDelegate: PBPopupBarPreviewingDelegate?
    
    /**
     For debug: If `true`, the popup bar will attribute some colors to its subviews.
     */
    @available(*, deprecated, message: "Use enablePopupBarColorsDebug on presentation container view controller instead")
    @objc public var PBPopupBarShowColors: Bool = false
    
    /**
     The popup bar presentation duration when presenting from hidden to closed state.
     
     - Seealso: `PBPopupContentView.popupPresentationDuration`.
     */
    @objc public var popupBarPresentationDuration: TimeInterval = 0.6
    
    /**
     The tap gesture recognizer attached to the popup bar for presenting the popup content view.
     */
    @available(*, deprecated, message: "Use PBPopupController.popupBarTapGestureRecognizer instead")
    @objc public var popupTapGestureRecognizer: UITapGestureRecognizer!
    
    /**
     Set this property with a custom popup bar view controller object to provide a popup bar with custom content. In this custom view controller, use the preferredContentSize property to set the size of the custom popup bar (example: preferredContentSize = CGSize(width: -1, height: 65)).
     */
    @objc public var customPopupBarViewController: UIViewController? {
        willSet {
            PBLog("The value of customBarViewController will change from \(String(describing: customPopupBarViewController)) to \(String(describing: newValue))")
            customPopupBarViewController?.view.removeFromSuperview()
        }
        didSet {
            PBLog("The value of customBarViewController changed from \(String(describing: oldValue)) to \(String(describing: customPopupBarViewController))")
            if customPopupBarViewController != nil {
                customPopupBarViewController!.popupContainerViewController = self.popupController.containerViewController
                self.popupBarStyle = .custom
            }
        }
    }
    
    /**
     Set this property to `true` if you want the custom popup bar extend under the safe area, to the bottom of the screen.
     
     When a popup bar is presented on a view controller with the system bottom docking view, or a navigation controller with hidden toolbar, the popup bar's background view will extend under the safe area.
     */
    @objc public var shouldExtendCustomBarUnderSafeArea: Bool = true
    
    /**
     If `true`, the popup bar will automatically inherit its style from the bottom bar.
     */
    @objc public var inheritsVisualStyleFromBottomBar: Bool = true {
        didSet {
            if inheritsVisualStyleFromBottomBar == true {
                self.popupController.containerViewController.configurePopupBarFromBottomBar()
            }
        }
    }
    
    /**
     A Boolean value that indicates whether the popup bar is floating like in iOS 17 (`true`) or not (`false`).
     */
    @objc public var isFloating: Bool {
        get {
            return self.popupBarIsFloating
        }
        set {
            self.popupBarIsFloating = newValue
        }
    }
    
    /**
     The popup bar style (see PBPopupBarStyle).
     */
    @objc public var popupBarStyle: PBPopupBarStyle = .default {
        willSet {
            PBLog("The value of popupBarStyle will change from \(popupBarStyle.description) to \(newValue.description)")
            if self.popupController.popupPresentationState != .hidden, popupBarStyle != newValue {
                if let vc = self.popupController.containerViewController {
                    vc.hidePopupBar(animated: false)
                }
                self.popupController.popupPresentationState = .closed
                self.customPopupBarViewController?.view.removeFromSuperview()
            }
        }
        didSet {
            PBLog("The value of popupBarStyle changed from \(oldValue.description) to \(popupBarStyle.description)")
            if oldValue != popupBarStyle {
                self.removeTitleLabels()
            }
            if popupBarStyle == .custom {
                self.isFloating = false
                if self.customPopupBarViewController == nil {
                    PBLog("Custom popuBar view controller cannot be nil.", error: true)
                }
                assert(self.customPopupBarViewController != nil, "Custom popuBar view controller cannot be nil.")
                if self.customPopupBarViewController == nil {
                    NSException.raise(NSExceptionName.internalInconsistencyException, format: "Custom popuBar view controller cannot be nil.", arguments: getVaList([]))
                }
            }
            else {
                self.configureContentSizeCategory()
            }
            self.setupCustomPopupBarView()
                        
            if self.popupController.popupPresentationState == .closed {
                if let vc = self.popupController.containerViewController {
                    self.popupController.popupPresentationState = .hidden
                    vc.showPopupBar(animated: false)
                }
            }
        }
    }
    
    /**
     The bar style of the popup bar toolbar.
     */
    @objc public var barStyle: UIBarStyle {
        get {
            return self.toolbar.barStyle
        }
        set(newValue) {
            self.systemBarStyle = newValue
            self.popupController.barStyle = newValue
            
#if targetEnvironment(macCatalyst)
            self.backgroundView?.backgroundColor = nil
#else
            if #available(iOS 13.0, *) {
                self.backgroundView?.backgroundColor = nil
            }
            else {
                if newValue == .black {
                    self.backgroundView?.backgroundColor = UIColor.clear
                }
                else {
                    self.backgroundView?.backgroundColor = nil
                }
            }
#endif
            self.toolbar.barStyle = newValue
        }
    }
    
    /**
     The popup bar's background effect. Use `nil` to use the most appropriate background style for the environment.
     */
    @objc public var backgroundEffect: UIBlurEffect? {
        didSet {
            self.backgroundView?.effect = backgroundEffect
        }
    }
    
    /**
     The floating popup bar's background effect. Use `nil` to use the most appropriate background style for the environment.
     */
    @objc public var floatingBackgroundEffect: UIBlurEffect? {
        didSet {
            self.contentView.effect = floatingBackgroundEffect
        }
    }
    
    /**
     The popup bar background style that specifies its visual effect appearance.
     
     - SeeAlso: `UIBlurEffect.Style`
     */
    @objc public var backgroundStyle: UIBlurEffect.Style {
        get {
            if #available(iOS 13.0, *) {
                if self.systemBarStyle == .black {
                    return .systemChromeMaterialDark
                }
                return .systemChromeMaterial
            }
            return self.systemBarStyle == .black ? .dark : .extraLight
        }
        set {
            self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            self.backgroundView?.effect = UIBlurEffect(style: newValue)
        }
    }
    
    /**
     A Boolean value that indicates whether the popup bar is translucent (`true`) or not (`false`).
     */
    @objc public var isTranslucent: Bool {
        get {
            return self.toolbar.isTranslucent
        }
        set {
            if self.toolbar.isTranslucent != newValue {
                self.toolbar.isTranslucent = newValue
                self.backgroundView?.effect = newValue == false ? nil : self.backgroundEffect
                self.contentView.effect =  newValue == false ? nil : self.floatingBackgroundEffect
            }
        }
    }
    
    /**
     The popup bar's background custom view (usefull for custom bars).
     This view is composited over `backgroundEffect`,  `backgroundImage` and `backgroundColor`.
     */
    @objc public var backgroundCustomView: UIView? {
        get {
            return backgroundView?.customView
        }
        set {
            self.backgroundView?.customView = newValue
        }
    }

    /**
     The background color of the popup bar's background view.
     */
    @objc override public var backgroundColor: UIColor? {
        get {
            return self.userBackgroundColor
        }
        set {
            if self.userBackgroundColor != newValue {
                self.userBackgroundColor = newValue
                self.backgroundView?.colorView.backgroundColor = newValue
            }
        }
    }
    
    /**
     The floating popup bar's background color. Use `nil` to use the most appropriate background style for the environment.
     This color is composited over `floatingBackgroundEffect`.
     */
    @objc public var floatingBackgroundColor: UIColor? {
        get {
            return self.userFloatingBackgroundColor
        }
        set {
            if self.userFloatingBackgroundColor != newValue {
                self.userFloatingBackgroundColor = newValue
                self.contentView.colorView.backgroundColor = newValue
            }
        }
    }
    
    /**
     The popup bar's background image. Use `nil` to use the most appropriate background style for the environment.
     This image is composited over the `floatingBackgroundColor`, and resized per the `floatingBackgroundImageContentMode`.
     */
    @objc public var backgroundImage: UIImage? {
        get {
            return self.userBackgroundImage
        }
        set {
            if self.userBackgroundImage != newValue {
                self.userBackgroundImage = newValue
                self.backgroundView?.imageView.image = newValue
            }
        }
    }
    
    /**
     The content mode to use when rendering the `backgroundImage`. Defaults to `UIViewContentModeScaleToFill`. `UIViewContentModeRedraw` will be reinterpreted as `UIViewContentModeScaleToFill`.
     */
    @objc public var backgroundImageContentMode: UIView.ContentMode = .scaleToFill {
        didSet {
            self.backgroundView?.imageView.contentMode = backgroundImageContentMode
        }
    }
    
    /**
     The floating popup bar's background image. Use `nil` to use the most appropriate background style for the environment.
     This image is composited over the `floatingBackgroundColor`, and resized per the `floatingBackgroundImageContentMode`.
     */
    @objc public var floatingBackgroundImage: UIImage? {
        get {
            return self.userFloatingBackgroundImage
        }
        set {
            if self.userFloatingBackgroundImage != newValue {
                self.userFloatingBackgroundImage = newValue
                self.contentView.imageView.image = newValue
            }
        }
    }
    
    /**
     The content mode to use when rendering the `floatingBackgroundImage`. Defaults to `UIViewContentModeScaleToFill`. `UIViewContentModeRedraw` will be reinterpreted as `UIViewContentModeScaleToFill`.
     */
    @objc public var floatingBackgroundImageContentMode: UIView.ContentMode = .scaleToFill {
        didSet {
            self.contentView.imageView.contentMode = floatingBackgroundImageContentMode
        }
    }
    
    /**
     The shadow displayed underneath the floating popup bar background. Read only but its properties can be changed.
     */
    @objc public internal(set) var floatingBackgroundShadow: NSShadow!
    
    /**
     The tint color to apply to the popup bar background.
     */
    @available(iOS, obsoleted: 13.0, message: "Use backgroundColor and floatingBackgroundColor instead")
    @objc public var barTintColor: UIColor! {
        get {
            return self.toolbar.barTintColor
        }
        set {
            if self.toolbar.barTintColor != newValue {
                self.toolbar.setBackgroundImage(newValue == nil ? UIImage() : nil, forToolbarPosition: .any, barMetrics: .default)
                self.toolbar.barTintColor = newValue
            }
        }
    }
    
    /**
     The tint color to apply to the popup bar items.
     */
    @objc override public var tintColor: UIColor! {
        get {
            return self.toolbar.tintColor
        }
        set {
            if self.toolbar.tintColor != newValue {
                self.toolbar.tintColor = newValue
            }
        }
    }
    
    /**
     The popup bar's image.
     
     - note: The image will only be displayed on prominent popup bars.
     */
    @objc public var image: UIImage? = nil {
        didSet {
            self.shadowImageView.imageView.image = image
            self.layoutImageView()
            
            self.setNeedsLayout()
        }
    }
    
    /**
     An image view displayed when the bar style is prominent. (read-only)
     */
    @objc public internal(set) var imageView: UIImageView!
    
    /**
     The view providing a shadow layer to the popup bar image view.
     
     - Note: Read-only, but its properties can be set. For example for no shadow, use `popupBar.shadowImageView.shadowOpacity = 0`.
     */
    @objc public private(set) var shadowImageView: PBPopupRoundShadowImageView!
    
    /**
     The popup bar's title.
     
     - Note: If no subtitle is set, the title will be centered vertically.
     */
    @objc public var title: String? {
        didSet {
            self.titleLabel?.isHidden = title == nil
            self.configureTitleLabels()
            self.configureAccessibility()
        }
    }
    
    /**
     Display attributes for the popup bar’s title text.
     
     You may specify the font, text color, and shadow properties for the title in the text attributes dictionary, using the keys found in `NSAttributedString.h`.
     */
    @objc public var titleTextAttributes: [NSAttributedString.Key: Any]? {
        didSet {
            self.configureTitleLabels()
        }
    }
    
    /**
     The popup bar's subtitle.
     
     - Note: If no title is set, the subtitle will be centered vertically.
     */
    @objc public var subtitle: String? {
        didSet {
            self.subtitleLabel?.isHidden = subtitle == nil
            
            self.configureTitleLabels()
            self.configureAccessibility()
        }
    }
    
    /**
     Display attributes for the popup bar’s subtitle text.
     
     You may specify the font, text color, and shadow properties for the subtitle in the text attributes dictionary, using the keys found in `NSAttributedString.h`.
     */
    @objc public var subtitleTextAttributes: [NSAttributedString.Key: Any]? {
        didSet {
            self.configureTitleLabels()
        }
    }
    
    /**
     The string that succinctly identifies the accessibility element (titles view, the container for title and subtitle labels).
     */
    override public var accessibilityLabel: String? {
        get {
            return self.titlesView.accessibilityLabel
        }
        set {
            self.titlesView.accessibilityLabel = newValue
            self.configureAccessibility()
        }
    }
    
    /**
     The string that briefly describes the result of performing an action on the accessibility title view (container for title and subtitle labels).
     */
    override public var accessibilityHint: String? {
        get {
            return self.titlesView.accessibilityHint
        }
        set {
            self.titlesView.accessibilityHint = newValue
            self.configureAccessibility()
        }
    }
    
    /**
     The semantic description of the view’s contents, used to determine whether the view should be flipped when switching between left-to-right and right-to-left layouts.
     
     Defaults to `UISemanticContentAttribute.unspecified`
     */
    @objc override public var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            super.semanticContentAttribute = semanticContentAttribute
            self.toolbar.semanticContentAttribute = semanticContentAttribute
            
            self.layoutToolbarItems()
            self.configureTitleLabels()

            self.setNeedsLayout()
        }
    }
    
    /**
     An array of custom bar button items to display on the left side. Or right side if RTL.
     */
    @objc public var leftBarButtonItems: [UIBarButtonItem]? {
        didSet {
            self.layoutToolbarItems()
            self.configureTitleLabels()

            self.setNeedsLayout()
        }
    }
    
    /**
     An array of custom bar button items to display on the right side. Or left side if RTL.
     */
    @objc public var rightBarButtonItems: [UIBarButtonItem]? {
        didSet {
            self.layoutToolbarItems()
            self.configureTitleLabels()

            self.setNeedsLayout()
        }
    }
    
    /**
     The semantic description of the bar items, used to determine the order of bar items when switching between left-to-right and right-to-left layouts.
     
     Defaults to `UISemanticContentAttribute.playback`
     */
    @objc public var barButtonItemsSemanticContentAttribute: UISemanticContentAttribute = .playback {
        didSet {
            self.layoutToolbarItems()
            self.configureTitleLabels()

            self.setNeedsLayout()
        }
    }
    
    /**
     The popup bar's progress view style.
     */
    @objc public var progressViewStyle: PBPopupBarProgressViewStyle = .default {
        didSet {
            self.layoutProgressView()
        }
    }
    
    /**
     The popup bar progress view's progress.
     
     The progress is represented by a floating-point value between 0.0 and 1.0, inclusive, where 1.0 indicates the completion of the task. The default value is 0.0. Values less than 0.0 and greater than 1.0 are pinned to those limits.
     */
    @objc public var progress: Float {
        get {
            return self.progressView?.progress ?? 0.0
        }
        set {
            self.progressView.setProgress(newValue, animated: false)
        }
    }
    
    /**
     The popup bar's border view style.
     */
    @objc public var borderViewStyle: PBPopupBarBorderViewStyle = .default {
        didSet {
            self.layoutBorderView()
        }
    }
    
    /**
     The accessibility label of the progress, in a localized string.
     */
    @objc public var accessibilityProgressLabel: String?
    
    /**
     The accessibility value of the progress, in a localized string.
     */
    @objc public var accessibilityProgressValue: String?
    
    // MARK: - Private Properties
    
    internal var enablePopupBarColorsDebug: Bool = false
    private var usePopupBarSmoothGradient: Bool = true
    private var usePopupBarLegacyShadow: Bool = false

    internal weak var popupController: PBPopupController!
    
    internal var ignoreLayoutDuringTransition: Bool = false
    
    internal var popupBarHeight: CGFloat {
        if self.popupBarStyle == .custom {
            return customPopupBarViewController != nil ? customPopupBarViewController!.preferredContentSize.height : PBPopupBarHeightProminent
        }
        return self.popupBarStyle == .prominent ? PBPopupBarHeightProminent : PBPopupBarHeightCompact
    }
    
    internal var popupBarWidth: CGFloat {
        let defaultWidth = self.popupController.containerViewController.defaultFrameForBottomBar().width
        if self.popupBarStyle == .custom {
            if let customPopupBarViewController = self.customPopupBarViewController {
                let width = customPopupBarViewController.preferredContentSize.width
                return width > 0 ? width : defaultWidth
            }
        }
        return self.popupController.containerViewController.defaultFrameForBottomBar().width
    }
    
    private var systemBarStyle: UIBarStyle!
    
    private var popupBarIsFloating: Bool = false {
        didSet {
            self.updatePopupBarAppearance()
            
            self.backgroundView?.mask = popupBarIsFloating ? self.floatingBackgroundMaskView : nil

            self.floatingBackgroundShadowView?.isHidden = !popupBarIsFloating

            self.contentView.cornerRadius = popupBarIsFloating ? self.floatingRadius : 0.0
            
            if self.usePopupBarLegacyShadow {
                self.contentView.castsShadow = popupBarIsFloating ? true : false
            }

            self.shadowImageView.cornerRadius = popupBarIsFloating ? self.floatingRadius / 2 : 3.0
            self.highlightView.layer.cornerRadius = popupBarIsFloating ? self.floatingRadius : 0.0
            
            self.contentView.preservesSuperviewLayoutMargins = !popupBarIsFloating
            self.toolbar.layer.cornerRadius = popupBarIsFloating ? self.floatingRadius : 0.0
            if #available(iOS 13.0, *) {
                self.toolbar.layer.cornerCurve = .continuous
            }
            
            self.toolbar.popupBarIsFloating = popupBarIsFloating
            
            if #available(iOS 13.0, *) {
                self.toolbar.backgroundImage = nil
                self.toolbar.shadowImage = nil
            }
            else {
                self.toolbar.backgroundImage = UIImage()
                self.toolbar.shadowImage = popupBarIsFloating ? UIImage() : nil
            }
            
            self.contentView.effect = popupBarIsFloating ? self.floatingBackgroundEffect : nil
            
            self.contentView.imageView.image = popupBarIsFloating ? self.floatingBackgroundImage : nil
            self.contentView.colorView.backgroundColor = popupBarIsFloating ? self.floatingBackgroundColor : nil

            self.backgroundView?.imageView.image = popupBarIsFloating ? nil : self.backgroundImage
            self.backgroundView?.colorView.backgroundColor = popupBarIsFloating ? nil : self.backgroundColor

            self.configureContentSizeCategory()
            
            self.setNeedsLayout()
        }
    }
    
    // The corner radius for the floating popup bar
    internal var floatingRadius: CGFloat = 14
    
    // The default inset for the floating popup bar
    internal var floatingInsets: UIEdgeInsets = UIEdgeInsets(top: 4.0, left: 12, bottom: 4.0, right: 12)

    internal var backgroundView: _PBPopupBackgroundEffectShadowView!
    internal var transitionBackgroundView: _PBPopupBackgroundEffectShadowView!
    
    private var floatingBackgroundMaskView: _PBPopupBackgroundMaskView!
    private var transitionFloatingBackgroundMaskView: _PBPopupBackgroundMaskView!

    private var floatingBackgroundShadowView: _PBPopupBackgroundShadowView!
    
    internal var effectGroupingIdentifier: String!
    
    private var effectGroupingIdentifierKey: String?
    {
        let gN = "Z3JvdXBOYW1l"
        var rv: String? = nil
        rv = _PBPopupDecodeBase64String(base64String: gN)
        return rv
    }
    
    private var userBackgroundColor: UIColor?
    private var userBackgroundImage: UIImage?
    
    private var userFloatingBackgroundColor: UIColor?
    private var userFloatingBackgroundImage: UIImage?

    private var contentView: _PBPopupBarContentView!
    private var toolbar: _PBPopupToolbar!
    
    internal var shadowColor: UIColor! {
        didSet {
            self.toolbar.shadowColor = shadowColor
        }
    }
    
    private var contentViewTopConstraint: NSLayoutConstraint!
    private var contentViewLeftConstraint: NSLayoutConstraint!
    private var contentViewRightConstraint: NSLayoutConstraint!
    private var contentViewHeightConstraint: NSLayoutConstraint!

    private var customBarTopConstraint: NSLayoutConstraint!
    private var customBarLeftConstraint: NSLayoutConstraint!
    private var customBarRightConstraint: NSLayoutConstraint!
    private var customBarHeightConstraint: NSLayoutConstraint!

    private var safeAreaBackgroundViewHeightConstraint: NSLayoutConstraint?
    
    private var imageViewTopConstraint: NSLayoutConstraint!
    private var imageViewLeftConstraint: NSLayoutConstraint!
    private var imageViewRightConstraint: NSLayoutConstraint!
    private var imageViewWidthConstraint: NSLayoutConstraint!
    private var imageViewHeightConstraint: NSLayoutConstraint!
    
    private var imageController: UIViewController?
    
    internal var imageShadowOpacity: Float = 0.0
    
    internal var swiftUIImageController: UIViewController? {
        set {
            if let imageController = imageController {
                imageController.view.removeFromSuperview()
            }
            imageController = newValue
            imageController?.view.backgroundColor = nil
            if let imageController = imageController {
                self.shadowImageView.cornerRadius = imageController.value(forKey: "cornerRadius") as! CGFloat
                self.shadowImageView.shadowColor = imageController.value(forKey: "shadowColor") as? UIColor
                self.shadowImageView.shadowOffset = imageController.value(forKey: "shadowOffset") as! CGSize
                self.shadowImageView.shadowOpacity = imageController.value(forKey: "shadowOpacity") as! Float
                self.shadowImageView.shadowRadius = imageController.value(forKey: "shadowRadius") as! CGFloat
                self.imageShadowOpacity = self.shadowImageView.shadowOpacity
                self.shadowImageView.addSubview(imageController.view)
                self.shadowImageView.shadowOpacity = 0.0
                
                self.shadowImageView.addSubview(imageController.view)
                imageController.view.translatesAutoresizingMaskIntoConstraints = false
                imageController.view.topAnchor.constraint(equalTo: self.shadowImageView.topAnchor, constant: 0.0).isActive = true
                imageController.view.leftAnchor.constraint(equalTo: self.shadowImageView.leftAnchor, constant: 0.0).isActive = true
                imageController.view.rightAnchor.constraint(equalTo: self.shadowImageView.rightAnchor, constant: 0.0).isActive = true
                imageController.view.bottomAnchor.constraint(equalTo: self.shadowImageView.bottomAnchor, constant: 0.0).isActive = true
                
                self.layoutImageView()
                self.layoutTitlesView()
            }
        }
        get {
            return imageController
        }
    }
    
    // The container view for titleLabel and subtitleLabel
    @objc dynamic private var titlesView: _PBPopupBarTitlesView!
    
    private var titlesViewLeftConstraint: NSLayoutConstraint!
    private var titlesViewRightConstraint: NSLayoutConstraint!
    
    // true if we have to ask for a custom label (i.e. MarqueeLabel)
    private var askForLabels: Bool = false
    
    // The label containing the title text
    internal var titleLabel: UILabel? {
        didSet {
            titleLabel?.backgroundColor = UIColor.clear
            titleLabel?.font = self.titleFont()
            titleLabel?.textColor = self.titleColor()
            titleLabel?.isAccessibilityElement = true
            titleLabel?.adjustsFontForContentSizeCategory = true
            titleLabel?.setContentHuggingPriority(.required, for: .vertical)
        }
    }

    // The label containing the subtitle text
    internal var subtitleLabel: UILabel? {
        didSet {
            subtitleLabel?.backgroundColor = UIColor.clear
            subtitleLabel?.font = self.subtitleFont()
            subtitleLabel?.textColor = self.subtitleColor()
            subtitleLabel?.isAccessibilityElement = true
            subtitleLabel?.adjustsFontForContentSizeCategory = true
            subtitleLabel?.setContentHuggingPriority(.required, for: .vertical)
        }
    }

    // The progress view (see PBPopupBarProgressViewStyle and progress property)
    @objc dynamic private var progressView: _PBPopupBarProgressView!
    
    private var progressViewVerticalConstraints: [NSLayoutConstraint]!
    private var progressViewHorizontalConstraints: [NSLayoutConstraint]!
    
    // Highlighted view when taping or paning the popupBar
    @objc dynamic internal var highlightView: _PBPopupBarHighlightView!
    
    // Border view for iPad when the popup bar is the neighbour of another object
    @objc dynamic internal var borderView: _PBPopupBarBorderView!
    
    private var borderViewVerticalConstraints: [NSLayoutConstraint]!
    private var borderViewHorizontalConstraints: [NSLayoutConstraint]!
    
    // MARK: - Private Init
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal convenience init(frame: CGRect, usePopupBarSmoothGradient: Bool = false, usePopupBarLegacyShadow: Bool = false, enablePopupBarColorsDebug: Bool = false) {
        self.init(frame: frame)
        
        self.usePopupBarSmoothGradient = usePopupBarSmoothGradient
        self.usePopupBarLegacyShadow = usePopupBarLegacyShadow
        self.enablePopupBarColorsDebug = enablePopupBarColorsDebug

        self.setupPopupBar()
    }
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
    }
        
    private func setupPopupBar() {
        self.autoresizesSubviews = true // default: true
        self.preservesSuperviewLayoutMargins = true // default: false
        
        self.autoresizingMask = []
        
        let effect = UIBlurEffect(style: self.backgroundStyle)
        
        self.backgroundView = _PBPopupBackgroundEffectShadowView(effect: effect)
        self.backgroundView.enablePopupBarColorsDebug = self.enablePopupBarColorsDebug
        self.backgroundView.frame = self.bounds
        self.backgroundView.autoresizingMask = []
        self.backgroundView.isUserInteractionEnabled = false
        self.backgroundView.floatingInset = self.floatingInsets
        self.backgroundView.castsShadow = false
        
        self.addSubview(self.backgroundView)

        self.backgroundEffect = effect

        self.floatingBackgroundMaskView = _PBPopupBackgroundMaskView(frame: self.bounds, smooth: self.usePopupBarSmoothGradient)
        
        self.transitionBackgroundView = _PBPopupBackgroundEffectShadowView(effect: effect)
        self.transitionBackgroundView.enablePopupBarColorsDebug = self.enablePopupBarColorsDebug
        self.transitionBackgroundView.frame = self.bounds
        self.transitionBackgroundView.autoresizingMask = []
        self.transitionBackgroundView.isUserInteractionEnabled = false
        self.transitionBackgroundView.floatingInset = self.floatingInsets
        self.transitionBackgroundView.castsShadow = false
        
        self.transitionFloatingBackgroundMaskView = _PBPopupBackgroundMaskView(frame: self.bounds, smooth: self.usePopupBarSmoothGradient)
        
        self.transitionBackgroundView.mask = self.transitionFloatingBackgroundMaskView
        
        if !self.usePopupBarLegacyShadow {
            
            self.floatingBackgroundShadowView = _PBPopupBackgroundShadowView()
            self.floatingBackgroundShadowView.autoresizingMask = []
            self.floatingBackgroundShadowView.isUserInteractionEnabled = false
            self.floatingBackgroundShadowView.floatingInset = self.floatingInsets
            self.floatingBackgroundShadowView.cornerRadius = self.floatingRadius
            self.floatingBackgroundShadowView.isHidden = true
            
            self.addSubview(self.floatingBackgroundShadowView)

            self.floatingBackgroundShadow = NSShadow()
            self.floatingBackgroundShadow.shadowColor = nil
            self.floatingBackgroundShadow.shadowBlurRadius = 8.0
            self.floatingBackgroundShadow.shadowOffset = .zero
            self.floatingBackgroundShadowView.userFloatingBackgroundShadow = self.floatingBackgroundShadow

            let shadow = NSShadow()
            
            var lightColor: UIColor
            var darkColor: UIColor
            if self.enablePopupBarColorsDebug {
                lightColor = UIColor.red.withAlphaComponent(0.85)
                darkColor = UIColor.red.withAlphaComponent(0.85)
            }
            else {
                lightColor = UIColor.black.withAlphaComponent(0.15)
                darkColor = UIColor.black.withAlphaComponent(0.30)
            }
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .light {
                    shadow.shadowColor = lightColor
                }
                else {
                    shadow.shadowColor = darkColor
                }
            }
            else {
                shadow.shadowColor = lightColor
            }
            shadow.shadowOffset = CGSize(width: 0.0, height: 0.0)
            shadow.shadowBlurRadius = 8.0
            
            self.floatingBackgroundShadowView.lightShadowColor = lightColor
            self.floatingBackgroundShadowView.darkShadowColor = darkColor
            self.floatingBackgroundShadowView.shadow = shadow
        }
        
        self.contentView = _PBPopupBarContentView(effect: nil)
        self.contentView.enablePopupBarColorsDebug = self.enablePopupBarColorsDebug
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = []
        self.contentView.castsShadow = false
        self.contentView.floatingInset = self.floatingInsets
        if #available(iOS 13.0, *) {
            self.contentView.layer.cornerCurve = .continuous
        }
        
        self.addSubview(self.contentView)

        self.floatingBackgroundEffect = effect

        // The toolbar frame must not be zero for configuring items.
        // See pb_popupBar() -> PBPopupBar in PBPopupController.swift
        self.toolbar = _PBPopupToolbar(frame: self.bounds)
        self.toolbar.autoresizingMask = []
        self.toolbar.isTranslucent = true
        
        if #available(iOS 13.0, *) {
            self.toolbar.shadowImage = nil
            self.toolbar.backgroundImage = nil
        }
        else {
            self.toolbar.backgroundImage = UIImage()
            self.toolbar.shadowImage = UIImage()
        }
        
        self.contentView.effectView.contentView.addSubview(self.toolbar)
        
        self.shadowImageView = PBPopupRoundShadowImageView(frame: .zero)
        self.shadowImageView.cornerRadius = 3.0
        self.shadowImageView.shadowColor = UIColor.black
        self.shadowImageView.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.shadowImageView.shadowRadius = 3.0
        self.shadowImageView.shadowOpacity = 0.5
        
        self.shadowImageView.imageView.accessibilityTraits = UIAccessibilityTraits.image
        self.shadowImageView.imageView.isAccessibilityElement = true
        
        self.shadowImageView.imageView.contentMode = .scaleAspectFit
        self.shadowImageView.contentMode = .scaleAspectFit
        
        self.shadowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.toolbar.addSubview(self.shadowImageView)
        
        self.titlesView = _PBPopupBarTitlesView()
        self.titlesView.isAccessibilityElement = true
        self.titlesView.accessibilityTraits = .button
        self.titlesView.accessibilityLabel = NSLocalizedString("Popup bar", comment: "")
        self.titlesView.autoresizingMask = []
        self.titlesView.isUserInteractionEnabled = false
        
        self.toolbar.addSubview(self.titlesView)
        
        self.configureContentSizeCategory()
        
        self.progressView = _PBPopupBarProgressView(progressViewStyle: .default)
        self.progressView.trackImage = UIImage()
        
        self.toolbar.addSubview(self.progressView)
        
        self.progressView.setProgress(0.0, animated: false)
        
        self.highlightView = _PBPopupBarHighlightView()
        self.highlightView.autoresizingMask = []
        self.highlightView.isUserInteractionEnabled = false
        self.highlightView.backgroundColor = UIColor.black.withAlphaComponent(0.10)
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                self.highlightView.backgroundColor = UIColor.white.withAlphaComponent(0.10)
            }
        }
        self.highlightView.alpha = 0.0
        
        self.addSubview(self.highlightView)
        
        self.borderView = _PBPopupBarBorderView()
        self.borderView.backgroundColor = UIColor.lightGray
        
        self.addSubview(borderView)
        
        self.isAccessibilityElement = false
        
        self.configureAccessibility()
        
        self.semanticContentAttribute = .unspecified
        
        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: .main) { [weak self] notification in
            self?.configureTitleLabels()
        }
    }
    
    deinit {
        self.floatingBackgroundShadowView?.colorToken?.invalidate()
        self.floatingBackgroundShadowView?.offsetToken?.invalidate()
        self.floatingBackgroundShadowView?.radiusToken?.invalidate()
        
        NotificationCenter.default.removeObserver(self, name: UIContentSizeCategory.didChangeNotification, object: nil)
        
        PBLog("deinit \(self)")
    }
    
    // MARK: - Public Methods
    
    /**
     Call this method to update the popup bar appearance (style, tint color, etc.) according to its docking view. You should call this after updating the docking view.
     If the popup bar's `inheritsVisualStyleFromBottomBar` property is set to `false`, this method has no effect.
     
     - SeeAlso: `PBPopupBar.inheritsVisualStyleFromBottomBar`.
     */
    @objc public func updatePopupBarAppearance() {
        self.popupController.containerViewController.configurePopupBarFromBottomBar()
    }
    
    internal func applyGroupingIdentifier(fromBottomBar: Bool) {
        guard let backgroundView = self.backgroundView,
              let transitionBackgroundView = self.transitionBackgroundView,
              let effectView = backgroundView.effectView,
              let transitionEffectView = transitionBackgroundView.effectView
        else {
            return
        }
        let popBarIdentifier = effectView.value(forKey: self.effectGroupingIdentifierKey!)
        PBLog("popBarIdentifier: \(String(describing: popBarIdentifier))")
        let identifier = String(format: "<%@:%p> Backdrop Group", NSStringFromClass(type(of: self)), self)
        PBLog("Identifier: \(identifier)")
        PBLog("groupingIdentifier: \(String(describing: self.effectGroupingIdentifier))")
        if let effectGroupingIdentifierKey = self.effectGroupingIdentifierKey {
            PBLog("effectGroupingIdentifierKey: \(effectGroupingIdentifierKey)")
            if !fromBottomBar {
                effectView.setValue(nil, forKey: effectGroupingIdentifierKey)
                transitionEffectView.setValue(nil, forKey: effectGroupingIdentifierKey)
                return
            }
            effectView.setValue(self.effectGroupingIdentifier ?? nil, forKey: effectGroupingIdentifierKey)
            transitionEffectView.setValue(self.effectGroupingIdentifier ?? nil, forKey: effectGroupingIdentifierKey)
        }
    }
    
    /**
     :nodoc:
     */
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        guard let popupBarView = self.superview else {return}
        
        if self.ignoreLayoutDuringTransition {
            return
        }
        self.frame = popupBarView.bounds
        
        self.layoutContentView()
        self.contentView.layoutIfNeeded()

        self.layoutToolbar()
        self.toolbar.layoutIfNeeded()

        self.layoutAllViews()
        
        if self.popupBarStyle == .custom {self.layoutCustomPopupBarView()}
    }
    
    /**
     :nodoc:
     */
    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        if self.ignoreLayoutDuringTransition {
            return
        }
        self.floatingBackgroundMaskView?.frame = self.backgroundView.bounds
        self.floatingBackgroundMaskView?.setNeedsDisplay()
    }

    /**
     :nodoc:
     */
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            let style = self.traitCollection.userInterfaceStyle
            self.highlightView.backgroundColor = style == .light ? UIColor.black.withAlphaComponent(0.10) : UIColor.white.withAlphaComponent(0.10)
        }
    }
    
    // MARK: - Private Methods
    
    internal func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if self.isFloating { return }
        let block = {
            self.highlightView.alpha = highlighted ? 1.0 : 0.0
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: block)
        }
        else {
            UIView.performWithoutAnimation(block)
        }
    }
    
    private func setupCustomPopupBarView() {
        let hidden = self.popupBarStyle == .custom && self.customPopupBarViewController != nil
        if hidden, let customPopupBarViewController = self.customPopupBarViewController {
            self.contentView.addSubview(customPopupBarViewController.view)
            self.bringSubviewToFront(self.highlightView)
            customPopupBarViewController.view.autoresizingMask = []
            self.customBarTopConstraint = nil
            self.customBarLeftConstraint = nil
            self.customBarRightConstraint = nil
            self.customBarHeightConstraint = nil
        }
        self.backgroundView?.customView?.isHidden = !hidden
        self.floatingBackgroundShadowView?.isHidden = !self.isFloating
        self.contentView.effect = self.isFloating ? self.floatingBackgroundEffect : nil
        self.toolbar.isHidden = hidden
        self.titlesView.isHidden = hidden
        self.highlightView.isHidden = hidden
    }
    
    private func layoutCustomPopupBarView() {
        if let customPopupBarViewController = self.customPopupBarViewController {
            
            customPopupBarViewController.view.preservesSuperviewLayoutMargins = true
                        
            customPopupBarViewController.view.translatesAutoresizingMaskIntoConstraints = false
            if let topConstraint = self.customBarTopConstraint {
                topConstraint.constant = 0.0
            }
            else {
                self.customBarTopConstraint = customPopupBarViewController.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0)
                self.customBarTopConstraint.isActive = true
            }
            if let leftConstraint = self.customBarLeftConstraint {
                leftConstraint.constant = 0.0
            }
            else {
                self.customBarLeftConstraint = customPopupBarViewController.view.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0.0)
                self.customBarLeftConstraint.isActive = true
            }
            if let rightConstraint = self.customBarRightConstraint {
                rightConstraint.constant = 0.0
            }
            else {
                self.customBarRightConstraint = customPopupBarViewController.view.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0.0)
                self.customBarRightConstraint.isActive = true
            }
            let constant = self.frame.height
            if let heightConstraint = self.customBarHeightConstraint {
                heightConstraint.constant = constant
            }
            else {
                self.customBarHeightConstraint = customPopupBarViewController.view.heightAnchor.constraint(equalToConstant: constant)
                self.customBarHeightConstraint.isActive = true
            }
        }
    }
    
    private func layoutAllViews() {
        
        self.layoutBackgroundView()
                
        self.layoutFloatingBackgroundShadowView()
        
        self.layoutImageView()
        
        self.layoutTitlesView()
        
        self.layoutProgressView()
        
        self.layoutHighlightView()
        
        self.layoutBorderView()
        
        //NSLayoutConstraint.reportAmbiguity(self)
        //NSLayoutConstraint.listConstraints(self)
    }
    
    private func layoutBackgroundView() {
        if let backgroundView = self.backgroundView {
            if self.enablePopupBarColorsDebug {
                backgroundView.effect = nil
                backgroundView.backgroundColor = UIColor.yellow
            }
            if backgroundView.translatesAutoresizingMaskIntoConstraints == true {
                backgroundView.translatesAutoresizingMaskIntoConstraints = false
                backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0.0).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0.0).isActive = true
            }
            if let heightConstraint = self.safeAreaBackgroundViewHeightConstraint {
                heightConstraint.constant = self.frame.size.height
            }
            else {
                self.safeAreaBackgroundViewHeightConstraint = backgroundView.heightAnchor.constraint(equalToConstant: self.frame.size.height)
                self.safeAreaBackgroundViewHeightConstraint?.isActive = true
            }
        }
    }
    
    private func layoutFloatingBackgroundShadowView() {
        if let floatingBackgroundShadowView = self.floatingBackgroundShadowView {
            if floatingBackgroundShadowView.translatesAutoresizingMaskIntoConstraints == true {
                floatingBackgroundShadowView.translatesAutoresizingMaskIntoConstraints = false
                floatingBackgroundShadowView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0).isActive = true
                floatingBackgroundShadowView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0.0).isActive = true
                floatingBackgroundShadowView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0).isActive = true
                floatingBackgroundShadowView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0.0).isActive = true
            }
        }
    }
    
    private func layoutContentView() {
        if self.enablePopupBarColorsDebug {
            self.contentView.effect = nil
            self.contentView.backgroundColor = UIColor.brown
        }
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        if let topConstraint = self.contentViewTopConstraint {
            topConstraint.constant = self.isFloating ? self.floatingInsets.top : 0.0
        }
        else {
            self.contentViewTopConstraint = self.contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.isFloating ? self.floatingInsets.top : 0.0)
            self.contentViewTopConstraint.isActive = true
        }
        
        if let leftConstraint = self.contentViewLeftConstraint {
            leftConstraint.constant = self.isFloating ? self.floatingInsets.left : 0.0
        }
        else {
            self.contentViewLeftConstraint = self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: self.isFloating ? self.floatingInsets.left : 0.0)
            self.contentViewLeftConstraint.isActive = true
        }
        
        if let rightConstraint = self.contentViewRightConstraint {
            rightConstraint.constant = self.isFloating ? -self.floatingInsets.right : 0.0
        }
        else {
            self.contentViewRightConstraint = self.contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: self.isFloating ? -self.floatingInsets.right : 0.0)
            self.contentViewRightConstraint.isActive = true
        }
        var bottom: CGFloat = 0
        if let bottomBar = self.popupController.containerViewController.bottomBar {
            bottom = (bottomBar.frame.height == 0 || bottomBar.isHidden) ? self.safeBottom() : 0.0
        }
        var constant = self.frame.height - bottom
        if self.isFloating {
            constant -= (self.floatingInsets.top + self.floatingInsets.bottom)
        }
        if let heightConstraint = self.contentViewHeightConstraint {
            heightConstraint.constant = constant
        }
        else {
            self.contentViewHeightConstraint = self.contentView.heightAnchor.constraint(equalToConstant: constant)
            self.contentViewHeightConstraint.isActive = true
        }
    }
    
    private func layoutToolbar() {
        if self.enablePopupBarColorsDebug {
            self.toolbar.layer.borderColor = UIColor.orange.cgColor
            self.toolbar.layer.borderWidth = 2.0
        }
        self.toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        self.toolbar.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0).isActive = true
        self.toolbar.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0.0).isActive = true
        self.toolbar.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0.0).isActive = true
        self.toolbar.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0).isActive = true
    }
    
    private func layoutImageView() {
        let safeLeading = self.safeLeading()
        let safeTrailing = self.safeTrailing()
        var height = self.popupBarHeight
        if self.isFloating {
            height -= (self.floatingInsets.top + self.floatingInsets.bottom)
        }
        let imageHeight = self.isFloating ? PBPopupBarImageHeightFloating : (self.popupBarStyle == .prominent || self.popupBarStyle == .custom) ? PBPopupBarImageHeightProminent : PBPopupBarImageHeightCompact
        
        if let topConstraint = self.imageViewTopConstraint {
            topConstraint.constant = (height - imageHeight) / 2
            if self.isFloating {
                topConstraint.constant += self.floatingInsets.top
            }
        }
        else {
            var constant = (height - imageHeight) / 2
            if self.isFloating {
                constant += self.floatingInsets.top
            }
            self.imageViewTopConstraint = self.shadowImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: constant)
        }
        self.imageViewTopConstraint.isActive = true
        
        self.imageViewLeftConstraint?.isActive = false
        self.imageViewRightConstraint?.isActive = false
        
        if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight {
            if let leftConstraint = self.imageViewLeftConstraint {
                leftConstraint.constant = 16.0 + safeLeading + (self.isFloating ? self.floatingInsets.right : 0.0)
            }
            else {
                self.imageViewLeftConstraint = self.shadowImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16.0 + safeLeading + (self.isFloating ? self.floatingInsets.right : 0.0))
            }
            self.imageViewLeftConstraint.isActive = true
        }
        else {
            if let rightConstraint = self.imageViewRightConstraint {
                rightConstraint.constant = -(16.0 + safeLeading + safeTrailing + (self.isFloating ? self.floatingInsets.left : 0.0))
            }
            else {
                self.imageViewRightConstraint = self.shadowImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -(16.0 + safeLeading + safeTrailing + (self.isFloating ? self.floatingInsets.left : 0.0)))
            }
            self.imageViewRightConstraint.isActive = true
        }
        
        if let widthConstraint = self.imageViewWidthConstraint {
            widthConstraint.constant = imageHeight
        }
        else {
            self.imageViewWidthConstraint = self.shadowImageView.widthAnchor.constraint(equalToConstant: imageHeight)
        }
        self.imageViewWidthConstraint.isActive = true
        
        if let heightConstraint = self.imageViewHeightConstraint {
            heightConstraint.constant = imageHeight
        }
        else {
            self.imageViewHeightConstraint = self.shadowImageView.heightAnchor.constraint(equalToConstant: imageHeight)
        }
        self.imageViewHeightConstraint.isActive = true
        
        self.shadowImageView.isHidden = ((self.image == nil && self.imageController == nil) ||/* self.popupBarStyle == .compact*/ self.popupBarStyle != .prominent)
        
        self.shadowImageView.layoutIfNeeded()
    }
    
    private func layoutTitlesView() {
        let xPositions = self.getMostLeftAndRightItemsXPositions()
        
        var left = xPositions[0]
        var right = xPositions[1]
        
        if left < 0.0 {left = 0.0}
        
        if right < 0.0 {right = 0.0}
        
        let hasImage: Bool = self.image != nil || self.imageController != nil
        
        if left == 0.0 && right == 0.0 {
            if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight {
                left = 16 + (hasImage ? (self.shadowImageView.frame.origin.x + self.shadowImageView.frame.size.width) : 0.0)
                right = 16
            }
            else {
                right = self.frame.size.width - (hasImage ? (self.shadowImageView.frame.origin.x) : 0.0) + 16
                left = 16
            }
        }
        else {
            let safeLeading = self.safeLeading()
            let safeTrailing = self.safeTrailing()
            
            if self.popupBarStyle == .prominent || self.popupBarStyle == .custom {
                if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight {
                    left = hasImage ? 16 + safeLeading + (self.isFloating ? PBPopupBarImageHeightFloating : PBPopupBarImageHeightProminent) + 16.0 : 16.0 + safeLeading
                    right = self.toolbar.frame.size.width - right - safeLeading
                }
                else {
                    right = hasImage ? self.shadowImageView.frame.size.width + 2 * 16.0 + safeLeading + safeTrailing : 16.0 + safeLeading + safeTrailing
                }
            }
            else {
                if left == 0 {
                    left = 16
                }
                left += safeLeading
                if left > right {right = self.toolbar.frame.size.width}
                right = self.toolbar.frame.size.width - right - safeLeading
            }
        }
        
        if self.enablePopupBarColorsDebug {
            self.titlesView.backgroundColor = UIColor.yellow
        }
        
        if self.titlesView.translatesAutoresizingMaskIntoConstraints == true {
            self.titlesView.translatesAutoresizingMaskIntoConstraints = false
            
            self.titlesView.topAnchor.constraint(equalTo: self.toolbar.topAnchor, constant: self.titlesView.isHidden ? 0.0 : 8.0).isActive = true
            self.titlesView.bottomAnchor.constraint(equalTo: self.toolbar.bottomAnchor, constant: self.titlesView.isHidden ? 0.0 : -8.0).isActive = true
        }
        
        if let leftConstraint = self.titlesViewLeftConstraint {
            leftConstraint.constant = left
        }
        else {
            self.titlesViewLeftConstraint = self.titlesView.leftAnchor.constraint(equalTo: self.toolbar.leftAnchor, constant: left)
        }
        self.titlesViewLeftConstraint.isActive = true
        
        if let rightConstraint = self.titlesViewRightConstraint {
            rightConstraint.constant = -right
        }
        else {
            self.titlesViewRightConstraint = self.titlesView.rightAnchor.constraint(equalTo: self.toolbar.rightAnchor, constant: -right)
        }
        self.titlesViewRightConstraint.isActive = true
    }
    
    private func configureAccessibility() {
        if let accessibilityLabel = self.accessibilityLabel, accessibilityLabel.count > 0 {
            self.titlesView.accessibilityLabel = accessibilityLabel
        }
        else {
            var accessibility = String()
            if let title = self.title {
                accessibility = title + "\n"
            }
            if let subtitle = self.subtitle {
                accessibility += subtitle
            }
            self.titlesView.accessibilityLabel = accessibility
        }
        
        if let accessibilityHint = self.accessibilityHint, accessibilityHint.count > 0 {
            self.titlesView.accessibilityHint = accessibilityHint
        }
        else {
            self.titlesView.accessibilityHint = NSLocalizedString("Double tap to open popup content", comment: "")
        }
    }
    
    private func removeTitleLabels() {
        if let titleLabel = self.titleLabel {
            titleLabel.removeFromSuperview()
            self.titlesView.removeArrangedSubview(titleLabel)
            self.titleLabel = nil
        }
        if let subtitleLabel = self.subtitleLabel {
            subtitleLabel.removeFromSuperview()
            self.titlesView.removeArrangedSubview(subtitleLabel)
            self.subtitleLabel = nil
        }
        
        self.setNeedsLayout()
                
        self.askForLabels = true
        self.configureTitleLabels()
    }

    private func configureTitleLabels() {
        if self.askForLabels {
            self.askForLabels = false
            if let titleLabel = self.dataSource?.titleLabel?(for: self) {
                if let oldTitleLabel = self.titleLabel {
                    oldTitleLabel.removeFromSuperview()
                    self.titlesView.removeArrangedSubview(oldTitleLabel)
                }
                self.titlesView.insertArrangedSubview(titleLabel, at: 0)
                self.titleLabel = titleLabel
            }
            
            if let subtitleLabel = self.dataSource?.subtitleLabel?(for: self) {
                if let oldSubtitleLabel = self.subtitleLabel {
                    oldSubtitleLabel.removeFromSuperview()
                    self.titlesView.removeArrangedSubview(oldSubtitleLabel)
                }
                self.titlesView.addArrangedSubview(subtitleLabel)
                self.subtitleLabel = subtitleLabel
            }
        }
        
        if self.titleLabel == nil {
            self.titleLabel = newTitleLabel()
            self.titlesView.insertArrangedSubview(self.titleLabel!, at: 0)
        }
        if self.enablePopupBarColorsDebug {
            self.titleLabel?.backgroundColor = UIColor.magenta.withAlphaComponent(0.5)
        }
        self.titleLabel?.isHidden = self.title == nil

        if self.subtitleLabel == nil {
            self.subtitleLabel = newTitleLabel()
            self.titlesView.addArrangedSubview(self.subtitleLabel!)
        }
        if self.enablePopupBarColorsDebug {
            self.subtitleLabel?.backgroundColor = UIColor.cyan.withAlphaComponent(0.5)
        }
        self.subtitleLabel?.isHidden = self.subtitle == nil

        let paragraphStyle = NSMutableParagraphStyle()
        
        if self.popupBarStyle == .compact {
            paragraphStyle.alignment = .center
            self.titleLabel?.textAlignment = .center
            self.subtitleLabel?.textAlignment = .center
        } else {
            paragraphStyle.alignment = .natural
            self.titleLabel?.textAlignment = .natural
            self.subtitleLabel?.textAlignment = .natural
            
            if self.semanticContentAttribute == .forceRightToLeft {
                paragraphStyle.alignment = .right
                self.titleLabel?.textAlignment = .right
                self.subtitleLabel?.textAlignment = .right
            }
        }
        
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let defaultTitleAttribures: NSMutableDictionary = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        if (self.titleTextAttributes != nil) {
            defaultTitleAttribures.addEntries(from: self.titleTextAttributes!)
        }
                
        if (self.title != nil)
        {
            self.titleLabel?.attributedText = NSAttributedString(string: self.title!, attributes: (defaultTitleAttribures as! [NSAttributedString.Key : Any]))
        }
        else {
            self.titleLabel?.text = nil
        }

        let defaultSubtitleAttribures: NSMutableDictionary = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        if (self.subtitleTextAttributes != nil) {
            defaultSubtitleAttribures.addEntries(from: self.subtitleTextAttributes!)
        }
                
        if (self.subtitle != nil)
        {
            self.subtitleLabel?.attributedText = NSAttributedString(string: self.subtitle!, attributes: (defaultSubtitleAttribures as! [NSAttributedString.Key : Any]))
        }
        else {
            self.subtitleLabel?.text = nil
        }
    }
    
    private func newTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.isAccessibilityElement = true
        titleLabel.backgroundColor = UIColor.clear
        return titleLabel
    }
    
    private func titleFont() -> UIFont {
        var fontSize: CGFloat = 15
        var fontWeight: UIFont.Weight = .medium
        var textStyle: UIFont.TextStyle = .body
        
        switch self.popupBarStyle {
        case .prominent:
            fontSize = self.isFloating ? 15 : 15
            fontWeight = self.isFloating ? .medium : .medium
            textStyle = self.isFloating ? .headline : .body
        case .compact:
            fontSize = self.isFloating ? 13.5 : 13.5
            fontWeight = self.isFloating ? .regular : .regular
            textStyle = self.isFloating ? .subheadline : .subheadline
        default:
            break
        }
        //let font = self.preferredFontFor(textStyle: textStyle, weight: fontWeight)
        
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: UIFont.systemFont(ofSize: fontSize, weight: fontWeight))
    }
    
    private func titleColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.darkText
        }
    }
    
    private func subtitleFont() -> UIFont {
        var fontSize: CGFloat = 15
        var fontWeight: UIFont.Weight = .regular
        var textStyle: UIFont.TextStyle = .body
        
        switch self.popupBarStyle {
        case .prominent:
            fontSize = self.isFloating ? 12.5 : 15
            fontWeight = self.isFloating ? .regular : .regular
            textStyle = self.isFloating ? .subheadline : .body
        case .compact:
            fontSize = self.isFloating ? 12 : 12
            fontWeight = self.isFloating ? .regular : .regular
            textStyle = self.isFloating ? .subheadline : .subheadline
        default:
            break
        }
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: UIFont.systemFont(ofSize: fontSize, weight: fontWeight))
    }
    
    private func subtitleColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        }
        else {
            return UIColor.darkGray
        }
    }
    
    private func configureContentSizeCategory() {
        if #available(iOS 15.0, *) {
            self.minimumContentSizeCategory = self.popupBarStyle == .prominent ? .medium : .small
            self.maximumContentSizeCategory = self.popupBarStyle == .prominent ? .accessibilityLarge : self.isFloating ? .small : .accessibilityMedium
        }
    }
    
    /*
    private func preferredFontFor(textStyle: UIFont.TextStyle, weight: UIFont.Weight? = nil) -> UIFont {
        let preferredContentSizeCategory: UIContentSizeCategory
        switch UIApplication.shared.preferredContentSizeCategory {
        case .extraSmall, .small, .medium:
            preferredContentSizeCategory = .large
        case .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            preferredContentSizeCategory =  .accessibilityLarge
        default:
            preferredContentSizeCategory = UIApplication.shared.preferredContentSizeCategory
        }
        let traitCollection = UITraitCollection(preferredContentSizeCategory: preferredContentSizeCategory)
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle, compatibleWith: traitCollection)
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        let font: UIFont
        if let weight = weight {
            font = UIFont.systemFont(ofSize: fontDescriptor.pointSize, weight: weight)
        } else {
            font = UIFont.systemFont(ofSize: fontDescriptor.pointSize)
        }
        return fontMetrics.scaledFont(for: font, maximumPointSize: fontDescriptor.pointSize, compatibleWith: traitCollection)
    }
    */
    
    private func layoutToolbarItems() {
        let barItemsLayoutDirection = UIView.userInterfaceLayoutDirection(for: self.barButtonItemsSemanticContentAttribute)
        let layoutDirection = UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute)
        
        let isReversed = barItemsLayoutDirection != layoutDirection
        
        let flexibleBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        flexibleBarButtonItem.tag = 999
        if let leftBarButtonItems = self.leftBarButtonItems, self.popupBarStyle == .compact {
            self.toolbar.setItems(!isReversed ? leftBarButtonItems : leftBarButtonItems.reversed(), animated: false)
            if let rightBarButtonItems = self.rightBarButtonItems {
                self.toolbar.setItems((!isReversed ? leftBarButtonItems : leftBarButtonItems.reversed()) + [flexibleBarButtonItem] + (!isReversed ? rightBarButtonItems : rightBarButtonItems.reversed()), animated: false)
            }
        }
        else {
            if let rightBarButtonItems = self.rightBarButtonItems {
                self.toolbar.setItems([flexibleBarButtonItem] + (!isReversed ? rightBarButtonItems : rightBarButtonItems.reversed()), animated: false)
            }
        }
    }
    
    private func layoutProgressView() {
        self.progressView.isHidden = self.progressViewStyle == .none
        
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: UIView] = ["view": (self.progressView)!]
        
        if let verticalConstraints = self.progressViewVerticalConstraints {
            NSLayoutConstraint.deactivate(verticalConstraints)
        }
        
        if self.progressViewStyle == .top {
            self.progressViewVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view(1.5)]", options: [], metrics: nil, views: views)
        } else {
            self.progressViewVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[view(1.5)]|", options: [], metrics: nil, views: views)
        }
        NSLayoutConstraint.activate(self.progressViewVerticalConstraints)
        
        if let horizontalConstraints = self.progressViewHorizontalConstraints {
            NSLayoutConstraint.deactivate(horizontalConstraints)
        }
        if self.isFloating {
            let format = String(format: "H:|-%f-[view]-%f-|", self.floatingRadius, self.floatingRadius)
            self.progressViewHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: views)
        }
        else {
            self.progressViewHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        }
        NSLayoutConstraint.activate(self.progressViewHorizontalConstraints)
    }
    
    private func layoutHighlightView() {
        if self.highlightView.window != nil, self.highlightView.translatesAutoresizingMaskIntoConstraints == true {
            self.highlightView.translatesAutoresizingMaskIntoConstraints = false
            
            self.highlightView.topAnchor.constraint(equalTo: (self.superview?.topAnchor)!, constant: 0.0).isActive = true
            self.highlightView.leftAnchor.constraint(equalTo: (self.superview?.leftAnchor)!, constant: 0.0).isActive = true
            self.highlightView.bottomAnchor.constraint(equalTo: (self.superview?.bottomAnchor)!, constant: 0.0).isActive = true
            self.highlightView.rightAnchor.constraint(equalTo: (self.superview?.rightAnchor)!, constant: 0.0).isActive = true
        }
    }
    
    private func layoutBorderView() {
        self.borderView.isHidden = self.borderViewStyle == .none
        
        self.borderView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: UIView] = ["view": (self.borderView)!, "imageView": (self.shadowImageView)]
        let height = self.popupBarHeight
        let imageHeight = (self.popupBarStyle == .prominent || self.popupBarStyle == .custom) ? PBPopupBarImageHeightProminent : PBPopupBarImageHeightCompact
        let metrics = ["verticalPadding": (height - imageHeight) / 2]
        
        if let horizontalConstraints = self.borderViewHorizontalConstraints {
            NSLayoutConstraint.deactivate(horizontalConstraints)
        }
        
        if self.borderViewStyle == .left {
            self.borderViewHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view(1)]", options: [], metrics: nil, views: views)
        } else {
            self.borderViewHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[view(1)]|", options: [], metrics: nil, views: views)
        }
        NSLayoutConstraint.activate(self.borderViewHorizontalConstraints)
        
        if let verticalConstraints = self.borderViewVerticalConstraints {
            NSLayoutConstraint.deactivate(verticalConstraints)
        }
        self.borderViewVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-verticalPadding-[view]-verticalPadding-|", options: [], metrics: metrics, views: views)
        NSLayoutConstraint.activate(self.borderViewVerticalConstraints)
    }
    
    private func getMostLeftAndRightItemsXPositions() -> [CGFloat] {
        var left: CGFloat = 0.0
        var right: CGFloat = 0.0
        
        if let toolbarItems = self.toolbar.items, toolbarItems.count > 0 {
            let items = toolbarItems as NSArray
            
            var index: Int = -1
            // Find the flexible space
            for i in 0..<items.count {
                if (items[i] as! UIBarButtonItem).tag == 999 {
                    index = i
                    break
                }
            }
            
            var leftItems: NSArray
            var rightItems: NSArray
            
            if index == -1 {
                leftItems = items.subarray(with: NSMakeRange(0, items.count - 1)) as NSArray
                rightItems = items.subarray(with: NSMakeRange(0, 0)) as NSArray
            }
            else {
                leftItems = items.subarray(with: NSMakeRange(0, index > 0 ? index : 0)) as NSArray
                rightItems = items.subarray(with: NSMakeRange(index + 1, items.count - (index + 1))) as NSArray
            }
            
            if leftItems.count > 0 {
                // If LTR: leftItems will be at left: return the frame of last one + width in left variable
                if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight {
                    if let leftItemView = (leftItems[leftItems.count - 1] as AnyObject).value(forKey: "view") as? UIView {
                        if self.enablePopupBarColorsDebug {
                            leftItemView.backgroundColor = UIColor.green
                        }
                        if leftItemView.superview?.classForCoder == itemClass11 {
                            left = leftItemView.superview!.frame.origin.x + leftItemView.superview!.frame.size.width
                        }
                        else {
                            left = leftItemView.frame.origin.x + leftItemView.frame.size.width
                        }
                        if leftItemView.subviews.count > 0 {
                            if let subview = leftItemView.subviews[0] as UIView?, subview.classForCoder == itemClass10 {
                                left += -subview.frame.origin.x
                            }
                        }
                    }
                }
                else {
                    // If RTL: leftItems will be at right: return the frame of last one in right variable
                    if let leftItemView = (leftItems[leftItems.count - 1] as AnyObject).value(forKey: "view") as? UIView {
                        if self.enablePopupBarColorsDebug {
                            leftItemView.backgroundColor = UIColor.green
                        }
                        if leftItemView.superview?.classForCoder == itemClass11 {
                            right = leftItemView.superview!.frame.origin.x
                        }
                        else {
                            right = leftItemView.frame.origin.x
                        }
                        if leftItemView.subviews.count > 0 {
                            if let subview = leftItemView.subviews[0] as UIView?, subview.classForCoder == itemClass10 {
                                right += subview.frame.origin.x
                            }
                        }
                    }
                }
            }
            
            if rightItems.count > 0 {
                // If LTR: rightItems will be at right: return the frame of first one in right variable
                if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight {
                    if let rightItemView = (rightItems[0] as AnyObject).value(forKey: "view") as? UIView {
                        if self.enablePopupBarColorsDebug {
                            rightItemView.backgroundColor = UIColor.green
                        }
                        if rightItemView.superview?.classForCoder == itemClass11 {
                            right = rightItemView.superview!.frame.origin.x
                        }
                        else {
                            right = rightItemView.frame.origin.x
                        }
                        if rightItemView.subviews.count > 0 {
                            if let subview = rightItemView.subviews[0] as UIView?, subview.classForCoder == itemClass10 {
                                right += subview.frame.origin.x
                            }
                        }
                        if NSStringFromClass(type(of: rightItemView).self).contains("HostingView") {
                            right -= 16
                        }
                    }
                }
                else {
                    // If RTL: rightItems will be at left: return the frame of first one + width in left variable
                    if let rightItemView = (rightItems[0] as AnyObject).value(forKey: "view") as? UIView {
                        if self.enablePopupBarColorsDebug {
                            rightItemView.backgroundColor = UIColor.green
                        }
                        if rightItemView.superview?.classForCoder == itemClass11 {
                            left = rightItemView.superview!.frame.origin.x + rightItemView.superview!.frame.size.width
                        }
                        else {
                            left = rightItemView.frame.origin.x + rightItemView.frame.size.width
                        }
                        if rightItemView.subviews.count > 0 {
                            if let subview = rightItemView.subviews[0] as UIView?, subview.classForCoder == itemClass10 {
                                left += -subview.frame.origin.x
                            }
                        }
                        if NSStringFromClass(type(of: rightItemView).self).contains("HostingView") {
                            left += 16
                        }
                    }
                }
            }
        }
        return [left, right]
    }
}

extension PBPopupBar
{
    // MARK: - Helpers
    
    internal func safeLeading() -> CGFloat {
        var safeLeading: CGFloat = 0.0
        safeLeading = max(self.safeAreaInsets.left, safeLeading)
        return safeLeading
    }
    
    internal func safeTrailing() -> CGFloat {
        var safeTrailing: CGFloat = 0.0
        safeTrailing = max(self.safeAreaInsets.right, safeTrailing)
        return safeTrailing
    }
    
    internal func safeBottom() -> CGFloat {
        var safeBottom: CGFloat = 0.0
        if let dropShadowView = self.popupController.dropShadowViewFor(self.popupController.containerViewController.view) {
            if dropShadowView.frame.minX > 0 {
                return 0.0
            }
        }
        guard (self.window != nil) else { return 0.0 }
        safeBottom = max((self.window?.safeAreaInsets.bottom)!, safeBottom)
        return safeBottom
    }
    
    func logDirection() {
        if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight {
            PBLog("userInterfaceLayoutDirection: Left To Right")
        }
        if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .rightToLeft {
            PBLog("userInterfaceLayoutDirection: Right To Left")
        }
    }
}

// MARK: - Custom views

extension PBPopupBar
{
    /**
     Custom views For Debug View Hierarchy Names
     */
    internal class _PBPopupBarTitlesView: UIStackView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.axis = .vertical
            self.distribution = .fillEqually
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    internal class _PBPopupBarProgressView: UIProgressView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    internal class _PBPopupBarHighlightView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    internal class _PBPopupBarBorderView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    internal class _PBPopupBarContentView: _PBPopupBackgroundEffectShadowView {
        override init(effect: UIVisualEffect?) {
            super.init(effect: effect)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    internal class _PBPopupBackgroundEffectShadowView: UIView {
        var enablePopupBarColorsDebug: Bool = false
        var effectView: UIVisualEffectView!
        var effect: UIVisualEffect! {
            didSet {
                if let effectView = self.effectView {
                    effectView.effect = effect
                }
            }
        }
        
        var floatingInset: UIEdgeInsets!
        
        var customView: UIView? {
            didSet {
                if let customView = customView {
                    self.addSubview(customView)
                }
            }
        }
        var colorView: UIView!
        var imageView: UIImageView!
        
        var cornerRadius: CGFloat = 0 {
            didSet {
                self.layer.cornerRadius = cornerRadius
                if #available(iOS 13.0, *) {
                    self.layer.cornerCurve = .continuous
                }
                
                if let effectView = self.effectView {
                    effectView.layer.cornerRadius = cornerRadius
                    if #available(iOS 13.0, *) {
                        effectView.layer.cornerCurve = .continuous
                    }
                }
            }
        }
        
        var castsShadow: Bool = false {
            didSet {
                if castsShadow
                {
                    self.layer.shadowColor = self.enablePopupBarColorsDebug ? UIColor.green.cgColor : UIColor.black.cgColor
                    self.layer.shadowOffset = .zero
                    self.layer.shadowOpacity = self.enablePopupBarColorsDebug ? 0.85 : 0.15
                    self.layer.shadowRadius = 8.0
                }
                else
                {
                    self.layer.shadowColor = UIColor.black.cgColor
                    self.layer.shadowOffset = .zero
                    //self.layer.shadowOpacity = 0.0
                    self.layer.shadowOpacity = 0.01
                    //self.layer.shadowRadius = 0.0
                    self.layer.shadowRadius = 8.0
                }
            }
        }

        init(effect: UIVisualEffect?) {
            super.init(frame: .zero)
            
            self.effectView = UIVisualEffectView(effect: effect)
            self.effectView.clipsToBounds = true
            
            self.colorView = UIView()
            self.imageView = UIImageView()
            
            self.cornerRadius = 0
            self.castsShadow = false

            self.layer.masksToBounds = false
            
            if let effectView = self.effectView {
                effectView.contentView.addSubview(self.colorView)
                effectView.contentView.addSubview(self.imageView)
                self.addSubview(effectView)
            }
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override  func layoutSubviews() {
            super.layoutSubviews()
            
            if let effectView = self.effectView {
                effectView.frame = self.bounds;
                
                self.imageView.frame = effectView.contentView.bounds
                self.colorView.frame = effectView.contentView.bounds
                
                effectView.contentView.sendSubviewToBack(self.imageView)
                effectView.contentView.sendSubviewToBack(self.colorView)
            }

            if let customView = self.customView {
                customView.frame = self.bounds
                self.effectView.isHidden = !customView.isHidden
            }
        }
    }

    internal class _PBPopupBackgroundShadowView: UIView {
        var colorToken: NSKeyValueObservation?
        var offsetToken: NSKeyValueObservation?
        var radiusToken: NSKeyValueObservation?
        
        var userFloatingBackgroundShadow: NSShadow!
        var lightShadowColor: UIColor!
        var darkShadowColor: UIColor!

        var shadow: NSShadow! {
            didSet {
                self.layer.shadowOffset = shadow.shadowOffset
                self.layer.shadowRadius = shadow.shadowBlurRadius
                
                self.updateShadowColor()
                
                self.setNeedsLayout()
                
                self.colorToken = self.userFloatingBackgroundShadow.observe(\.shadowColor, options: .new) { (shadowColor, change) in
                    self.updateShadowColor()
                }

                self.offsetToken = self.userFloatingBackgroundShadow.observe(\.shadowOffset, options: .new) { (shadowOffset, change) in
                    guard let shadowOffset = change.newValue else { return }
                    self.layer.shadowOffset = shadowOffset
                }
                
                self.radiusToken = self.userFloatingBackgroundShadow.observe(\.shadowBlurRadius, options: .new) { (shadowBlurRadius, change) in
                    guard let shadowBlurRadius = change.newValue else { return }
                    self.layer.shadowRadius = shadowBlurRadius
                }
            }
        }
        
        var maskLayer: CAShapeLayer!
        
        var cornerRadius: CGFloat!
        
        var floatingInset: UIEdgeInsets!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
                        
            self.maskLayer = CAShapeLayer()
            self.maskLayer.fillRule = .evenOdd
            self.layer.mask = self.maskLayer
            self.layer.shouldRasterize = true

            if #available(iOS 17.0, *) {
                self.registerForTraitChanges([UITraitDisplayScale.self, UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                    self.layer.rasterizationScale = self.traitCollection.displayScale
                    if let userShadow = self.userFloatingBackgroundShadow, userShadow.shadowColor == nil {
                        self.shadow.shadowColor = self.traitCollection.userInterfaceStyle == .light ? self.lightShadowColor : self.darkShadowColor
                        self.updateShadowColor()
                    }
                }
            }
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            PBLog("deinit \(self)")
        }
        
        func updateShadowColor() {
            if let userShadow = self.userFloatingBackgroundShadow, let shadowColor = userShadow.shadowColor as? UIColor {
                self.layer.shadowColor = shadowColor.withAlphaComponent(1.0).cgColor
                self.layer.shadowOpacity = Float(shadowColor.cgColor.alpha)
            }
            else {
                if let shadow = self.shadow, let shadowColor = shadow.shadowColor as? UIColor {
                    self.layer.shadowColor = shadowColor.withAlphaComponent(1.0).cgColor
                    self.layer.shadowOpacity = Float(shadowColor.cgColor.alpha)
                }
            }
        }
        
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            
            self.layer.rasterizationScale = self.traitCollection.displayScale
            if #available(iOS 13.0, *) {
                if let userShadow = self.userFloatingBackgroundShadow, userShadow.shadowColor == nil {
                    self.shadow.shadowColor = self.traitCollection.userInterfaceStyle == .light ? self.lightShadowColor : self.darkShadowColor
                }
            }
            else {
                self.shadow.shadowColor = self.lightShadowColor
            }
            self.updateShadowColor()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            if let shadow = self.shadow {
                let dx = 2 * shadow.shadowBlurRadius + abs(shadow.shadowOffset.width)
                let dy = 2 * shadow.shadowBlurRadius + abs(shadow.shadowOffset.height)
                
                self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius).cgPath
                self.maskLayer.frame = CGRectInset(self.bounds, -dx, -dy)
                
                let maskPath = UIBezierPath(rect: self.maskLayer.bounds)
                maskPath.append(UIBezierPath(roundedRect: CGRectInset(self.maskLayer.bounds, dx, dy), cornerRadius: self.cornerRadius))
                maskPath.usesEvenOddFillRule = true
                self.maskLayer.path = maskPath.cgPath
            }
        }
    }
    
    internal class _PBPopupBackgroundMaskView: UIView {
        var gradient: CGGradient!
        var isSmooth: Bool = false
        
        convenience init(frame: CGRect, smooth: Bool = false) {
            self.init(frame: frame)
            
            self.isSmooth = smooth
            
            self.backgroundColor = .clear

            let color1 = UIColor.clear
            let color2 = UIColor.black
            
            if smooth {
                self.gradient = CGGradient.with(easing: .easeInOutSine, from: color1, to: color2)
            }
            else {
                let colors = [color1.cgColor, color2.cgColor]
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let colorLocations: [CGFloat] = [0.0, 1.0]
                self.gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            guard let gradient = self.gradient else { return }
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            UIGraphicsPushContext(context)
            let startPoint = CGPoint(x: bounds.width / 2, y: self.isSmooth ? 0.0 : 0.0)
            let endPoint = CGPoint(x: bounds.width / 2, y: bounds.height)
            context.drawLinearGradient(
                gradient,
                start: startPoint,
                end: endPoint,
                options: []
            )
            UIGraphicsPopContext()
        }
    }
    
    internal class _PBPopupSafeAreaBackgroundView: UIVisualEffectView {
        override init(effect: UIVisualEffect?) {
            super.init(effect: effect)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

