//
//  PBPopupController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 14/04/2018.
//  Copyright © 2018-2024 Patrick BODET. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import ObjectiveC


internal class _PBPopupBarView: UIView {
    
    var popupController: PBPopupController! = nil
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizingMask = []
        self.autoresizesSubviews = true
        self.preservesSuperviewLayoutMargins = true
        self.clipsToBounds = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let popupController = self.popupController {
            let state = popupController.popupPresentationState
            if state != .presenting && state != .dismissing {
                self.popupController.setPopupBarViewFrame(for: state)
            }
        }
    }
}

/**
 Available states of PBPopupController.
 */
@objc public enum PBPopupPresentationState: Int {
    /**
     The popup bar is hidden, not presented.
     */
    case hidden
    /**
     The popup bar is in presenting transition, will be shown. State will be closed.
     */
    case presenting
    /**
     The popup bar is in dismissing transition, will be hidden, dismissed.
     */
    case dismissing
    /**
     The popup bar is dismissed.
     */
    case dismissed
    /**
     The popup bar is presented, popup content view is closed, hidden.
     */
    case closed
    /**
     The popup bar is presented, hidden while popup content view is open, shown.
     */
    case open
    /**
     The popup content view is in presenting transition, will be open, shown.
     */
    case opening
    /**
     The popup content view is in dismissing transition, will be closed, hidden.
     */
    case closing
    /**
     The popup content view is in transitioning transition, will be closed or open.
     */
    case transitioning
}

extension PBPopupPresentationState
{
    private static let strings = ["hidden", "presenting", "dismissing", "dismissed", "closed", "open", "opening", "closing", "transitioning"]
    
    private func string() -> NSString {
        return PBPopupPresentationState.strings[self.rawValue] as NSString
    }
    
    /**
     Return an human readable description for the PBPopupController state.
     */
    public var description: NSString {
        get {
            return string()
        }
    }
}

/**
 Available popup content view presentation styles.
 
 Use the most appropriate style for the current operating system version. Uses fullScreen for iOS 9 and above, otherwise deck.
 */
@objc public enum PBPopupPresentationStyle : Int {
    
    /**
     A presentation style which attempt to recreate the card-like transition found in the iOS 10 Apple Music.
     */
    case deck
    
    /**
     A presentation style in which the presented view covers the screen.
     */
    case fullScreen
    
    /**
     A presentation style in which the presented view covers a part of the screen (height only ???).
     */
    case custom
    
    /**
     A presentation style in which the presented view covers a part of the screen without popup bar.
     */
    case popup
    
    /**
     Default presentation style: fullScreen for iOS 9 and above, otherwise deck.
     */
    public static let `default`: PBPopupPresentationStyle = {
        return .deck
    }()
}

extension PBPopupPresentationStyle
{
    /**
     An array of human readable strings for the popup content view presentation styles.
     */
    public static let strings = ["deck", "fullScreen", "custom", "popup"]
    
    private func string() -> NSString {
        return PBPopupPresentationStyle.strings[self.rawValue] as NSString
    }
    
    /**
     Return an human readable description for the popup content view presentation style.
     */
    public var description: NSString {
        get {
            return string()
        }
    }
}

@objc public protocol PBPopupControllerDataSource: NSObjectProtocol {
    
    /**
     Returns a custom bottom bar view. The popup bar will be attached to.
     
     - Parameter popupController:             The popup controller object.
     
     - Returns:
     The view object representing the bottom bar view.
     */
    @objc optional func bottomBarView(for popupController: PBPopupController) -> UIView?
    
    /**
     Returns the default frame for the bottom bar view.
     
     - Parameter popupController:             The popup controller object.
     - Parameter bottomBarView:               The bottom bar view returned by 'bottomBarView(for:)'
     
     - Returns:
     The default frame for the bottom bar view, when the popup is in hidden or closed state. If `bottomBarView` returns nil or is not implemented, this method is not called, and the default system-provided frame is used.
     
     - SeeAlso: bottomBarView(for:)
     */
    @objc optional func popupController(_ popupController: PBPopupController, defaultFrameFor bottomBarView: UIView) -> CGRect
    
    /**
     Returns the insets for the bottom bar view from bottom of the container controller's view. By default, this is set to the container controller view's safe area insets since iOS 11 or `UIEdgeInsets.zero` otherwise. Currently, only the bottom inset is respected.
     
     The system calculates the position of the popup bar by summing the bottom bar height and the bottom of the insets.
     
     - Parameter popupController:             The popup controller object.
     - Parameter bottomBarView:               The bottom bar view returned by 'bottomBarView(for:)'
     
     - Returns:
     The insets for the bottom bar view from bottom of the container controller's view. If `bottomBarView` returns nil or is not implemented, this method is not called, and the default system-provided bottom inset is used.
     
     - SeeAlso: bottomBarView(for:)
     */
    @objc optional func popupController(_ popupController: PBPopupController, insetsFor bottomBarView: UIView) -> UIEdgeInsets
}

@objc public protocol PBPopupControllerDelegate: NSObjectProtocol {
    /**
     Called just before the popup bar view is presenting.
     
     - Parameter popupController:     The popup controller object.
     - Parameter popupBar       :     The popup bar object.
     */
    @objc optional func popupController(_ popupController: PBPopupController, willPresent popupBar: PBPopupBar)
    
    /**
     Called just before the popup bar view is dismissing.
     
     - Parameter popupController:     The popup controller object.
     - Parameter popupBar       :     The popup bar object.
     */
    @objc optional func popupController(_ popupController: PBPopupController, willDismiss popupBar: PBPopupBar)
    
    /**
     Called just after the popup bar view is presenting.
     
     - Parameter popupController:     The popup controller object.
     - Parameter popupBar       :     The popup bar object.
     */
    @objc optional func popupController(_ popupController: PBPopupController, didPresent popupBar: PBPopupBar)
    
