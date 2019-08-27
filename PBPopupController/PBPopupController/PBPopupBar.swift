//
//  PBPopupBar.swift
//  PBPopupController
//
//  Created by Patrick BODET on 29/03/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
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
        if (ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 10) {
            return .compact
        }
        return .prominent
    }()
}

extension PBPopupBarStyle {
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
        if (ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 10) {
            return .bottom
        }
        return .none
    }()
}

extension PBPopupBarProgressViewStyle {
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

// _UITAMICAdaptorView
private let itemClass11: AnyClass? = NSClassFromString(_PBPopupDecodeBase64String(base64String: "X1VJVEFNSUNBZGFwdG9yVmlldw==")!)
// _UIToolbarNavigationButton
private let itemClass10: AnyClass? = NSClassFromString(_PBPopupDecodeBase64String(base64String: "X1VJVG9vbGJhck5hdmlnYXRpb25CdXR0b24=")!)

internal let PBPopupBarHeightCompact: CGFloat = 48.0//40.0
internal let PBPopupBarHeightProminent: CGFloat = 64.0
internal let PBPopupBarImageHeightProminent: CGFloat = 48.0
internal let PBPopupBarImageHeightCompact: CGFloat = 40.0//32.0

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
     
     - returns: A UIlabel object to be used instead of the default one.
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
 A popup bar presented with a content view controller such as a `UITabBarController`, a `UINavigationController`, a `UIViewController` or a custom container view controller. The user can swipe or tap the popup bar at any point to present the popup content view controller. After presenting, the user dismisses the popup content view controller by either swiping or tapping an optional popup close button. The contents of the popup bar is built dynamically using its own properties. The popup bar may be a custom one if `PBPopupBar.customPopupBarViewController` is set.
 
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
    @objc public var PBPopupBarShowColors: Bool = false
    
    /**
     The popup bar presentation duration when presenting from hidden to closed state.
     
     - Seealso: `PBPopupContentView.popupPresentationDuration`.
     */
    @objc public var popupBarPresentationDuration: TimeInterval = 0.6
    
    /**
     The tap gesture recognizer attached to the popup bar for presenting the popup content view.
     */
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
     If `true`, the popup bar will automatically inherit its style from the bottom bar.
     */
    @objc public var inheritsVisualStyleFromBottomBar: Bool = true {
        didSet {
            if inheritsVisualStyleFromBottomBar == true {
                self.popupController.containerViewController._configurePopupBarFromBottomBar()
            }
        }
    }
    
    /**
     The popup bar style (see PBPopupBarStyle).
     */
    @objc public var popupBarStyle: PBPopupBarStyle = .default {
        willSet {
            PBLog("The value of popupBarStyle will change from \(popupBarStyle.description) to \(newValue.description)")
            customPopupBarViewController?.view.removeFromSuperview()
        }
        didSet {
            PBLog("The value of popupBarStyle changed from \(oldValue.description) to \(popupBarStyle.description)")
            if popupBarStyle == .custom {
                if self.customPopupBarViewController == nil {
                    PBLog("Custom popuBar view controller cannot be nil.", error: true)
                }
                assert(self.customPopupBarViewController != nil, "Custom popuBar view controller cannot be nil.")
                if self.customPopupBarViewController == nil {
                    NSException.raise(NSExceptionName.internalInconsistencyException, format: "Custom popuBar view controller cannot be nil.", arguments: getVaList([]))
                }
            }
            self.setupCustomPopupBarView()
            
            self.layoutToolbarItems()
            self.configureTitleLabels()
            
            self.setNeedsLayout()

            if self.popupController.popupPresentationState != .hidden && oldValue != popupBarStyle {
                self.popupController.popupPresentationState = .hidden
                let vc = self.popupController.containerViewController!
                _LNPopupSupportFixInsetsForViewController(vc, false,  oldValue == .custom ? -(customPopupBarViewController?.preferredContentSize.height)! : oldValue == .prominent ? -PBPopupBarHeightProminent : -PBPopupBarHeightCompact)
                self.popupController._presentPopupBarAnimated(true)
            }
        }
    }
    