    /**
     Called just after the popup bar view is dismissing.
     
     - Parameter popupController:     The popup controller object.
     - Parameter popupBar       :     The popup bar object.
     */
    @objc optional func popupController(_ popupController: PBPopupController, didDismiss popupBar: PBPopupBar)
    
    /**
     Called just before the popup content view is about to be open by typing or dragging the popup bar.
     
     - Parameter popupController:             The popup controller object.
     - Parameter popupContentViewController:  The popup content view controller object.
     
     - Returns:
     `false` if you want the gesture action to be ignored, `true` otherwise.
     */
    @objc optional func popupController(_ popupController: PBPopupController, shouldOpen popupContentViewController: UIViewController) -> Bool
    
    /**
     Called just before the popup content view is about to be open.
     
     - Parameter popupController:             The popup controller object.
     - Parameter popupContentViewController:  The popup content view controller object.
     */
    @objc optional func popupController(_ popupController: PBPopupController, willOpen popupContentViewController: UIViewController)
    
    /**
     Asks the delegate for addditional animations to add to the animator while opening the popup content view.
     
     - Parameter popupController:             The popup controller object.
     - Parameter popupContentViewController:  The popup content view controller object.

     - Returns:
     A block containing the requested animations. The properties should be animatable.
     */
    @objc optional func additionalAnimationsForOpening(popupController: PBPopupController, popupContentViewController: UIViewController, isInteractive: Bool) -> (() -> Void)?

    /**
     Called just before the popup content view is about to be closed by typing the popup close button or dragging the popup content view.
     
     - Parameter popupController:             The popup controller object.
     - Parameter popupContentViewController:  The popup content view controller object.
     
     - Returns:
     `false` if you want the gesture action to be ignored, `true` otherwise.
     */
    @objc optional func popupController(_ popupController: PBPopupController, shouldClose popupContentViewController: UIViewController) -> Bool
    
    /**
     Called just before the popup content view is about to be closed.
     
     - Parameter popupController:             The popup controller object.
     - Parameter popupContentViewController:  The popup content view controller object.
     */
    @objc optional func popupController(_ popupController: PBPopupController, willClose popupContentViewController: UIViewController)
    
    /**
     Asks the delegate for addditional animations to add to the animator while closing the popup content view.
     
     - Parameter popupController:             The popup controller object.
     - Parameter popupContentViewController:  The popup content view controller object.

     - Returns:
     A block containing the requested animations. The properties should be animatable.
     */
    @objc optional func additionalAnimationsForClosing(popupController: PBPopupController, popupContentViewController: UIViewController, isInteractive: Bool) -> (() -> Void)?

    /**
     Called just after the popup content view is open.
     
     - Parameter popupController:             The popup controller object.
     - Parameter popupContentViewController:  The popup content view controller object.
     */
    @objc optional func popupController(_ popupController: PBPopupController, didOpen popupContentViewController: UIViewController)
    
    /**
     Called just after the popup content view is closed.
     
     - Parameter popupController:             The popup controller object.
     - Parameter popupContentViewController:  The popup content view controller object.
     */
    @objc optional func popupController(_ popupController: PBPopupController, didClose popupContentViewController: UIViewController)
    
    /**
     Called several times during the interactive transition by user.
     
     - Parameter popupController:             The popup controller object.
     - Parameter popupContentViewController:  The popup content view controller object.
     - Parameter state:                       The popup presentation state before the start of the transition (closed / open).
     - Parameter progress:                    The current progress of the interactive presentation
     - Parameter location:                    The popup content view current location. The y-coordinate of the point on screen.
     
     - Note: The current progress is represented by a floating-point value between 0.0 and 1.0, inclusive, where 1.0 indicates the completion of the interactive presentation.
     
     - SeeAlso: `PBPopupPresentationState`.
     */
    @objc optional func popupController(_ popupController: PBPopupController, interactivePresentationFor popupContentViewController: UIViewController, state: PBPopupPresentationState, progress: CGFloat, location: CGFloat)
    
    /**
     Called when the presentation state of the popup controller has changed.
     
     - Parameter popupController:  The popup controller object.
     - Parameter state:            The popup presentation state.
     - Parameter previousState:    The previous popup presentation state.
     
     - SeeAlso: `PBPopupPresentationState`.
     */
    @objc optional func popupController(_ popupController: PBPopupController, stateChanged state: PBPopupPresentationState, previousState: PBPopupPresentationState)
    
    /**
     Implement this to return NO when you want the tap gesture recognizer to be ignored.
     
     - SeeAlso: `PBPopupBar.popupTapGestureRecognizer`
     
     - Parameter popupController:    The popup controller object.
     - Parameter state:              The popup presentation state.
     
     - Returns:
     `false` if you want the pan gesture recognizer to be ignored, `true` otherwise.
     */
    @objc optional func popupControllerTapGestureShouldBegin(_ popupController: PBPopupController, state: PBPopupPresentationState) -> Bool
    
    /**
     Implement this to return NO when you want the pan gesture recognizer to be ignored.
     
     - SeeAlso:
     `popupBarPanGestureRecognizer`
     `popupContentPanGestureRecognizer`
     
     - Parameter popupController:    The popup controller object.
     - Parameter state:              The popup presentation state.
     
     - Returns:
     `false` if you want the pan gesture recognizer to be ignored, `true` otherwise.
     */
    @objc optional func popupControllerPanGestureShouldBegin(_ popupController: PBPopupController, state: PBPopupPresentationState) -> Bool
}

@objc public class PBPopupController: NSObject, UIGestureRecognizerDelegate {
    
    // MARK: - Public Properties
    
    /**
     The data source of the PBPopupController object.
     
     - SeeAlso: `PBPopupControllerDataSource`.
     */
    @objc weak public var dataSource: PBPopupControllerDataSource?
    
    /**
     The delegate of the PBPopupController object.
     
     - SeeAlso: `PBPopupControllerDelegate`.
     */
    @objc weak public var delegate: PBPopupControllerDelegate?
    
    /**
     When presenting the contextual content view, the presentation controller will use a snapshot of the presentation view based on its content.
     */
    @objc public var shouldUseSnapshotForPresentingView: Bool = false
    
    /**
     The state of the popup presentation. (read-only)
     
     - SeeAlso:
     `PBPopupPresentationState`.
     `PBPopupControllerDelegate`.
     */
    @objc public internal(set) var popupPresentationState: PBPopupPresentationState
    
    /**
     The tap gesture recognizer attached to the popup bar for presenting the popup content view.
     */
    @objc public var popupBarTapGestureRecognizer: UITapGestureRecognizer!
    
    /**
     The pan gesture recognizer attached to the popup bar for presenting the popup content view.
     */
    @objc public var popupBarPanGestureRecognizer: UIPanGestureRecognizer!
    
    /**
     The pan gesture recognizer attached to the popup content view for dismissing the popup content view.
     */
    @objc public var popupContentPanGestureRecognizer: UIPanGestureRecognizer!
    
    /**
     Set this property to `false` if you want addional safe area insets to be ignored when the popup bar is presented (usefull for iPad when the popup is the neighbour of another object).
     */
    @objc public var wantsAdditionalSafeAreaInsetBottom: Bool = true
    
    /**
     Set this property to `true` if you want addional safe area insets to be on top when the popup bar is presented (usefull for Catalyst when the popup is presented on top).
     */
    @objc public var wantsAdditionalSafeAreaInsetTop: Bool = false
    
    /**
     The preferred status bar style for the container view controller.
     */

    @objc public var containerPreferredStatusBarStyle: UIStatusBarStyle {
        get {
            return _containerPreferredStatusBarStyle
        }
        set {
            _containerPreferredStatusBarStyle = newValue
        }
    }
    
    internal var _containerPreferredStatusBarStyle: UIStatusBarStyle = .default

    /**
     The preferred status bar style for the popup content view controller.
     */
    @objc public var popupPreferredStatusBarStyle: UIStatusBarStyle {
        get {
            guard let vc = self.containerViewController else { return _popupPreferredStatusBarStyle }
            guard let popupContentView = vc.popupContentView else { return _popupPreferredStatusBarStyle }
            
            let popupPresentationStyle = popupContentView.popupPresentationStyle
            switch popupPresentationStyle {
            case .deck:
                return .lightContent
            case .custom:
                if popupContentView.popupContentSize.height == UIScreen.main.bounds.height {
                    return _popupPreferredStatusBarStyle
                }
                return self.containerPreferredStatusBarStyle
            case .popup:
                return self.containerPreferredStatusBarStyle
            case .fullScreen:
                return _popupPreferredStatusBarStyle
            }
        }
        set {
            _popupPreferredStatusBarStyle = newValue
            self.popupStatusBarStyle = newValue
        }
    }

    internal var _popupPreferredStatusBarStyle: UIStatusBarStyle = .default
    
    /**
     The status bar style of the popup content view controller. Return this value when you override the preferredStatusBarStyle variable.
     */
    @objc public var popupStatusBarStyle: UIStatusBarStyle {
        get {
            return _popupStatusBarStyle
        }
        set {
            _popupStatusBarStyle = newValue
        }
    }

    internal var _popupStatusBarStyle: UIStatusBarStyle = .default

    /**
     Controls whether interaction with the popup generates haptic feedback to the user. The default value is `true`.
     */
    @objc public var allowPopupHapticFeedbackGeneration: Bool = true
    
    /**
     The soft soimpact feedback specific intensity. A value between 0.0 and 1.0.
     */
    @objc public var softFeedbackGeneratorIntensity: CGFloat = 0.6
    
    /**
     The rigid impact feedback specific intensity. A value between 0.0 and 1.0.
     */
    @objc public var rigidFeedbackGeneratorIntensity: CGFloat = 0.7
    
    // MARK: - Private Properties
    
    @objc internal weak var containerViewController: UIViewController!
    
    internal var barStyle: UIBarStyle! {
        didSet {
            if let popupContentView = self.containerViewController.popupContentView, let popupEffectView = popupContentView.popupEffectView, popupEffectView.effect != nil {
                if popupContentView.inheritsVisualStyleFromPopupBar == false {
#if targetEnvironment(macCatalyst)
                    popupContentView.popupEffectView.effect = UIBlurEffect(style: .systemThickMaterial)
                    if barStyle == .black {
                        popupContentView.popupEffectView.effect = UIBlurEffect(style: .systemThickMaterialDark)
                    }
#else
                    popupContentView.popupEffectView.effect = UIBlurEffect(style: .systemChromeMaterial)
                    if barStyle == .black {
                        popupContentView.popupEffectView.effect = UIBlurEffect(style: .systemChromeMaterialDark)
                    }
#endif
                }
            }
        }
    }
    
    internal var popupBarView: _PBPopupBarView!
    
    internal var bottomBarHeight: CGFloat
    {
        guard let vc = self.containerViewController else { return 0.0 }
        
        return vc.defaultFrameForBottomBar().height
    }

    internal var bottomBarInset: CGFloat
    {
        guard let vc = self.containerViewController else { return 0.0 }
        
        let insets = vc.insetsForBottomBar()
        
        return insets.bottom
    }

    internal var bottomBarIsHidden: Bool
    {
        guard let vc = self.containerViewController else { return false }

        return vc.bottomBarIsHidden()
    }
    
    private var disableInteractiveTransitioning = false
    
    internal var popupPresentationController: PBPopupPresentationController?
    internal var popupPresentationInteractiveController: PBPopupInteractivePresentationController!
    internal var popupDismissalInteractiveController: PBPopupInteractivePresentationController!
    
    internal var _delegate_additionalAnimationsForOpening: (() -> Void)?
    internal var _delegate_additionalAnimationsForClosing: (() -> Void)?
    
    private var softFeedbackGenerator: UIImpactFeedbackGenerator!
    private var rigidFeedbackGenerator: UIImpactFeedbackGenerator!
    
    private weak var previewingContext: UIViewControllerPreviewing?
    