    /**
     The bar style of the popup bar' toolbar.
     */
    @objc public var barStyle: UIBarStyle {
        get {
            return self.toolbar.barStyle
        }
        set(newValue) {
            self.systemBarStyle = newValue
            self.popupController.systemBarStyle = newValue
            if #available(iOS 13.0, *) {
                self.backgroundView.backgroundColor = nil
                self.safeAreaBackgroundView.backgroundColor = nil
            }
            else {
                if newValue == .black {
                    self.backgroundView.backgroundColor = UIColor.clear
                    if #available(iOS 11.0, *) {
                        self.safeAreaBackgroundView.backgroundColor = UIColor.clear
                    }
                }
                else {
                    self.backgroundView.backgroundColor = UIColor(white: 230.0 / 255.0, alpha: 0.5)
                    if #available(iOS 11.0, *) {
                        self.safeAreaBackgroundView.backgroundColor = UIColor(white: 230.0 / 255.0, alpha: 0.5)
                    }
                }
            }
            self.toolbar.barStyle = newValue
        }
    }
    
    /**
     The popup bar background style that specifies its visual effect appearance.
     
     - SeeAlso: `UIBlurEffect.Style`
     */
    @objc public var backgroundStyle: UIBlurEffect.Style {
        get {
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                if self.systemBarStyle == .black {
                    return .systemChromeMaterialDark
                }
                return .systemChromeMaterial
            }
            #endif
            return self.systemBarStyle == .black ? .dark : popupBarStyle == .compact ? .extraLight : .light
        }
        set {
            self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            self.backgroundView.effect = UIBlurEffect(style: newValue)
            if #available(iOS 11.0, *) {
                self.safeAreaToolbar?.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
                self.safeAreaBackgroundView?.effect = UIBlurEffect(style: newValue)
            }
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
                self.backgroundView.isHidden = (newValue == false)
                if #available(iOS 11.0, *) {
                    self.safeAreaToolbar?.isTranslucent = newValue
                    self.safeAreaBackgroundView?.isHidden = (newValue == false)
                }
                if self.inheritsVisualStyleFromBottomBar == true {
                    self.backgroundView.effect = nil
                    self.backgroundView.isHidden = true
                    if #available(iOS 11.0, *) {
                        self.safeAreaBackgroundView?.effect = nil
                        self.safeAreaBackgroundView?.isHidden = true
                    }
                }
            }
        }
    }
    
    /**
     The background color of the popup bar' toolbar.
     */
    @objc override public var backgroundColor: UIColor? {
        get {
            return self.toolbar.backgroundColor
        }
        set {
            if self.toolbar.backgroundColor != newValue {
                self.toolbar.setBackgroundImage(newValue == nil ? UIImage() : nil, forToolbarPosition: .any, barMetrics: .default)
                self.toolbar.backgroundColor = newValue
                if #available(iOS 11.0, *) {
                    self.safeAreaToolbar?.setBackgroundImage(newValue == nil ? UIImage() : nil, forToolbarPosition: .any, barMetrics: .default)
                    self.safeAreaToolbar?.backgroundColor = newValue
                }
            }
        }
    }
    
    /**
     The tint color to apply to the popup bar background.
     */
    @objc public var barTintColor: UIColor! {
        
        get {
            return self.toolbar.barTintColor
        }
        set {
            if self.toolbar.barTintColor != newValue {
                self.toolbar.setBackgroundImage(newValue == nil ? UIImage() : nil, forToolbarPosition: .any, barMetrics: .default)
                self.toolbar.barTintColor = newValue
                if #available(iOS 11.0, *) {
                    self.safeAreaToolbar?.setBackgroundImage(newValue == nil ? UIImage() : nil, forToolbarPosition: .any, barMetrics: .default)
                    self.safeAreaToolbar?.barTintColor = newValue
                }
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
            self.imageView?.image = image
            self.layoutImageView()
        }
    }
    
    /**
     An image view displayed when the bar style is prominent. (read-only)
     */
    @objc public internal(set) var imageView: UIImageView!
    
    /**
     The view providing a shadow' layer to the popup bar image view.
     
     - Note: Read-only, but its properties can be set. For example for no shadow, use `popupBar.shadowImageView.layer.shadowOpacity = 0`.
     */
    @objc public private(set) var shadowImageView: PBPopupRoundShadowImageView!
    
    /**
     The popup bar's title.
     
     - Note: If no subtitle is set, the title will be centered vertically.
     */
    @objc public var title: String? {
        didSet {
            self.toolbar.setNeedsLayout()
            self.toolbar.layoutIfNeeded()
            
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
            self.toolbar.setNeedsLayout()
            self.toolbar.layoutIfNeeded()
            
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
            self.toolbar.semanticContentAttribute = semanticContentAttribute
            
            self.toolbar.setNeedsLayout()
            self.toolbar.layoutIfNeeded()
            
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
            self.toolbar.setNeedsLayout()
            self.toolbar.layoutIfNeeded()

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
            self.toolbar.setNeedsLayout()
            self.toolbar.layoutIfNeeded()
            
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
            self.toolbar.setNeedsLayout()
            self.toolbar.layoutIfNeeded()

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
     The accessibility label of the progress, in a localized string.
     */
    @objc public var accessibilityProgressLabel: String?
    
    /**
     The accessibility value of the progress, in a localized string.
     */
    @objc public var accessibilityProgressValue: String?
    
    // MARK: - Private Properties
    
    @objc weak internal var popupController: PBPopupController!
    
    internal var ignoreLayoutDuringTransition: Bool = false
    
    internal var popupBarHeight: CGFloat {
        if self.popupBarStyle == .custom {
            return customPopupBarViewController != nil ? customPopupBarViewController!.preferredContentSize.height : PBPopupBarHeightProminent
        }
        return self.popupBarStyle == .prominent ? PBPopupBarHeightProminent : PBPopupBarHeightCompact
    }
    
    private var systemBarStyle: UIBarStyle!
    
    private var backgroundView: UIVisualEffectView!
    
    private var toolbar: PBPopupToolbar!
    
    private var safeAreaBackgroundView: PBPopupSafeAreaBackgroundView!
    
    private var safeAreaBackgroundViewHeightConstraint: NSLayoutConstraint?
    
    private var safeAreaToolbar: UIToolbar!
    
    private var imageViewTopConstraint: NSLayoutConstraint!
    private var imageViewLeftConstraint: NSLayoutConstraint!
    private var imageViewRightConstraint: NSLayoutConstraint!
    private var imageViewWidthConstraint: NSLayoutConstraint!
    private var imageViewHeightConstraint: NSLayoutConstraint!
    
    // The container view for titleLabel and subtitleLabel
    @objc dynamic private var titlesView: PBPopupBarTitlesView!

    private var titlesViewLeftConstraint: NSLayoutConstraint!
    private var titlesViewRightConstraint: NSLayoutConstraint!
    
    // true if we have to ask for a custom label (i.e. MarqueeLabel)
    private var askForLabels: Bool = false
    
    // The label containing the title text
    private var titleLabel: UILabel!
    
    private var titleLabelCenterConstraint: NSLayoutConstraint!
    private var titleLabelTopConstraint: NSLayoutConstraint!
    private var titleLabelHeightConstraint: NSLayoutConstraint!
    
    // The label containing the subtitle text
    private var subtitleLabel: UILabel!
    
    private var subtitleLabelCenterConstraint: NSLayoutConstraint!
    private var subtitleLabelBottomConstraint: NSLayoutConstraint!
    private var subtitleLabelHeightConstraint: NSLayoutConstraint!
    
    // The progress view (see PBPopupBarProgressViewStyle and progress property)
    @objc dynamic private var progressView: PBPopupBarProgressView!

    private var progressViewVerticalConstraints: [NSLayoutConstraint]!
    private var progressViewHorizontalConstraints: [NSLayoutConstraint]!

    // Highlighted view when taping or paning the popupBar
    @objc dynamic internal var highlightView: PBPopupBarHighlightView!

    // MARK: - Private Init
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizesSubviews = true // default: true
        self.preservesSuperviewLayoutMargins = true // default: false
        
        self.autoresizingMask = []
        
        let effect = UIBlurEffect(style: ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 10 ? .extraLight : self.backgroundStyle)
        self.backgroundView = UIVisualEffectView(effect: effect)
        self.backgroundView.clipsToBounds = false
        self.backgroundView.autoresizingMask = []
        self.backgroundView.isUserInteractionEnabled = false
        if #available(iOS 13.0, *) {
            self.backgroundView.backgroundColor = nil
        }
        else {
            self.backgroundView.backgroundColor = UIColor(white: 230.0 / 255.0, alpha: 0.5)
        }
        self.addSubview(self.backgroundView)
        
        if #available(iOS 11.0, *) {
            self.safeAreaBackgroundView = PBPopupSafeAreaBackgroundView(effect: effect)
            self.safeAreaBackgroundView.autoresizesSubviews = true
            self.safeAreaBackgroundView.clipsToBounds = false
            self.safeAreaBackgroundView.autoresizingMask = []
            self.safeAreaBackgroundView.isUserInteractionEnabled = false
            if #available(iOS 13.0, *) {
                self.safeAreaBackgroundView.backgroundColor = nil
            }
            else {
                self.safeAreaBackgroundView.backgroundColor = UIColor(white: 230.0 / 255.0, alpha: 0.5)
            }
            self.addSubview(self.safeAreaBackgroundView)
            
            self.safeAreaToolbar = UIToolbar()
            self.safeAreaToolbar.autoresizingMask = []
            self.safeAreaToolbar.isTranslucent = true
            
            self.safeAreaToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
            self.safeAreaToolbar.setShadowImage(UIImage(), forToolbarPosition: .topAttached)
            
            self.safeAreaToolbar.clipsToBounds = false

            self.safeAreaBackgroundView.contentView.addSubview(safeAreaToolbar)
        }
        
        self.toolbar = PBPopupToolbar(frame: self.bounds)
        self.toolbar.autoresizingMask = []
        self.toolbar.isTranslucent = true
        
        // For background color, we have to replace the system image.
        // -- > self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        // The backgroundColor is not translucent.
        
        // For barTintColor, do not replace the system image.
        // --> self.toolbar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
        // The barTintColor is translucent if the toolbar is translucent.
        
        // For effect view, replace the system image.
        // --> self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        
        if #available(iOS 11.0, *) {
            self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        }
        else {
            self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        }
        
        // To remove the top line:
        // --> self.toolbar.clipsToBounds = true
        // Or if toolbar.clipsToBounds = false
        // --> self.toolbar.setShadowImage(UIImage(), forToolbarPosition: .topAttached)
        
        // 1 - Must be called before clipsToBounds else the shadow line not shown
        self.toolbar.layer.masksToBounds = true
        
        // 2 - For the shadow image (top line)
        self.toolbar.clipsToBounds = false
        
        self.addSubview(self.toolbar)
                
        self.imageView = UIImageView()
        
        self.imageView.accessibilityTraits = UIAccessibilityTraits.image
        self.imageView.isAccessibilityElement = true
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.autoresizingMask = []
        self.imageView.contentMode = .scaleAspectFit
        
        self.imageView.layer.cornerRadius = 3.0
        self.imageView.layer.masksToBounds = true
        
        self.shadowImageView = PBPopupRoundShadowImageView(frame: self.imageView.bounds)
        self.shadowImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.shadowImageView.backgroundColor = UIColor.clear
        self.shadowImageView.shadowColor = UIColor.black
        self.shadowImageView.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.shadowImageView.shadowRadius = 3.0
        self.shadowImageView.shadowOpacity = 0.5
        
        self.shadowImageView.addSubview(self.imageView)
        
        self.toolbar.addSubview(self.shadowImageView)
        
        self.titlesView = PBPopupBarTitlesView()
        self.titlesView.isAccessibilityElement = true
        self.titlesView.accessibilityTraits = .button
        self.titlesView.accessibilityLabel = NSLocalizedString("Popup bar", comment: "")
        self.titlesView.autoresizingMask = []
        self.titlesView.isUserInteractionEnabled = false
        self.titlesView.clipsToBounds = true
        
        self.toolbar.addSubview(self.titlesView)
        
        self.titleLabel = UILabel()
        self.titleLabel.isAccessibilityElement = true
        /*
        self.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        if #available(iOS 10.0, *) {
            self.titleLabel.adjustsFontForContentSizeCategory = true
        }
        */
        self.titleLabel.backgroundColor = UIColor.clear
        
        self.titlesView.addSubview(self.titleLabel)
        
        self.subtitleLabel = UILabel()
        self.subtitleLabel.isAccessibilityElement = true
        /*
        self.subtitleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        if #available(iOS 10.0, *) {
            self.subtitleLabel.adjustsFontForContentSizeCategory = true
        }
        */
        self.subtitleLabel.backgroundColor = UIColor.clear
        
        self.titlesView.addSubview(self.subtitleLabel)
        
        self.progressView = PBPopupBarProgressView(progressViewStyle: .default)
        self.progressView.trackImage = UIImage()
        
        self.toolbar.addSubview(self.progressView)
        
        self.progressView.setProgress(0.0, animated: false)
        
        self.highlightView = PBPopupBarHighlightView()
        self.highlightView.autoresizingMask = []
        self.highlightView.isUserInteractionEnabled = false
        self.highlightView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.highlightView.alpha = 0.0
        self.addSubview(self.highlightView)
        
        self.isAccessibilityElement = false
        self.configureAccessibility()
        
        self.semanticContentAttribute = .unspecified
        
        self.clipsToBounds = false // Important for shadow line.
    }
    
    deinit {
        PBLog("deinit \(self)")
    }
    
    // MARK: - Public Methods
    
    /**
     Call this method to update the popup bar appearance (style, tint color, etc.) according to its docking view. You should call this after updating the docking view.
     If the popup bar's `inheritsVisualStyleFromBottomBar` property is set to `false`, this method has no effect.
     
     - SeeAlso: `PBPopupBar.inheritsVisualStyleFromBottomBar`.
     */
    @objc public func updatePopupBarAppearance() {
        self.popupController.containerViewController._configurePopupBarFromBottomBar()
    }
    
    /**
     :nodoc:
     */
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        guard let popupBarView = self.superview else {return}
        
        //self.toolbar.setNeedsLayout()
        //self.toolbar.layoutIfNeeded()
        
        if self.ignoreLayoutDuringTransition {
            return
        }
        
        UIView.performWithoutAnimation({() -> Void in
            
            self.frame.size.width = popupBarView.frame.width
            
            self.frame.size.height = self.popupBarHeight
            
            self.layoutToolbar()
            
            self.layoutAllViews()
            
            if popupBarStyle == .custom {self.layoutCustomPopupBarView()}
        })
    }
    
    // MARK: - Private Methods
    
    internal func setHighlighted(_ highlighted: Bool, animated: Bool) {
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
        if self.popupBarStyle == .custom && self.customPopupBarViewController != nil {
            self.addSubview(customPopupBarViewController!.view)
            self.bringSubviewToFront(self.highlightView)
        }
        self.backgroundView.isHidden = hidden
        self.safeAreaBackgroundView?.isHidden = hidden
        self.toolbar.isHidden = hidden
        self.safeAreaToolbar?.isHidden = hidden
        self.titlesView.isHidden = hidden
    }
    
    private func layoutCustomPopupBarView() {
        if self.customPopupBarViewController != nil {

            self.customPopupBarViewController?.view.preservesSuperviewLayoutMargins = true
            
            self.customPopupBarViewController?.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.topAnchor.constraint(equalTo:(customPopupBarViewController?.view.topAnchor)!),
                self.leftAnchor.constraint(equalTo: (customPopupBarViewController?.view.leftAnchor)!),
                self.rightAnchor.constraint(equalTo: (customPopupBarViewController?.view.rightAnchor)!),
                self.bottomAnchor.constraint(equalTo: (customPopupBarViewController?.view.bottomAnchor)!)])
        }
    }
    
    private func layoutAllViews() {
        
        self.layoutBackgroundView()
        
        self.layoutSafeAreaBackgroundView()
        
        self.layoutToolbar()
        
        self.layoutImageView()
        
        self.layoutTitlesView()
        
        self.layoutTitleLabels()
        
        self.layoutProgressView()
        
        self.layoutHighlightView()
        
        //NSLayoutConstraint.reportAmbiguity(self)
        //NSLayoutConstraint.listConstraints(self)
    }
    
    private func layoutSafeAreaBackgroundView() {
        if #available(iOS 11.0, *) {
            if self.safeAreaBackgroundView.translatesAutoresizingMaskIntoConstraints == true {
                self.safeAreaBackgroundView.translatesAutoresizingMaskIntoConstraints = false
                self.safeAreaBackgroundView.preservesSuperviewLayoutMargins = false
                self.safeAreaBackgroundView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
                self.safeAreaBackgroundView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0.0).isActive = true
                self.safeAreaBackgroundView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0.0).isActive = true
            }
            if let heightConstraint = self.safeAreaBackgroundViewHeightConstraint {
                heightConstraint.constant = self.safeBottom()
            }
            else {
                self.safeAreaBackgroundViewHeightConstraint = self.safeAreaBackgroundView.heightAnchor.constraint(equalToConstant: self.safeBottom())
            }
            self.safeAreaBackgroundViewHeightConstraint?.isActive = true
            
            if PBPopupBarShowColors == true {
                self.safeAreaToolbar.setBackgroundImage(nil, forToolbarPosition: .bottom, barMetrics: .default)
                self.safeAreaToolbar.setShadowImage(nil, forToolbarPosition: .topAttached)
                self.safeAreaToolbar.barTintColor = UIColor.blue
            }
            
            if self.safeAreaToolbar.translatesAutoresizingMaskIntoConstraints == true {
                self.safeAreaToolbar.translatesAutoresizingMaskIntoConstraints = false
                self.safeAreaToolbar.preservesSuperviewLayoutMargins = false
                self.safeAreaToolbar.topAnchor.constraint(equalTo: self.safeAreaBackgroundView.contentView.topAnchor, constant: 0.0).isActive = true
                self.safeAreaToolbar.leftAnchor.constraint(equalTo: self.safeAreaBackgroundView.contentView.leftAnchor, constant: 0.0).isActive = true
                self.safeAreaToolbar.rightAnchor.constraint(equalTo: self.safeAreaBackgroundView.contentView.rightAnchor, constant: 0.0).isActive = true
                self.safeAreaToolbar.bottomAnchor.constraint(equalTo: self.safeAreaBackgroundView.contentView.bottomAnchor, constant: 0.0).isActive = true
            }
        }
    }
    
    private func layoutBackgroundView() {
        if PBPopupBarShowColors == true {
            self.toolbar.setBackgroundImage(nil, forToolbarPosition: .bottom, barMetrics: .default)
            self.toolbar.setShadowImage(nil, forToolbarPosition: .topAttached)
            self.toolbar.barTintColor = UIColor.orange
        }
        if self.backgroundView.translatesAutoresizingMaskIntoConstraints == true {
            self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.33).isActive = true
            self.backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0.0).isActive = true
            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
            self.backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0.0).isActive = true
        }
    }
    
    private func layoutToolbar() {
        if self.toolbar.translatesAutoresizingMaskIntoConstraints == true {
            self.toolbar.translatesAutoresizingMaskIntoConstraints = false
            self.toolbar.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.33).isActive = true
            self.toolbar.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0.0).isActive = true
            self.toolbar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
            self.toolbar.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0.0).isActive = true
        }
    }
    
    private func layoutImageView() {
        let safeLeading = self.safeLeading()
        let height = self.popupBarHeight
        let imageHeight = (self.popupBarStyle == .prominent || self.popupBarStyle == .custom) ? PBPopupBarImageHeightProminent : PBPopupBarImageHeightCompact
        
        if self.imageView.translatesAutoresizingMaskIntoConstraints == false {
            
            if let topConstraint = self.imageViewTopConstraint {
                topConstraint.constant = (height - imageHeight) / 2
            }
            else {
                self.imageViewTopConstraint = self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: (height - imageHeight) / 2)
            }
            self.imageViewTopConstraint.isActive = true
            
            self.imageViewLeftConstraint?.isActive = false
            self.imageViewRightConstraint?.isActive = false
            
            if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight {
                if let leftConstraint = self.imageViewLeftConstraint {
                    leftConstraint.constant = 16.0 + safeLeading
                }
                else {
                    self.imageViewLeftConstraint = self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16.0 + safeLeading)
                }
                self.imageViewLeftConstraint.isActive = true
            }
            else {
                if let rightConstraint = self.imageViewRightConstraint {
                    rightConstraint.constant = -(16.0 + safeLeading)
                }
                else {
                    self.imageViewRightConstraint = self.imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -(16.0 + safeLeading))
                }
                self.imageViewRightConstraint.isActive = true
            }
            
            if let widthConstraint = self.imageViewWidthConstraint {
                widthConstraint.constant = imageHeight
            }
            else {
                self.imageViewWidthConstraint = self.imageView.widthAnchor.constraint(equalToConstant: imageHeight)
            }
            self.imageViewWidthConstraint.isActive = true
            
            if let heightConstraint = self.imageViewHeightConstraint {
                heightConstraint.constant = imageHeight
            }
            else {
                self.imageViewHeightConstraint = self.imageView.heightAnchor.constraint(equalToConstant: imageHeight)
            }
            self.imageViewHeightConstraint.isActive = true
        }
        
        self.imageView.isHidden = (self.image == nil || self.popupBarStyle == .compact)
        self.imageView.layoutIfNeeded()
    }
    
    private func layoutTitlesView() {
        let xPositions = self.getMostLeftAndRightItemsXPositions()
        
        var left = xPositions[0]
        var right = xPositions[1]
        
        if left < 0.0 {left = 0.0}
        
        if right < 0.0 {right = 0.0}
        
        if left == 0.0 && right == 0.0 {
            left = 16 + (self.image != nil ? (self.imageView.frame.origin.x + self.imageView.frame.size.width) : 0.0)
            right = 16
        }
        else {
            let safeLeading = self.safeLeading()
            
            if self.popupBarStyle == .prominent || self.popupBarStyle == .custom {
                if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight {
                    
                    left = self.image == nil ? 16.0 + safeLeading : 16 + safeLeading + PBPopupBarImageHeightProminent + 16.0
                    right = self.toolbar.frame.size.width - right - safeLeading
                }
                else {
                    right = self.image == nil ? 16.0 + safeLeading : self.imageView.frame.size.width + 2 * 16.0 + safeLeading
                }
            }
            else {
                if left == 0 {
                    left = 16
                }
                left += safeLeading
                if left > right {right = self.toolbar.frame.size.width}
                if #available(iOS 11.0, *) {
                    right = self.toolbar.frame.size.width - right - safeLeading
                }
                else {
                    right = self.toolbar.frame.size.width - right - safeLeading
                }
                //if right > left {right = 0}
            }
        }
        
        if PBPopupBarShowColors == true {
            self.titlesView.backgroundColor = UIColor.yellow
        }
        
        if self.titlesView.translatesAutoresizingMaskIntoConstraints == true {
            self.titlesView.translatesAutoresizingMaskIntoConstraints = false
            
            self.titlesView.topAnchor.constraint(equalTo: self.toolbar.topAnchor, constant: 0.0).isActive = true
            self.titlesView.bottomAnchor.constraint(equalTo: self.toolbar.bottomAnchor, constant: 0.0).isActive = true
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
    
    private func configureTitleLabels() {
        
        if self.askForLabels {
            self.askForLabels = false
            if let titleLabel = self.dataSource?.titleLabel?(for: self) {
                NSLayoutConstraint.deactivate(self.titleLabel.constraints)
                self.titleLabel.translatesAutoresizingMaskIntoConstraints = true
                self.titleLabelTopConstraint = nil
                self.titleLabelHeightConstraint = nil
                self.titleLabelCenterConstraint = nil
                self.titleLabel.removeFromSuperview()
                self.titleLabel = titleLabel
                if PBPopupBarShowColors == true {
                    self.titleLabel.backgroundColor = UIColor.magenta
                }
                self.titlesView.addSubview(self.titleLabel)
            }
            
            if let subtitleLabel = self.dataSource?.subtitleLabel?(for: self) {
                NSLayoutConstraint.deactivate(self.subtitleLabel.constraints)
                self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = true
                self.subtitleLabelBottomConstraint = nil
                self.subtitleLabelHeightConstraint = nil
                self.subtitleLabelCenterConstraint = nil
                self.subtitleLabel.removeFromSuperview()
                self.subtitleLabel = subtitleLabel
                if PBPopupBarShowColors == true {
                    self.subtitleLabel.backgroundColor = UIColor.cyan
                }
                self.titlesView.addSubview(self.subtitleLabel)
            }
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        if self.popupBarStyle == .compact {
            paragraphStyle.alignment = .center
            self.titleLabel.textAlignment = .center
            self.subtitleLabel.textAlignment = .center
        } else {
            paragraphStyle.alignment = .natural
            self.titleLabel.textAlignment = .natural
            self.subtitleLabel.textAlignment = .natural
            
            if self.semanticContentAttribute == .forceRightToLeft {
                paragraphStyle.alignment = .right
                self.titleLabel.textAlignment = .right
                self.subtitleLabel.textAlignment = .right
            }
        }
        
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        var font: UIFont
        font = UIFont.systemFont(ofSize: self.popupBarStyle == .prominent ? 18 : 14, weight: .regular)
        if #available(iOS 11.0, *) {
            font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
            self.titleLabel.adjustsFontForContentSizeCategory = true
        }
        
        let defaultTitleAttribures: NSMutableDictionary = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: font]
        
        if (self.titleTextAttributes != nil) {
            defaultTitleAttribures.addEntries(from: self.titleTextAttributes!)
        }
        
        if (self.title != nil)
        {
            self.titleLabel.attributedText = NSAttributedString(string: self.title!, attributes: (defaultTitleAttribures as! [NSAttributedString.Key : Any]))
        }
        else {
            self.titleLabel.text = nil
        }

        font = UIFont.systemFont(ofSize: self.popupBarStyle == .prominent ? 14 : 11/*12*/, weight: .regular)
        if #available(iOS 11.0, *) {
            font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
            self.subtitleLabel.adjustsFontForContentSizeCategory = true
        }
        let defaultSubTitleAttribures: NSMutableDictionary = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: font]
        
        if (self.subtitleTextAttributes != nil) {
            defaultSubTitleAttribures.addEntries(from: self.subtitleTextAttributes!)
        }
        
        if (self.subtitle != nil)
        {
            self.subtitleLabel.attributedText = NSAttributedString(string: self.subtitle!, attributes: (defaultSubTitleAttribures as! [NSAttributedString.Key : Any]))
        }
        else {
            self.subtitleLabel.text = nil
        }
    }
    
    private func layoutTitleLabels() {
        let height = self.popupBarHeight
        let imageHeight = (self.popupBarStyle == .prominent || self.popupBarStyle == .custom) ? PBPopupBarImageHeightProminent : PBPopupBarImageHeightCompact
        
        if PBPopupBarShowColors == true {
            self.titleLabel.backgroundColor = UIColor.magenta
        }
        
        if self.titleLabel.translatesAutoresizingMaskIntoConstraints == true {
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.titleLabel.leftAnchor.constraint(equalTo: self.titlesView.leftAnchor, constant: 0.0).isActive = true
            self.titleLabel.rightAnchor.constraint(equalTo: self.titlesView.rightAnchor, constant: 0.0).isActive = true
        }
        
        if self.subtitle == nil {
            if self.titleLabelCenterConstraint == nil {
                self.titleLabelCenterConstraint = self.titleLabel.centerYAnchor.constraint(equalTo: self.titlesView.centerYAnchor, constant: 0)
                self.titleLabelCenterConstraint.isActive = true
            }
            else {
                if let topConstraint = self.titleLabelTopConstraint {
                    NSLayoutConstraint.deactivate([topConstraint])
                }
                self.titleLabelCenterConstraint.isActive = true
            }
        }
        else {
            if let centerConstraint = self.titleLabelCenterConstraint {
                NSLayoutConstraint.deactivate([centerConstraint])
            }
            if let topConstraint = self.titleLabelTopConstraint {
                topConstraint.constant = (height - imageHeight) / 2
            }
            else {
                self.titleLabelTopConstraint = self.titleLabel.topAnchor.constraint(equalTo: self.titlesView.topAnchor, constant: (height - imageHeight) / 2)
            }
            self.titleLabelTopConstraint.isActive = true
        }
        
        if PBPopupBarShowColors == true {
            self.subtitleLabel.backgroundColor = UIColor.cyan
        }
        
        if self.subtitleLabel.translatesAutoresizingMaskIntoConstraints == true {
            self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.subtitleLabel.leftAnchor.constraint(equalTo: self.titlesView.leftAnchor, constant: 0.0).isActive = true
            self.subtitleLabel.rightAnchor.constraint(equalTo: self.titlesView.rightAnchor, constant: 0.0).isActive = true
        }
        
        if self.title == nil {
            if self.subtitleLabelCenterConstraint == nil {
                self.subtitleLabelCenterConstraint = self.subtitleLabel.centerYAnchor.constraint(equalTo: self.titlesView.centerYAnchor, constant: 0)
                self.subtitleLabelCenterConstraint.isActive = true
            }
            else {
                if let bottomConstraint = self.subtitleLabelBottomConstraint {
                    NSLayoutConstraint.deactivate([bottomConstraint])
                }
                self.subtitleLabelCenterConstraint.isActive = true
            }
        }
        else {
            if let centerConstraint = self.subtitleLabelCenterConstraint {
                NSLayoutConstraint.deactivate([centerConstraint])
            }
            if let bottomConstraint = self.subtitleLabelBottomConstraint {
                bottomConstraint.constant = -(height - imageHeight) / 2
            }
            else {
                self.subtitleLabelBottomConstraint = self.subtitleLabel.bottomAnchor.constraint(equalTo: self.titlesView.bottomAnchor, constant: -(height - imageHeight) / 2)
            }
            self.subtitleLabelBottomConstraint.isActive = true
        }
        
        if self.title != nil && self.subtitle != nil {
            let fullHeight = self.titleLabel.font.lineHeight + self.subtitleLabel.font.lineHeight
            
            if let heightConstraint = self.titleLabelHeightConstraint {
                heightConstraint.constant = imageHeight * (self.titleLabel.font.lineHeight / fullHeight)
            }
            else {
                self.titleLabelHeightConstraint = self.titleLabel.heightAnchor.constraint(equalToConstant: imageHeight * (self.titleLabel.font.lineHeight / fullHeight))
            }
            self.titleLabelHeightConstraint.isActive = true
            
            if let heightConstraint = self.subtitleLabelHeightConstraint {
                heightConstraint.constant = imageHeight * (self.subtitleLabel.font.lineHeight / fullHeight)
            }
            else {
                self.subtitleLabelHeightConstraint = self.subtitleLabel.heightAnchor.constraint(equalToConstant: imageHeight * (self.subtitleLabel.font.lineHeight / fullHeight))
            }
            self.subtitleLabelHeightConstraint.isActive = true
        }
    }

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
        self.toolbar.layoutIfNeeded()
        self.layoutSubviews()
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
        self.addConstraints(progressViewVerticalConstraints)
        
        if let horizontalConstraints = self.progressViewHorizontalConstraints {
            NSLayoutConstraint.deactivate(horizontalConstraints)
        }
        self.progressViewHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        self.addConstraints(progressViewHorizontalConstraints)
    }

    private func layoutHighlightView() {
        
        if self.highlightView.translatesAutoresizingMaskIntoConstraints == true {
            self.highlightView.translatesAutoresizingMaskIntoConstraints = false
            
            self.highlightView.topAnchor.constraint(equalTo: (self.superview?.topAnchor)!, constant: 0.0).isActive = true
            self.highlightView.leftAnchor.constraint(equalTo: (self.superview?.leftAnchor)!, constant: 0.0).isActive = true
            self.highlightView.bottomAnchor.constraint(equalTo: (self.superview?.bottomAnchor)!, constant: 0.0).isActive = true
            self.highlightView.rightAnchor.constraint(equalTo: (self.superview?.rightAnchor)!, constant: 0.0).isActive = true
        }
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
                        if PBPopupBarShowColors == true {
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
                        if PBPopupBarShowColors == true {
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
                        if PBPopupBarShowColors == true {
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
                    }
                }
                else {
                    // If RTL: rightItems will be at left: return the frame of first one + width in left variable
                    if let rightItemView = (rightItems[0] as AnyObject).value(forKey: "view") as? UIView {
                        if PBPopupBarShowColors == true {
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
                    }
                }
            }
        }
        
        return [left, right]
    }
}