    internal func dropShadowViewFor(_ view: UIView) -> UIView?
    {
        guard let vc = self.containerViewController else {
            return nil
        }
        if vc.popupContentView.popupIgnoreDropShadowView {
            return nil
        }
        var inputView: UIView? = view
        while inputView != nil {
            guard let view = inputView else { continue }
            inputView = view.superview
            if inputView == nil {
                return nil
            }
            if NSStringFromClass(type(of: inputView!).self).contains("DropShadow") {
                return inputView
            }
            if NSStringFromClass(type(of: inputView!).self).contains("PopoverView") {
                return inputView
            }
            if NSStringFromClass(type(of: inputView!).self) == "PBPopupController.PBPopupContentView" {
                return inputView
            }
        }
        return nil
    }
    
    internal func hasPopupFor(_ view: PBPopupContentView) -> PBPopupContentView? {
        let contentViews: [PBPopupContentView] = view.subviews.compactMap{ $0 as? PBPopupContentView }
        if contentViews.count > 0 {
            return contentViews.first
        }
        return nil
    }
    
    internal var isContainerPresentationSheet: Bool
    {
        return (self.dropShadowViewFor(self.containerViewController.view) != nil)
    }
    
    internal func cornerRadiusForWindow() -> CGFloat
    {
#if targetEnvironment(macCatalyst)
        if let hostingWindow = self.containerViewController.view.window?.value(forKeyPath: "hostWindow.attachedWindow") as AnyObject? {
            if let borderView = hostingWindow.value(forKey: "borderView") as AnyObject? {
                // TODO: macCatalyst cornerRadius
                //if let cornerRadius = borderView.value(forKey: "bottomCornerHeight") as? CGFloat {
                //    return cornerRadius
                //}
                if let cornerRadius = borderView.value(forKey: "cachedCornerRadius") as? CGFloat {
                    return cornerRadius
                }
            }
        }
        return 0
#else
        return UIScreen.main.displayCornerRadius
#endif
    }
    
    private func updatePopupStatusBarStyle(for state: PBPopupPresentationState, previousState: PBPopupPresentationState)
    {
        if let vc = self.containerViewController {
            let popupContentView = vc.popupContentView
            switch popupContentView?.popupPresentationStyle {
            case .deck, .fullScreen:
                if state == .opening, previousState == .closed {
                    self.popupStatusBarStyle = .lightContent
                }
                if state == .closing, previousState == .open {
                    self.popupStatusBarStyle = .lightContent
                }
                if state == .transitioning, previousState == .closed {
                    self.popupStatusBarStyle = self.containerPreferredStatusBarStyle
                }
                if state == .transitioning, previousState == .open {
                    self.popupStatusBarStyle = .lightContent
                }
            default:
                self.popupStatusBarStyle = .default
            }
            vc.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: - Init
    
    internal init(containerViewController controller: UIViewController)
    {
        DispatchQueue.once {
            UIViewController.vc_swizzle()
            UITabBarController.tbc_swizzle()
            UINavigationController.nc_swizzle()
            UISplitViewController.svc_swizzle()
        }
        
        self.popupPresentationState = .hidden
        self.containerViewController = controller
        
        self.softFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
        self.rigidFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        PBLog("deinit \(self)")
        self.containerViewController = nil
    }
    
    internal func pb_popupBar() -> PBPopupBar
    {
        let rv = PBPopupBar(frame: CGRect(x: 0, y: 0, width: self.containerViewController.view.bounds.width, height: PBPopupBarHeightProminent), usePopupBarSmoothGradient: self.containerViewController.usePopupBarSmoothGradient, usePopupBarLegacyShadow: self.containerViewController.usePopupBarLegacyShadow, enablePopupBarColorsDebug: self.containerViewController.enablePopupBarColorsDebug)
        self.popupBarView = _PBPopupBarView()
        self.popupBarView.frame = CGRect(x: 0, y: 0, width: self.containerViewController.view.bounds.width, height: rv.popupBarHeight)
        rv.isHidden = true
        self.popupPresentationState = .hidden
        
        self.popupBarView.addSubview(rv)
        
        self.popupBarTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.popupTapGestureRecognized(tgr:)))
        self.popupBarView.addGestureRecognizer(self.popupBarTapGestureRecognizer)
        self.popupBarTapGestureRecognizer.delegate = self
        
        self.containerViewController.popupBar = rv
        rv.popupController = self
        
        self.popupBarView.popupController = self
        
        rv.isFloating = false
        
        return rv
    }
    
    internal func pb_bottomBar() -> UIView!
    {
        var rv: UIView? = nil
        if self.containerViewController is UITabBarController {
            let tbc = self.containerViewController as! UITabBarController
            rv = tbc.tabBar
        }
        if let navigationController = self.containerViewController as? UINavigationController {
            rv = navigationController.toolbar
            if navigationController.isToolbarHidden {
                rv?.isHidden = true
            }
        }
        if rv == nil {
            if let view = self.dataSource?.bottomBarView?(for: self) {
                rv = view
            }
            else {
                let y: CGFloat = self.containerViewController.view.frame.size.height
                
                rv = UIView(frame: CGRect(x: 0.0, y: y, width: self.containerViewController.view.frame.size.width, height: 0.0))
                rv!.isHidden = true
                self.containerViewController.view.addSubview(rv!)
            }
            if self.containerViewController.view is UIScrollView {
                print("Attempted to present popup bar:\n \(String(describing: self.containerViewController.popupBar)) \non top of a UIScrollView subclass:\n \(String(describing: self.containerViewController.view)).\nThis is unsupported and may result in unexpected behavior.")
            }
        }
        
        self.containerViewController.bottomBar = rv
        
        return rv
    }
    
    internal func pb_popupContentView() -> PBPopupContentView!
    {
        let rv = PBPopupContentView()
        rv.autoresizingMask = []
        
        rv.clipsToBounds = true
        
        rv.preservesSuperviewLayoutMargins = true // default: false
        rv.layer.masksToBounds = true
        
        self.containerViewController.popupContentView = rv
        
        rv.popupController = self
        
        return rv
    }
    
    // MARK: - Popup Bar Haptic Feedback Generation
    
    private func _prepareSoftFeedback()
    {
        if self.allowPopupHapticFeedbackGeneration == false {
            return
        }
        self.softFeedbackGenerator.prepare()
    }
    
    private func _generateSoftFeedbackWithIntensity(_ intensity: CGFloat)
    {
        if self.allowPopupHapticFeedbackGeneration == false {
            return
        }
        self.softFeedbackGenerator.impactOccurred(intensity: intensity)
    }
    
    private func _prepareRigidFeedback()
    {
        if self.allowPopupHapticFeedbackGeneration == false {
            return
        }
        self.rigidFeedbackGenerator.prepare()
    }
    
    private func _generateRigidFeedbackWithIntensity(_ intensity: CGFloat)
    {
        if self.allowPopupHapticFeedbackGeneration == false {
            return
        }
        self.rigidFeedbackGenerator.impactOccurred(intensity: intensity)
    }
    
    // MARK: - Popup Bar Animation
    
    internal func _presentPopupBarAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil)
    {
        guard let vc = self.containerViewController else {
            completionBlock?()
            return
        }
        if self.popupPresentationState != .hidden || vc.popupBarIsHidden {
            completionBlock?()
            return
        }
        
        let previousState = self.popupPresentationState
        self.popupPresentationState = .presenting
        self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
        self.delegate?.popupController?(self, willPresent: vc.popupBar)
        
        let height = vc.popupBar.popupBarHeight
        let width = vc.popupBar.popupBarWidth
        
        vc.popupBar.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        
        vc.view.insertSubview(self.popupBarView, belowSubview: vc.bottomBar)

        self.setPopupBarViewFrame(for: .hidden)

        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        
        vc.popupBar.setNeedsLayout()
        vc.popupBar.layoutIfNeeded()
        
        vc.popupBar.isHidden = false
        
        UIView.animate(withDuration: animated ? vc.popupBar.popupBarPresentationDuration : 0.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [.curveEaseInOut, .layoutSubviews], animations: {
            
            vc.configurePopupBarFromBottomBar()
            
            self.setPopupBarViewFrame(for: .closed)
            self.popupBarView.alpha = 1.0
            
            self.fixInsetsForContainerIfNeeded()
        }) { (success) in
            let previousState = self.popupPresentationState
            self.popupPresentationState = .closed
            self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
            self.delegate?.popupController?(self, didPresent: vc.popupBar)
            vc.popupBarIsHidden = false
            
            vc.configurePopupBarFromBottomBar()
            vc.popupBar.setNeedsLayout()
            vc.popupBar.layoutIfNeeded()
            
            completionBlock?()
        }
    }
    
    internal func _dismissPopupBarAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil)
    {
        guard let vc = self.containerViewController else {
            completionBlock?()
            return
        }
        if self.popupPresentationState == .hidden {
            completionBlock?()
            return
        }
        
        let previousState = self.popupPresentationState
        self.popupPresentationState = .dismissing
        self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
        self.delegate?.popupController?(self, willDismiss: vc.popupBar)
                
        vc.popupBar.ignoreLayoutDuringTransition = true
        UIView.animate(withDuration: animated ? vc.popupBar.popupBarPresentationDuration : 0.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [.curveLinear, .layoutSubviews], animations: {
            
            vc.configurePopupBarFromBottomBar()
            
            self.setPopupBarViewFrame(for: .hidden)
            
            self.fixInsetsForContainerIfNeeded(addInsets: false)
        }) { (success) in
            let previousState = self.popupPresentationState
            self.popupPresentationState = .hidden
            self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
            
            vc.popupContentView.removeFromSuperview()
            vc.popupContentView = nil
            
            vc.popupBar.removeFromSuperview()
            self.delegate?.popupController?(self, didDismiss: vc.popupBar)
            vc.popupBar = nil
            self.popupBarView?.removeFromSuperview()
            self.popupBarView = nil
            self.popupPresentationState = .dismissed
            vc.popupContentViewController.popupContainerViewController = nil
            vc.popupContentViewController.popupCloseButton = nil
            vc.popupContentViewController = nil
            
            completionBlock?()
        }
    }
    
    internal func _hidePopupBarAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil)
    {
        guard let vc = self.containerViewController else {
            completionBlock?()
            return
        }
        
        if self.popupPresentationState == .hidden {
            completionBlock?()
            return
        }
        
        self.popupPresentationState = .dismissing
        
        let block = {
            vc.configurePopupBarFromBottomBar()
            self.setPopupBarViewFrame(for: .hidden)
            self.fixInsetsForContainerIfNeeded(addInsets: false)
        }
        
        if animated {
            UIView.animate(withDuration: animated ? vc.popupBar.popupBarPresentationDuration : 0.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [.curveLinear, .layoutSubviews], animations: {
                block()
            }) { (success) in
                self.popupPresentationState = .hidden
                completionBlock?()
            }
        }
        else {
            block()
            self.popupPresentationState = .hidden
        }
    }
    
    internal func _showPopupBarAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil)
    {
        self._presentPopupBarAnimated(animated, completionBlock: nil)
    }
    
    internal func _presentPopupAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil)
    {
        self.popupPresentationState = .closed
        self._openPopupAnimated(animated) {
            completionBlock?()
        }
    }
    
    internal func _dismissPopupAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil)
    {
        self._closePopupAnimated(animated) {
            completionBlock?()
        }
    }
    
    internal func fixInsetsForContainerIfNeeded(addInsets: Bool = true, layout: Bool = true)
    {
        guard let vc = self.containerViewController else {
            return
        }
        let height = vc.popupBar.popupBarHeight
        var additionalInsets = UIEdgeInsets()
        if self.wantsAdditionalSafeAreaInsetBottom {
            additionalInsets.bottom += addInsets ? height : -height
        }
        if self.wantsAdditionalSafeAreaInsetTop {
            additionalInsets.top += addInsets ? height : -height
        }
        PBPopupFixInsetsForViewController(vc, layout, additionalInsets)
    }
    
    
    // MARK: - Gesture recognizers
    
    @objc internal func popupTapGestureRecognized(tgr: UITapGestureRecognizer)
    {
        self._prepareRigidFeedback()
        
        if self.delegate?.popupControllerTapGestureShouldBegin?(self, state: self.popupPresentationState) == false {
            return
        }
        if let vc = self.containerViewController {
            if self.delegate?.popupController?(self, shouldOpen: vc.popupContentViewController) == false {
                return
            }
            
            self._generateRigidFeedbackWithIntensity(self.rigidFeedbackGeneratorIntensity)
            
            vc.popupBar.setHighlighted(true, animated: false)
            self._openPopupAnimated(true) {
                vc.popupBar.setHighlighted(false, animated: false)
            }
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.popupBarTapGestureRecognizer && otherGestureRecognizer == self.popupBarPanGestureRecognizer {
            return true
        }
        return false
    }
    
    // MARK: - Popup Content Animation
    
    internal func preparePopupContentViewControllerForPresentation()
    {
        if let vc = self.containerViewController {
            if vc.popupContentView.popupPresentationStyle != .popup {
                self.popupPresentationInteractiveController = PBPopupInteractivePresentationController()
                self.popupPresentationInteractiveController.attachToViewController(popupController: self, withView: self.popupBarView, presenting: true)
                self.popupPresentationInteractiveController.delegate = self
            }
            
            self.popupDismissalInteractiveController = PBPopupInteractivePresentationController()
            if vc.popupContentView.popupContentDraggingView != nil {
                vc.popupContentView.addSubview(vc.popupContentView.popupContentDraggingView)
                self.popupDismissalInteractiveController.attachToViewController(popupController: self, withView: vc.popupContentView.popupContentDraggingView, presenting: false)
            }
            else {
                self.popupDismissalInteractiveController.attachToViewController(popupController: self, withView: vc.popupContentView, presenting: false)
            }
            self.popupDismissalInteractiveController.delegate = self
            
            if let popupVC = vc.popupContentViewController {
                popupVC.transitioningDelegate = self
                popupVC.modalPresentationStyle = .custom
                popupVC.isModalInPresentation = true
                popupVC.modalPresentationCapturesStatusBarAppearance = true
            }
        }
    }
    
    @objc internal func closePopupContent()
    {
        self._prepareRigidFeedback()
        // The popup content has a popup open. Close it before closing the main popup content.
        if let popupController =  UIViewController.getAssociatedPopupControllerFor(self.containerViewController.popupContentViewController) {
            if popupController.popupPresentationState == .open {
                popupController.closePopupContent(animated: false) {
                    if self.containerViewController.popupContentView.popupCanDismissOnPassthroughViews {
                        if self.popupPresentationState == .open {
                            self.closePopupContent(animated: true)
                        }
                    }
                }
            }
            else {
                // Close popup content.
                if self.popupPresentationState == .open {
                    self._generateRigidFeedbackWithIntensity(self.rigidFeedbackGeneratorIntensity)
                    self.closePopupContent(animated: true)
                }
            }
        }
        else {
            // Close popup content.
            if self.popupPresentationState == .open {
                self._generateRigidFeedbackWithIntensity(self.rigidFeedbackGeneratorIntensity)
                self.closePopupContent(animated: true)
            }
        }
    }
    
    @objc internal func closePopupContent(animated: Bool = true, completionBlock: (() -> Swift.Void)? = nil)
    {
        guard let vc = self.containerViewController else {
            return
        }
        if self.delegate?.popupController?(self, shouldClose: vc.popupContentViewController) == false {
            return
        }
        
        if vc.popupContentView.popupPresentationStyle == .popup {
            vc.dismissPopup(animated: animated) {
                completionBlock?()
            }
        }
        else {
            self._closePopupAnimated(true)
        }
    }
    
    internal func _openPopupAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil)
    {
        guard let vc = self.containerViewController else {
            completionBlock?()
            return
        }
        if vc.popupContentViewController == nil {
            completionBlock?()
            return
        }
        
        if self.popupPresentationState != .closed {
            completionBlock?()
            return
        }
        
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        
        self.disableInteractiveTransitioning = true
        self.popupContentPanGestureRecognizer.isEnabled = false
        let previousState = self.popupPresentationState
        self.popupPresentationState = .opening
        self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
        self.delegate?.popupController?(self, willOpen: vc.popupContentViewController)
        
        if let block = self.delegate?.additionalAnimationsForOpening?(popupController: self, popupContentViewController: vc.popupContentViewController, isInteractive: false) {
            self._delegate_additionalAnimationsForOpening = block
        }
        
        // TODO: SwiftUI
        if NSStringFromClass(type(of: vc.popupContentViewController).self).contains("PBPopupUIContentController") {
            if (vc.popupContentView.superview != nil) {
                vc.popupContentViewController.view.removeFromSuperview()
                vc.popupContentView.removeFromSuperview()
            }
        }
        //
        
        self.updatePopupStatusBarStyle(for: self.popupPresentationState, previousState: previousState)
        
        vc.present(vc.popupContentViewController, animated: true) {
            if let scrollView = vc.popupContentViewController.view as? UIScrollView {
                self.popupDismissalInteractiveController.contentOffset = scrollView.contentOffset
            }
            let previousState = self.popupPresentationState
            self.popupPresentationState = .open
            self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
            self.delegate?.popupController?(self, didOpen: vc.popupContentViewController)
            self._delegate_additionalAnimationsForOpening = nil
            completionBlock?()
            self.disableInteractiveTransitioning = false
            self.popupContentPanGestureRecognizer.isEnabled = true
        }
    }
    
    internal func _closePopupAnimated(_ animated: Bool, completionBlock: (() -> Swift.Void)? = nil)
    {
        guard let vc = self.containerViewController else {
            completionBlock?()
            return
        }
        if vc.popupContentViewController == nil {
            completionBlock?()
            return
        }
        if self.popupPresentationState != .open {
            completionBlock?()
            return
        }
        
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        
        self.disableInteractiveTransitioning = true
        let previousState = self.popupPresentationState
        self.popupPresentationState = .closing
        self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
        self.delegate?.popupController?(self, willClose: vc.popupContentViewController)
        
        if let block = self.delegate?.additionalAnimationsForClosing?(popupController: self, popupContentViewController: vc.popupContentViewController, isInteractive: false) {
            self._delegate_additionalAnimationsForClosing = block
        }
        
        self.updatePopupStatusBarStyle(for: self.popupPresentationState, previousState: previousState)

        vc.popupContentViewController.dismiss(animated: animated) {
            let previousState = self.popupPresentationState
            self.popupPresentationState = .closed
            self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
            self.delegate?.popupController?(self, didClose: vc.popupContentViewController)
            if let scrollView = vc.popupContentViewController.view as? UIScrollView {
                self.popupDismissalInteractiveController.contentOffset = scrollView.contentOffset
            }
            self._delegate_additionalAnimationsForClosing = nil
            self.popupPresentationController = nil
            
            // TODO: SwiftUI
            if NSStringFromClass(type(of: vc.popupContentViewController).self).contains("PBPopupUIContentController") {
                vc.popupContentView.insertSubview(vc.popupContentViewController.view, at: 0)
                vc.view.insertSubview(vc.popupContentView, at: 0)
            }
            //
            completionBlock?()
            self.disableInteractiveTransitioning = false
        }
    }
    
    // MARK: - Helpers
    
    internal func delay(_ delay:Double, closure:@escaping ()->())
    {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    // MARK: - Frames
    
    internal func statusBarOrientation(for view: UIView) -> UIInterfaceOrientation
    {
        var statusBarOrientation: UIInterfaceOrientation = .unknown
#if !targetEnvironment(macCatalyst)
        statusBarOrientation = view.window?.windowScene?.interfaceOrientation ?? .unknown
#endif
        
        return statusBarOrientation
    }
    
    internal func statusBarFrame(for view: UIView) -> CGRect
    {
        var statusBarFrame: CGRect = .zero
#if !targetEnvironment(macCatalyst)
        statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
#else
        let insets = view.superview?.safeAreaInsets ?? .zero
        statusBarFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: insets.top)
#endif
        
        return statusBarFrame
    }
    
    internal func statusBarHeight(for view: UIView) -> CGFloat
    {
        var statusBarHeight: CGFloat = 0
#if !targetEnvironment(macCatalyst)
        statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0.0
#else
        let insets = view.superview?.safeAreaInsets ?? .zero
        statusBarHeight = insets.top
#endif
        
        return statusBarHeight
    }
    
    internal func statusBarIsHidden(for view: UIView) -> Bool
    {
#if !targetEnvironment(macCatalyst)
        return view.window?.windowScene?.statusBarManager?.isStatusBarHidden ?? false
#else
        return false
#endif
    }
    
    internal func popupBarViewFrameForPopupStateHidden() -> CGRect
    {
        guard let vc = self.containerViewController else { return .zero }
        
        var frame = self.popupBarViewFrameForPopupStateClosed()
        
        let insets = vc.insetsForBottomBar()
        
        frame.origin.y += self.wantsAdditionalSafeAreaInsetTop ? -vc.popupBar.popupBarHeight : vc.popupBar.popupBarHeight + insets.bottom
        
        if vc.popupBarIsHidden || vc.popupBar.isFloating {
            frame.origin.y = self.wantsAdditionalSafeAreaInsetTop ? vc.view.bounds.minY : vc.view.bounds.height
        }
        PBLog("\(frame)")
        return frame
    }
        
    internal func popupBarViewFrameForPopupStateClosed() -> CGRect
    {
        guard let vc = self.containerViewController else { return .zero }

        let defaultFrame = vc.defaultFrameForBottomBar()
        
        let insets = vc.insetsForBottomBar()
        
        var height = vc.popupBar.popupBarHeight
        
        let width = vc.popupBar.popupBarWidth
        
        // Safe Area
        if self.bottomBarIsHidden, vc.popupBar.popupBarStyle != .custom || vc.popupBar.shouldExtendCustomBarUnderSafeArea {
            height += insets.bottom
        }
        let x = max((defaultFrame.size.width - width) / 2, defaultFrame.origin.x)
        
        var y = defaultFrame.origin.y - height
        y -= vc.popupBar.popupBarStyle == .custom && self.bottomBarIsHidden ? insets.bottom : 0.0
        
        var frame = CGRect(x: x, y: y, width: min(defaultFrame.size.width, width), height: height)
        
        if let svc = vc.splitViewController, vc === svc.viewControllers.first {
            frame.origin.x += abs(vc.view.frame.minX)
            frame.size.width -= abs(vc.view.frame.minX)
        }
        PBLog("\(frame)")
        return frame
    }
        
    internal func setPopupBarViewFrame(for state: PBPopupPresentationState) {
        if state == .hidden {
            self.popupBarView.frame = self.popupBarViewFrameForPopupStateHidden()
        }
        else {
            self.popupBarView.frame = self.popupBarViewFrameForPopupStateClosed()
        }
    }
}