extension PBPopupBar {
    
    // MARK: - Helpers
    
    internal func safeLeading() -> CGFloat {
        var safeLeading: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            guard (self.window != nil) else { return 0.0 }
            safeLeading = max((self.window?.safeAreaInsets.left)!, safeLeading)
        }
        return safeLeading
    }
    
    internal func safeBottom() -> CGFloat {
        var safeBottom: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            guard (self.window != nil) else { return 0.0 }
            safeBottom = max((self.window?.safeAreaInsets.bottom)!, safeBottom)
        }
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

extension PBPopupBar {
    /**
     Custom views For Debug View Hierarchy Names
     */
    internal class PBPopupBarTitlesView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    internal class PBPopupBarProgressView: UIProgressView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    internal class PBPopupBarHighlightView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    internal class PBPopupSafeAreaBackgroundView: UIVisualEffectView {
        override init(effect: UIVisualEffect?) {
            super.init(effect: effect)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}


extension NSLayoutConstraint {
    class func reportAmbiguity (_ v:UIView?) {
        var v = v
        if v == nil {
            v = UIApplication.shared.keyWindow
        }
        for vv in v!.subviews {
            print("\(vv) \(vv.hasAmbiguousLayout)")
            if vv.subviews.count > 0 {
                self.reportAmbiguity(vv)
            }
        }
    }
    class func listConstraints (_ v:UIView?) {
        var v = v
        if v == nil {
            v = UIApplication.shared.keyWindow
        }
        for vv in v!.subviews {
            let arr1 = vv.constraintsAffectingLayout(for:.horizontal)
            let arr2 = vv.constraintsAffectingLayout(for:.vertical)
            let s = String(format: "\n\n%@\nH: %@\nV:%@", vv, arr1, arr2)
            print(s)
            if vv.subviews.count > 0 {
                self.listConstraints(vv)
            }
        }
    }
}