// MARK: - Custom Animations delegate

extension PBPopupController: UIViewControllerTransitioningDelegate
{
    /**
     :nodoc:
     */
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        self.popupPresentationController?.shouldUseSnapshotForPresentingView = self.shouldUseSnapshotForPresentingView
        // TODO: SwiftUI
        if NSStringFromClass(type(of: presented).self).contains("PBPopupUIContentController") {
            self.popupPresentationController?.shouldUseSnapshotForPresentingView = true
        }
        //
        self.popupPresentationController?.isPresenting = true
        self.popupPresentationController?.popupController = self
        self.popupPresentationController?.popupPresentationStyle = self.containerViewController.popupContentView.popupPresentationStyle
        
        return self.popupPresentationController
    }
    
    /**
     :nodoc:
     */
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        self.popupPresentationController?.shouldUseSnapshotForPresentingView = self.shouldUseSnapshotForPresentingView
        // TODO: SwiftUI
        if NSStringFromClass(type(of: dismissed).self).contains("PBPopupUIContentController") {
            self.popupPresentationController?.shouldUseSnapshotForPresentingView = true
        }
        //
        self.popupPresentationController?.isPresenting = false
        self.popupPresentationController?.popupController = self
        self.popupPresentationController?.popupPresentationStyle = self.containerViewController.popupContentView.popupPresentationStyle
        
        return self.popupPresentationController
    }
    
    /**
     :nodoc:
     */
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        self.popupPresentationController = PBPopupPresentationController(presentedViewController: presented, presenting: self.containerViewController)
        
        if self.isContainerPresentationSheet {
            presented.modalPresentationCapturesStatusBarAppearance = false
        }
        
        return self.popupPresentationController
    }
    
    /**
     :nodoc:
     */
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        guard !self.disableInteractiveTransitioning else { return nil }
        
        return self.popupPresentationInteractiveController
    }
    
    /**
     :nodoc:
     */
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        guard !self.disableInteractiveTransitioning else { return nil }
        
        return self.popupDismissalInteractiveController
    }
}

extension PBPopupController: PBPopupInteractivePresentationDelegate
{
    internal func presentInteractive()
    {
        if let vc = self.containerViewController {
            self.popupContentPanGestureRecognizer.isEnabled = false

            self._prepareSoftFeedback()
            
            if self.delegate?.popupController?(self, shouldOpen: vc.popupContentViewController) == false {
                return
            }
            vc.view.setNeedsLayout()
            vc.view.layoutIfNeeded()
            
            let previousState = self.popupPresentationState
            self.popupPresentationState = .transitioning
            self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
            // TODO: SwiftUI
            if NSStringFromClass(type(of: vc.popupContentViewController).self).contains("PBPopupUIContentController") {
                if (vc.popupContentView.superview != nil) {
                    vc.popupContentViewController.view.removeFromSuperview()
                    vc.popupContentView.removeFromSuperview()
                }
            }

            self._generateSoftFeedbackWithIntensity(self.softFeedbackGeneratorIntensity)
            
            self.updatePopupStatusBarStyle(for: self.popupPresentationState, previousState: previousState)
            
            vc.present(vc.popupContentViewController, animated: true) {
                if self.popupPresentationState == .opening {
                    if let scrollView = vc.popupContentViewController.view as? UIScrollView {
                        self.popupDismissalInteractiveController.contentOffset = scrollView.contentOffset
                    }
                    let previousState = self.popupPresentationState
                    self.popupPresentationState = .open
                    self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
                    self.delegate?.popupController?(self, didOpen: vc.popupContentViewController)
                }
                // TODO: SwiftUI
                else {
                    self.popupPresentationController = nil
                    if NSStringFromClass(type(of: vc.popupContentViewController).self).contains("PBPopupUIContentController") {
                        vc.popupContentView.insertSubview(vc.popupContentViewController.view, at: 0)
                        vc.view.insertSubview(vc.popupContentView, at: 0)
                    }
                }
                //
                self.popupContentPanGestureRecognizer?.isEnabled = true
            }
        }
    }
    
    internal func dismissInteractive()
    {
        if let vc = self.containerViewController {
            if self.delegate?.popupController?(self, shouldClose: vc.popupContentViewController) == false {
                return
            }

            self._prepareSoftFeedback()
            
            vc.view.setNeedsLayout()
            vc.view.layoutIfNeeded()
            
            let previousState = self.popupPresentationState
            self.popupPresentationState = .transitioning
            self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
            
            self._generateSoftFeedbackWithIntensity(self.softFeedbackGeneratorIntensity)
            
            self.updatePopupStatusBarStyle(for: self.popupPresentationState, previousState: previousState)
            
            vc.popupContentViewController.dismiss(animated: true) {
                if self.popupPresentationState == .closing {
                    if let scrollView = vc.popupContentViewController.view as? UIScrollView {
                        self.popupDismissalInteractiveController.contentOffset = scrollView.contentOffset
                    }
                    let previousState = self.popupPresentationState
                    self.popupPresentationState = .closed
                    self.delegate?.popupController?(self, stateChanged: self.popupPresentationState, previousState: previousState)
                    self.delegate?.popupController?(self, didClose: vc.popupContentViewController)

                    self.popupPresentationController = nil
                    // TODO: SwiftUI
                    if NSStringFromClass(type(of: vc.popupContentViewController).self).contains("PBPopupUIContentController") {
                        vc.popupContentView.insertSubview(vc.popupContentViewController.view, at: 0)
                        vc.view.insertSubview(vc.popupContentView, at: 0)
                    }
                    //
                    self.popupBarPanGestureRecognizer?.isEnabled = true
                }
            }
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension PBPopupController: UIViewControllerPreviewingDelegate
{
    /**
     :nodoc:
     */
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController?
    {
        if let vc = self.containerViewController {
            if let rv = vc.popupBar.previewingDelegate?.previewingViewControllerFor?(vc.popupBar) {
                
                // Disable interaction if a preview view controller is about to be presented.
                self.popupBarTapGestureRecognizer?.isEnabled = false
                self.popupBarPanGestureRecognizer?.isEnabled = false
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    self.popupBarTapGestureRecognizer?.isEnabled = true
                    self.popupBarPanGestureRecognizer?.isEnabled = true
                })
                return rv
            }
        }
        return nil
    }
    
    /**
     :nodoc:
     */
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let vc = self.containerViewController
        {
            vc.popupBar.previewingDelegate?.popupBar?(vc.popupBar, commit: viewControllerToCommit)
        }
    }
}
