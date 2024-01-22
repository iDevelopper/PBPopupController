//
//  FirstTableViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 22/10/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class FirstTableViewController: UITableViewController, PBPopupControllerDataSource {
    
    // MARK: - Properties
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitle: UILabel! {
        didSet {
            let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            headerTitle.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
            headerTitle.adjustsFontForContentSizeCategory = true
        }
    }
    
    var popupContentVC: PopupContentViewController!
    var popupContentTVC: PopupContentTableViewController!

    weak var containerVC: UIViewController!
    
    var containerIsBarController: Bool {
        return self.containerVC is UITabBarController || self.containerVC is UINavigationController
    }
    
    var demoViewController: DemoViewController!

    var popupPlayButtonItem: UIBarButtonItem!
    var popupNextButtonItem: UIBarButtonItem!
    var popupPrevButtonItem: UIBarButtonItem!
    var popupMoreButtonItem: UIBarButtonItem!

    var popupBarIsFloating: Bool!
    var popupBarStyle: PBPopupBarStyle!
    var progressViewStyle: PBPopupBarProgressViewStyle!
    var popupPresentationStyle: PBPopupPresentationStyle!
    var popupCloseButtonStyle: PBPopupCloseButtonStyle!
    
    var isPopupContentTableView: Bool = false
    
    var images = [UIImage]()
    var titles = [String]()
    var subtitles = [String]()
    
    // Labels for popup bar data source
    var label: MarqueeLabel? = {
        let marqueeLabel = MarqueeLabel(frame: .zero, rate: 15, fadeLength: 10)
        marqueeLabel.leadingBuffer = 0.0   // 0
        marqueeLabel.trailingBuffer = 5.0  // 5
        marqueeLabel.animationDelay = 1.0
        marqueeLabel.type = .continuous
        return marqueeLabel
    }()
    
    var sublabel: MarqueeLabel? = {
        let marqueeLabel = MarqueeLabel(frame: .zero, rate: 20, fadeLength: 10)
        marqueeLabel.leadingBuffer = 0.0
        marqueeLabel.trailingBuffer = 5.0
        marqueeLabel.animationDelay = 1.0
        marqueeLabel.type = .continuous
        return marqueeLabel
    }()

    var effectView: UIVisualEffectView!

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for idx in 1...self.tableView(tableView, numberOfRowsInSection: 3) {
            let imageName = String(format: "Cover%02d", idx)
            images += [UIImage(named: imageName)!]
            titles += [LoremIpsum.title]
            subtitles += [LoremIpsum.sentence]
        }
        
        self.tableView.backgroundColor = UIColor.PBRandomAdaptiveColor()
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.tableHeaderView = nil
        if (self.navigationController == nil) {
            self.tableView.tableHeaderView = self.headerView
        }
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80.0
        
        self.setupContainerVC()
        
        //self.containerVC.usePopupBarLegacyShadow = true
        //self.containerVC.usePopupBarSmoothGradient = false
        if #available(iOS 17.0, *) {
            if let popupBar = self.containerVC?.popupBar {
                popupBar.isFloating = true
                self.popupBarIsFloating = true
            }
        }
        self.firstSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let containerVC = self.containerVC, let popupContentView = containerVC.popupContentView {
            let height = self.containerVC.view.bounds.height * (self.traitCollection.verticalSizeClass == .compact ? 0.90 : 0.75)
            popupContentView.popupContentSize = CGSize(width: -1, height: height)
            //popupContentView.popupContentSize = CGSize(width: self.containerVC.view.bounds.width - 40, height: height)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupToolbarAppearance()
        
        self.tabBarController?.delegate = self
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        /*
        guard let popupBar = self.containerVC.popupBar else { return }
        popupBar.floatingBackgroundShadow.shadowColor = self.traitCollection.userInterfaceStyle == .light ? UIColor.cyan.withAlphaComponent(0.80) : UIColor.magenta.withAlphaComponent(0.30)
        */
    }
    
    /*
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if let containerVC = self.containerVC, let popupContentView = containerVC.popupContentView {
            let height = self.view.bounds.height * (self.traitCollection.verticalSizeClass == .compact ? 0.90 : 0.75)
            popupContentView.popupContentSize = CGSize(width: -1, height: height)
        }
    }
    */
    
    deinit {
        PBLog("deinit \(self)")
    }

    // MARK: - Navigation
    
    @IBAction func pushNextAndHideBottomBar(_ sender: Any) {
        self.pushNext(self)
    }

    @IBAction func pushNext(_ sender: Any) {
        if let splitVC = self.splitViewController as? SplitViewController {
            if self.traitCollection.horizontalSizeClass == .compact {
                if let detailVC = splitVC.detailVC {
                    if detailVC != self.navigationController {
                        if #available(iOS 14.0, *) {
                            splitVC.show(detailVC, sender: self)
                        }
                        else {
                            splitVC.showDetailViewController(detailVC, sender: self)
                        }
                        return
                    }
                }
            }
        }

        var nextVC: UIViewController! = nil
        if let navigationController = self.navigationController as? NavigationController {
            navigationController.toolbarIsShown = false
            nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DemoTableViewController") as! DemoTableViewController
            (nextVC as! DemoTableViewController).firstVC = self
        }
        else {
            nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DemoTableViewController") as! DemoTableViewController
            (nextVC as! DemoTableViewController).firstVC = self
        }
        if let nextVC = nextVC {
            nextVC.hidesBottomBarWhenPushed = true
            if sender is FirstTableViewController {
                nextVC.hidesPopupBarWhenPushed = true
            }
            if let navigationController = self.navigationController as? NavigationController {
                navigationController.toolbarIsShown = false
            }
            nextVC.title = self.title
            nextVC.modalPresentationStyle = .currentContext
            self.show(nextVC, sender: sender)
        }
    }

    // Home bar button item
    @IBAction func dismiss(_ sender: Any?) {
        self.popupContentVC = nil
        self.popupContentTVC = nil
                
        self.containerVC.dismissPopupBar(animated: false) {
            if sender is UIBarButtonItem || sender is UIButton { // Home button
#if targetEnvironment(macCatalyst)
                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                guard let windowScene = window?.windowScene else {
                    return
                }
                if let titlebar = windowScene.titlebar, let toolbar = titlebar.toolbar {
                    toolbar.isVisible = false
                    titlebar.toolbar = nil
                }
#endif
                
                self.performSegue(withIdentifier: "unwindToHome", sender: sender)
            }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.restoreInitialRootViewControllerIfNeeded()
        }
    }
    
    // MARK: - Setups
    
    func setupContainerVC() {
        if let splitViewController = self.splitViewController as? SplitViewController {
            if let containerVC = splitViewController.containerVC {
                self.containerVC = containerVC
            }
            else {
                if splitViewController.globalIsContainer == true {
                    self.containerVC = splitViewController
                }
                else if splitViewController.masterIsContainer == true {
                    self.containerVC = splitViewController.viewControllers.first
                }
                else {
                    self.containerVC = splitViewController.viewControllers.last
                }
                if let nc = splitViewController.viewControllers.first as? UINavigationController {
                    nc.topViewController?.title = splitViewController.globalIsContainer ? "Split View Controller (Global)": splitViewController.masterIsContainer ? "Split View Controller (Master)" : "Split View Controller (Detail)"
                }
                splitViewController.containerVC = self.containerVC
                if let nc = splitViewController.viewControllers.last as? UINavigationController {
                    splitViewController.detailVC = nc
                    nc.topViewController?.title = "Split View Controller (Detail)"
                }
            }
        }
        else if let tabBarController = self.tabBarController {
            self.containerVC = tabBarController
            if let navigationController = self.navigationController {
                navigationController.isToolbarHidden = true
            }
            else {
                self.headerTitle.text = tabBarController.title
            }
        }
        else if let navigationController = self.navigationController as? NavigationController {
            navigationController.isToolbarHidden = true
            if navigationController.toolbarIsShown {
                navigationController.isToolbarHidden = false
            }
            self.containerVC = navigationController
            if let containerController = navigationController.parent {
                self.containerVC = containerController
            }
        }
        else if let containerController = self.parent {
            self.containerVC = containerController
            self.headerTitle.text = containerController.title
        }
        else {
            self.containerVC = self
        }
    }
    
    func setupContentVC() {
        self.popupContentVC = self.storyboard?.instantiateViewController(withIdentifier: "PopupContentViewController") as? PopupContentViewController
        self.popupContentVC.overrideUserInterfaceStyle = self.navigationController?.overrideUserInterfaceStyle ?? .unspecified
        self.popupContentVC.images = self.images
        self.popupContentVC.titles = self.titles
        self.popupContentVC.subtitles = self.subtitles
    }
    
    func setupContentTVC() {
        self.popupContentTVC = self.storyboard?.instantiateViewController(withIdentifier: "PopupContentTableViewController2") as? PopupContentTableViewController
        self.popupContentTVC.overrideUserInterfaceStyle = self.navigationController?.overrideUserInterfaceStyle ?? .unspecified
        self.popupContentTVC.images = self.images
        self.popupContentTVC.titles = self.titles
        self.popupContentTVC.subtitles = self.subtitles
    }
    
    func setupToolbarAppearance(withBackgroundColor backgroundColor: UIColor? = nil) {
        if let navigationController = self.navigationController as? NavigationController {
            let navigationBarAppearance = navigationController.navigationBar.standardAppearance
            
            let toolbarAppearance = UIToolbarAppearance()
            toolbarAppearance.configureWithDefaultBackground()
            
            toolbarAppearance.backgroundEffect = navigationBarAppearance.backgroundEffect
            
            navigationBarAppearance.backgroundColor = backgroundColor
            if backgroundColor == nil {
                toolbarAppearance.backgroundColor = navigationBarAppearance.backgroundColor
            }
            else {
                toolbarAppearance.backgroundColor = backgroundColor
            }
            navigationController.navigationBar.compactAppearance = navigationBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            if #available(iOS 15.0, *) {
                navigationController.navigationBar.compactScrollEdgeAppearance = navigationBarAppearance
            }

            navigationController.toolbar.compactAppearance = toolbarAppearance
            navigationController.toolbar.standardAppearance = toolbarAppearance
        }
    }
    
    func firstSetup() {
        
        self.commonSetup()
        
        self.setupPopupBar()
        
        self.setupCustomPopupBar()
                
        self.commonSetup()
        
        self.setupBarButtonItems()
    }
    
    func commonSetup() {
        if let popupBar = self.containerVC?.popupBar {
            self.popupBarIsFloating = popupBar.isFloating
            
            self.popupBarStyle = popupBar.popupBarStyle
            
            self.progressViewStyle = popupBar.progressViewStyle
            
            self.popupPresentationStyle = self.containerVC.popupContentView.popupPresentationStyle
            
            self.popupCloseButtonStyle = self.containerVC.popupContentView.popupCloseButtonStyle
            
            self.containerVC.popupController.delegate = self
            
#if targetEnvironment(macCatalyst)
            if let tabBarController = self.tabBarController, self.navigationController == nil {
                if tabBarController.modalPresentationStyle == .fullScreen {
                    self.containerVC.popupController.dataSource = self
                    self.setupToolbarIfNeeded()
                    self.containerVC.popupController.wantsAdditionalSafeAreaInsetBottom = false
                    self.containerVC.popupController.wantsAdditionalSafeAreaInsetTop = true
                }
            }
#endif
            self.tableView.reloadData()
        }
    }
    
    func setupCustomPopupBar() {
        if let popupBar = self.containerVC.popupBar {
            if self.popupBarStyle == .custom {
                if let customPopupBarVC = storyboard?.instantiateViewController(withIdentifier: "CustomPopupBarViewController") as? CustomPopupBarViewController {
                    customPopupBarVC.view.backgroundColor = UIColor.clear
                    popupBar.shouldExtendCustomBarUnderSafeArea = false
                    popupBar.inheritsVisualStyleFromBottomBar = false
                    let customView = UIView()
                    popupBar.backgroundCustomView = customView
                    popupBar.customPopupBarViewController = customPopupBarVC

                    customPopupBarVC.imageView.image = popupBar.image
                    customPopupBarVC.titleLabel.text = popupBar.title
                    customPopupBarVC.subtitleLabel.text = popupBar.subtitle
                }
            }
        }
    }
    
    func setupPopupBar() {
        if let popupBar = self.containerVC.popupBar {
            if #available(iOS 17.0, *) {
                popupBar.isFloating = self.popupBarStyle == .custom ? false : self.popupBarIsFloating
                /*
                var floatingInsets = popupBar.floatingInsets
                floatingInsets.left = 20
                floatingInsets.right = 20
                popupBar.floatingInsets = floatingInsets
                */
                //popupBar.floatingBackgroundColor = UIColor.systemMint
                //popupBar.floatingBackgroundEffect = UIBlurEffect(style: .systemMaterial)
                /*
                let userInterfaceStyle = self.traitCollection.userInterfaceStyle
                popupBar.floatingBackgroundShadow.shadowColor = userInterfaceStyle == .light ? UIColor.cyan.withAlphaComponent(0.80) : UIColor.magenta.withAlphaComponent(0.30)
                popupBar.floatingBackgroundShadow.shadowBlurRadius = 8.0
                */
            }
            //if #available(iOS 15.0, *) {
            //    popupBar.maximumContentSizeCategory = self.popupBarStyle == .prominent ? .accessibilityLarge : .small
            //}
            popupBar.dataSource = self.isPopupContentTableView ? nil : self
            popupBar.previewingDelegate = self
            
            popupBar.inheritsVisualStyleFromBottomBar = self.containerIsBarController ? true : false
            popupBar.shadowImageView.shadowOpacity = 0
            popupBar.borderViewStyle = .none

            popupBar.image?.accessibilityLabel = NSLocalizedString("Cover", comment: "")
            
            if self.containerVC is UITabBarController, self.navigationController == nil {
                let interaction = UIContextMenuInteraction(delegate: self)
                popupBar.addInteraction(interaction)
            }
            //popupBar.semanticContentAttribute = .forceRightToLeft
            //popupBar.barButtonItemsSemanticContentAttribute = .forceRightToLeft
            
            
            //let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            //paragraphStyle.alignment = .center
            //paragraphStyle.lineBreakMode = .byTruncatingTail
            //containerVC.popupBar.titleTextAttributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.backgroundColor: UIColor.clear, NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)]
            
            if let popupContentView = self.containerVC.popupContentView {
                // TODO:
                //popupContentView.popupEffectView.effect = nil
                popupContentView.popupIgnoreDropShadowView = false
                //popupContentView.popupPresentationDuration = 0.4
                popupContentView.popupCanDismissOnPassthroughViews = true
                //popupContentView.popupContentDraggingView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200))
            }
            
            self.containerVC.popupController.containerPreferredStatusBarStyle = .default
            self.containerVC.popupController.popupPreferredStatusBarStyle = .lightContent
        }
    }
    
    func setupBarButtonItems() {
        let scaleConfig = UIImage.SymbolConfiguration(scale: self.popupBarIsFloating || self.popupBarStyle == .compact ? .medium : .large)
        let weightConfig = UIImage.SymbolConfiguration(weight: .semibold)
        let config = scaleConfig.applying(weightConfig)
        
        var image: UIImage!
        image = UIImage(systemName: "play.fill", withConfiguration: config)?.withAlignmentRectInsets(.zero).imageWithoutBaseline()
        self.popupPlayButtonItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        image = UIImage(systemName: "forward.fill", withConfiguration: config)?.withAlignmentRectInsets(.zero).imageWithoutBaseline()
        self.popupNextButtonItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        image = UIImage(systemName: "ellipsis", withConfiguration: config)?.withAlignmentRectInsets(.zero).imageWithoutBaseline()
        self.popupMoreButtonItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        image = UIImage(systemName: "backward.fill", withConfiguration: config)?.withAlignmentRectInsets(.zero).imageWithoutBaseline()
        self.popupPrevButtonItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        
        self.popupPlayButtonItem.accessibilityLabel = NSLocalizedString("Play", comment: "")
        self.popupNextButtonItem.accessibilityLabel = NSLocalizedString("Next track", comment: "")
        self.popupMoreButtonItem.accessibilityLabel = NSLocalizedString("More", comment: "")
        self.popupPrevButtonItem.accessibilityLabel = NSLocalizedString("Previous track", comment: "")
        
        self.configureBarButtonItems()
    }
    
    func configureBarButtonItems() {
        if let popupBar = self.containerVC.popupBar {
            popupBar.leftBarButtonItems = nil
            popupBar.rightBarButtonItems = nil
            if UIDevice.current.userInterfaceIdiom == .phone {
                if popupBar.popupBarStyle == .prominent {
                    popupBar.leftBarButtonItems = nil
                    popupBar.rightBarButtonItems = [self.popupPlayButtonItem, self.popupNextButtonItem]
                }
                else {
                    popupBar.leftBarButtonItems = [self.popupPlayButtonItem]
                    popupBar.rightBarButtonItems = [self.popupMoreButtonItem]
                }
            }
            else {
                if popupBar.popupBarStyle == .prominent {
                    popupBar.leftBarButtonItems = nil
                    popupBar.rightBarButtonItems = [self.popupPlayButtonItem, self.popupNextButtonItem]
                }
                else {
                    popupBar.leftBarButtonItems = [self.popupPrevButtonItem, self.popupPlayButtonItem, self.popupNextButtonItem]
                    popupBar.rightBarButtonItems = [self.popupMoreButtonItem]
                }
            }
            let target = self.isPopupContentTableView ? self.popupContentTVC : self.popupContentVC
            self.popupPlayButtonItem.target = target
            self.popupPlayButtonItem.action = self.isPopupContentTableView ? #selector(PopupContentViewController.playPauseAction(_:)) : #selector(PopupContentTableViewController.playPauseAction(_:))
            self.popupNextButtonItem.target = target
            self.popupNextButtonItem.action = self.isPopupContentTableView ? #selector(PopupContentViewController.nextAction(_:)) : #selector(PopupContentTableViewController.nextAction(_:))
            self.popupPrevButtonItem.target = target
            self.popupPrevButtonItem.action = self.isPopupContentTableView ? #selector(PopupContentViewController.prevAction(_:)) : #selector(PopupContentTableViewController.prevAction(_:))
            self.popupMoreButtonItem.target = target
            self.popupMoreButtonItem.action = self.isPopupContentTableView ? #selector(PopupContentViewController.moreAction(_:)) : #selector(PopupContentTableViewController.moreAction(_:))
        }
    }
    
    // MARK: - Toolbar container actions
    
    @IBAction func defaultToolbarStyle(_ sender: UIBarButtonItem) {
        self.setupToolbarAppearance()
        self.navigationController?.overrideUserInterfaceStyle = .unspecified
        self.popupContentVC?.overrideUserInterfaceStyle = .unspecified
        self.popupContentTVC?.overrideUserInterfaceStyle = .unspecified
        let aColor = self.view.tintColor
        self.navigationController?.toolbar.tintColor = aColor
        (navigationController?.toolbar.items as NSArray?)?.enumerateObjects({ obj, idx, stop in
            (obj as! UIBarButtonItem).tintColor = self.navigationController?.toolbar.tintColor
        })
        self.navigationController?.navigationBar.tintColor = self.navigationController?.toolbar.tintColor
        self.navigationController?.updatePopupBarAppearance()
    }

    @IBAction func changeToolbarStyle(_ sender: Any) {
        let navBarAppearance = self.navigationController?.navigationBar.standardAppearance
        if navBarAppearance?.backgroundColor == nil {
            self.setupToolbarAppearance(withBackgroundColor: UIColor.PBRandomAdaptiveColor())
        }
        else {
            self.setupToolbarAppearance()
        }
        let interfaceStyle = Int.random(in: 0..<3)
        self.navigationController?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue:interfaceStyle) ?? .unspecified
        self.popupContentVC?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue:interfaceStyle) ?? .unspecified
        self.popupContentTVC?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue:interfaceStyle) ?? .unspecified
        let aColor = UIColor.PBRandomAdaptiveInvertedColor()
        self.navigationController?.toolbar.tintColor = aColor
        (navigationController?.toolbar.items as NSArray?)?.enumerateObjects({ obj, idx, stop in
            (obj as! UIBarButtonItem).tintColor = self.navigationController?.toolbar.tintColor
        })
        self.navigationController?.navigationBar.tintColor = self.navigationController?.toolbar.tintColor
        self.navigationController?.updatePopupBarAppearance()
    }
    
    // MARK: - Setup Styles Actions
    
    @IBAction func barIsFloatingChanged(_ sender: UISwitch) {
        if self.popupBarStyle == .custom { return }
        
        self.popupBarIsFloating = sender.isOn
                        
        if let popupBar = self.containerVC?.popupBar {
            popupBar.isFloating = self.popupBarIsFloating
        }
        self.setupBarButtonItems()

        self.commonSetup()
    }

    @IBAction func popupBarStyleChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.popupBarStyle = .default
        case 1:
            self.popupBarStyle = .prominent
        case 2:
            self.popupBarStyle = .compact
        case 3:
            self.popupBarStyle = .custom
        default:
            break
        }
        
        if self.popupBarStyle == .custom {
            self.setupCustomPopupBar()
            return
        }
        
        self.setupPopupBar()
        
        if let popupBar = self.containerVC.popupBar {
            popupBar.popupBarStyle = self.popupBarStyle
        }
        self.setupBarButtonItems()
        
        self.commonSetup()
    }
    
    @IBAction func progressViewStyleChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.progressViewStyle = .default
        case 1:
            self.progressViewStyle = .bottom
        case 2:
            self.progressViewStyle = .top
        case 3:
            self.progressViewStyle = PBPopupBarProgressViewStyle.none
        default:
            break
        }
        if self.progressViewStyle == nil {
            self.containerVC.popupBar.progressViewStyle = .none
        }
        else {
            self.containerVC.popupBar.progressViewStyle = self.progressViewStyle
            self.containerVC.popupBar.progress = 0.5
        }

        self.commonSetup()
    }
    
    @IBAction func popupPresentationStyleChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.popupPresentationStyle = .default
        case 1:
            self.popupPresentationStyle = .deck
        case 2:
            self.popupPresentationStyle = .fullScreen
        case 3:
            self.popupPresentationStyle = .custom
        default:
            break
        }
        
        self.containerVC.popupContentView.popupPresentationStyle = self.popupPresentationStyle
        
        self.commonSetup()
    }
    
    @IBAction func popupCloseButtonStyleChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.popupCloseButtonStyle = .default
        case 1:
            self.popupCloseButtonStyle = .chevron
        case 2:
            self.popupCloseButtonStyle = .round
        case 3:
            self.popupCloseButtonStyle = PBPopupCloseButtonStyle.none
        default:
            break
        }
        if self.popupCloseButtonStyle == nil {
            self.containerVC.popupContentView.popupCloseButtonStyle = .none
        }
        else {
            self.containerVC.popupContentView.popupCloseButtonStyle = self.popupCloseButtonStyle
        }
        
        self.commonSetup()
    }
    
    @IBAction func popupContentViewChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.isPopupContentTableView = false
            self.popupContentTVC = nil
        case 1:
            self.isPopupContentTableView = true
            self.popupContentVC = nil
        default:
            break
        }
        
        self.setupPopupBar()
        
        self.commonSetup()
        
        if self.containerVC.popupController.popupPresentationState == .closed {
            // Present the popup bar with another popup content
            self.presentPopupBar(self)
        }
    }
    
    // MARK: - Popup Bar Actions
    
    @IBAction func presentPopupBar(_ sender: Any) {
        if #available(iOS 14.0, *) {
            if let svc = self.splitViewController, svc.isCollapsed {
                if let containerVC = self.containerVC, !(containerVC is UISplitViewController), let nc = self.navigationController, nc != containerVC {
                    return
                }
            }
        }
        
        self.firstSetup()

        // If sender is the present item of the navigation controller toolbar
        if sender is UIBarButtonItem {
            self.updatePopupBar(forRowAt: 0)
        }
        
        self.isPopupContentTableView ? self.setupContentTVC() : self.setupContentVC()

        self.setupBarButtonItems()

        DispatchQueue.main.async {
            self.containerVC.presentPopupBar(withPopupContentViewController: self.isPopupContentTableView ? self.popupContentTVC : self.popupContentVC, animated: true, completion: {
                PBLog("Popup Bar Presented")
            })
        }
    }
    
    @IBAction func dismissPopupBar(_ sender: Any) {
        // TODO: Test pop when hidesPopupBarWhenPushed is true.
        // self.navigationController?.popToRootViewController(animated: true)
        
        // self.navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
        
        // TODO: Comment below if test:
        //
        self.containerVC.dismissPopupBar(animated: true, completion: {
            PBLog("Popup Bar Dismissed")
        })
        //
    }
}

extension FirstTableViewController {
    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, sender: Any?) -> Bool {
        let result = super.canPerformUnwindSegueAction(action, from: fromViewController, sender: sender)
        
        self.popupContentVC = nil
        self.popupContentTVC = nil
        if let containerVC = self.containerVC {
            containerVC.dismissPopupBar(animated: true, completion: nil)
        }

        print("\(self) \(#function) \(action) \(result)")
        
        return result
    }

    override func dismiss(animated: Bool, completion: (() -> Void)?) {
        print("\(self) \(#function)")
        super.dismiss(animated:animated, completion: completion)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let result = super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        if identifier == "unwindToHome" {
            print("\(self) \(#function) \(result)")
        }
        return result
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToHome" {
            print("\(self) \(#function)")
        }
    }
}

    // MARK: - Table view data source

extension FirstTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.containerVC != nil {
            return 4
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 5
        case 2:
            return 3
        case 3:
            return 22
        default:
            break
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Floating Popup Bar
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.switchLabel.text = "Floating Popup Bar"
            cell.switchSwitch.isOn = self.containerVC.popupBar.isFloating
            cell.switchSwitch.addTarget(self, action: #selector(barIsFloatingChanged(_:)), for: .valueChanged)
            cell.switchLabel.font = UIFont.preferredFont(forTextStyle: .body)
            
            cell.switchLabel.textColor = UIColor.label

            cell.switchLabel.adjustsFontForContentSizeCategory = true
            cell.selectionStyle = .none

            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "segmentedTableViewCell", for: indexPath) as! SegmentedTableViewCell
            switch indexPath.row {
            case 0:
                // PopupBarStyle
                cell.titleLabel.text = "PopupBarStyle"
                cell.segmentedControl.removeAllSegments()
                cell.segmentedControl.insertSegment(withTitle: "Default", at: 0, animated: false)
                for idx in 0..<PBPopupBarStyle.strings.count {
                    cell.segmentedControl.insertSegment(withTitle: PBPopupBarStyle.strings[idx], at: idx+1, animated: false)
                }
                self.popupBarStyle = self.containerVC.popupBar.popupBarStyle
                cell.segmentedControl.selectedSegmentIndex = self.popupBarStyle.rawValue + 1
                cell.segmentedControl.removeTarget(nil, action: nil, for: .valueChanged)
                cell.segmentedControl.addTarget(self, action: #selector(popupBarStyleChanged(_:)), for: .valueChanged)
                cell.selectionStyle = .none
                
            case 1:
                // ProgressViewStyle
                cell.titleLabel.text = "ProgressViewStyle"
                cell.segmentedControl.removeAllSegments()
                cell.segmentedControl.insertSegment(withTitle: "Default", at: 0, animated: false)
                for idx in 0..<PBPopupBarProgressViewStyle.strings.count {
                    cell.segmentedControl.insertSegment(withTitle: PBPopupBarProgressViewStyle.strings[idx], at: idx+1, animated: false)
                }
                self.progressViewStyle = self.containerVC.popupBar.progressViewStyle
                cell.segmentedControl.selectedSegmentIndex = self.progressViewStyle.rawValue + 1
                cell.segmentedControl.removeTarget(nil, action: nil, for: .valueChanged)
                cell.segmentedControl.addTarget(self, action: #selector(progressViewStyleChanged(_:)), for: .valueChanged)
                cell.selectionStyle = .none
                
            case 2:
                // PopupPresentationStyle
                cell.titleLabel.text = "PopupPresentationStyle"
                cell.segmentedControl.removeAllSegments()
                cell.segmentedControl.insertSegment(withTitle: "Default", at: 0, animated: false)
                for idx in 0..<PBPopupPresentationStyle.strings.count - 1 {
                    cell.segmentedControl.insertSegment(withTitle: PBPopupPresentationStyle.strings[idx], at: idx+1, animated: false)
                }
                self.popupPresentationStyle = self.containerVC.popupContentView.popupPresentationStyle
                cell.segmentedControl.selectedSegmentIndex = self.popupPresentationStyle.rawValue + 1
                cell.segmentedControl.removeTarget(nil, action: nil, for: .valueChanged)
                cell.segmentedControl.addTarget(self, action: #selector(popupPresentationStyleChanged(_:)), for: .valueChanged)
                cell.selectionStyle = .none
                
            case 3:
                // PopupCloseButtonStyle
                cell.titleLabel.text = "PopupCloseButtonStyle"
                cell.segmentedControl.removeAllSegments()
                cell.segmentedControl.insertSegment(withTitle: "Default", at: 0, animated: false)
                for idx in 0..<PBPopupCloseButtonStyle.strings.count {
                    cell.segmentedControl.insertSegment(withTitle: PBPopupCloseButtonStyle.strings[idx], at: idx+1, animated: false)
                }
                self.popupCloseButtonStyle = self.containerVC.popupContentView.popupCloseButtonStyle
                cell.segmentedControl.selectedSegmentIndex = self.popupCloseButtonStyle.rawValue + 1
                cell.segmentedControl.removeTarget(nil, action: nil, for: .valueChanged)
                cell.segmentedControl.addTarget(self, action: #selector(popupCloseButtonStyleChanged(_:)), for: .valueChanged)
                cell.selectionStyle = .none
                
            case 4:
                // PopupContentViewController
                cell.titleLabel.text = "popupContentViewController"
                cell.segmentedControl.removeAllSegments()
                cell.segmentedControl.insertSegment(withTitle: "View", at: 0, animated: false)
                cell.segmentedControl.insertSegment(withTitle: "Table View", at: 1, animated: false)
                cell.segmentedControl.selectedSegmentIndex = self.isPopupContentTableView ? 1 : 0
                cell.segmentedControl.removeTarget(nil, action: nil, for: .valueChanged)
                cell.segmentedControl.addTarget(self, action: #selector(popupContentViewChanged(_:)), for: .valueChanged)
                cell.selectionStyle = .none
                
            default:
                break
            }
            
            cell.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
            
            cell.titleLabel.textColor = UIColor.label

            cell.titleLabel.adjustsFontForContentSizeCategory = true
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonTableViewCell", for: indexPath) as! ButtonTableViewCell
            switch indexPath.row {
            case 0:
                // Dismiss Popup Bar
                cell.selectionStyle = .none

            case 1:
                // Push next
                cell.selectionStyle = .none
            
            case 2:
                cell.selectionStyle = .none

            default:
                break
            }
            
            cell.button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            cell.button.titleLabel?.adjustsFontForContentSizeCategory = true
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "musicTableViewCell", for: indexPath) as! MusicTableViewCell
            cell.albumArtImageView.image = images[indexPath.row]
            cell.songNameLabel.text = titles[indexPath.row]
            cell.albumNameLabel.text = subtitles[indexPath.row]
            cell.selectionStyle = .none

            var font = UIFont.systemFont(ofSize: 17, weight: .regular)
            cell.songNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
            cell.songNameLabel.adjustsFontForContentSizeCategory = true
            
            font = UIFont.systemFont(ofSize: 13, weight: .regular)
            cell.albumNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
            cell.albumNameLabel.adjustsFontForContentSizeCategory = true
            
            cell.songNameLabel.textColor = UIColor.label
            cell.albumNameLabel.textColor = UIColor.secondaryLabel

            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
}

// MARK: - Table view delegate

extension FirstTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        
        switch indexPath.section {
        case 2:
            if let cell = cell as? ButtonTableViewCell {
                switch indexPath.row {
                case 0:
                    // Dismiss Popup Bar
                    cell.button.setTitle("Dismiss Popup Bar", for: .normal)
                    cell.button.removeTarget(nil, action: nil, for: .touchUpInside)
                    cell.button.addTarget(self, action: #selector(dismissPopupBar(_:)), for: .touchUpInside)
                    
                case 1:
                    // Push next
                    cell.button.setTitle("Next", for: .normal)
                    cell.button.removeTarget(nil, action: nil, for: .touchUpInside)
                    cell.button.addTarget(self, action: #selector(pushNext(_:)), for: .touchUpInside)
                    
                case 2:
                    // Push next & hide bottom bar
                    cell.button.setTitle("Next (hidesPopupBarWhenPushed)", for: .normal)
                    cell.button.removeTarget(nil, action: nil, for: .touchUpInside)
                    cell.button.addTarget(self, action: #selector(pushNextAndHideBottomBar(_:)), for: .touchUpInside)
                    
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 3 {
            self.updatePopupBar(forRowAt: indexPath.row)
            if self.popupBarStyle == .custom {
                self.setupCustomPopupBar()
            }
            self.presentPopupBar(self)
        }
    }
    
    func updatePopupBar(forRowAt index: Int) {
        self.containerVC.popupBar.image = images[index]
        self.containerVC.popupBar.title = titles[index]
        self.containerVC.popupBar.subtitle = subtitles[index]
        self.configureAccessibility()
    }
    
    private func configureAccessibility() {
        guard let containerVC = self.containerVC,
              let popupBar = containerVC.popupBar else {return}
        
        var accessibility = String()
        accessibility = NSLocalizedString("Popup bar", comment: "") + "\n"
        if let title = popupBar.title {
            accessibility += title + "\n"
        }
        if let subtitle = popupBar.subtitle {
            accessibility += subtitle
        }
        popupBar.accessibilityLabel = accessibility
        
        popupBar.accessibilityHint = NSLocalizedString("Double tap to open popup content", comment: "")
    }
}

    // MARK: - PBPopupController delegate
  
extension FirstTableViewController: PBPopupControllerDelegate {
    func popupControllerTapGestureShouldBegin(_ popupController: PBPopupController, state: PBPopupPresentationState) -> Bool {
#if targetEnvironment(macCatalyst)
        if let tabBarController = self.tabBarController, self.navigationController == nil {
            if tabBarController.modalPresentationStyle == .fullScreen {
                return false
                //return true
            }
            return true
        }
#endif
        return true
    }
    
    func popupControllerPanGestureShouldBegin(_ popupController: PBPopupController, state: PBPopupPresentationState) -> Bool {
#if targetEnvironment(macCatalyst)
        if let tabBarController = self.tabBarController, self.navigationController == nil {
            if tabBarController.modalPresentationStyle == .fullScreen {
                return false
            }
            return true
        }
#endif
        return true
    }
    
    func popupController(_ popupController: PBPopupController, willPresent popupBar: PBPopupBar) {
        PBLog("willPresent - state: \(popupController.popupPresentationState.description)")
    }
    
    func popupController(_ popupController: PBPopupController, didPresent popupBar: PBPopupBar) {
        PBLog("didPresent - state: \(popupController.popupPresentationState.description)")
    }
    
    func popupController(_ popupController: PBPopupController, willDismiss popupBar: PBPopupBar) {
        PBLog("willDismiss - state: \(popupController.popupPresentationState.description)")
    }
    
    func popupController(_ popupController: PBPopupController, didDismiss popupBar: PBPopupBar) {
        PBLog("didDismiss - state: \(popupController.popupPresentationState.description)")
    }
    
    func popupController(_ popupController: PBPopupController, shouldOpen popupContentViewController: UIViewController) -> Bool {
        PBLog("shouldOpen - state: \(popupController.popupPresentationState.description)")
        if let popupContent = popupContentViewController as? PopupContentViewController {
            popupContent.albumArtImage = self.containerVC.popupBar.image
            popupContent.songTitle = self.containerVC.popupBar.title
            popupContent.albumTitle = self.containerVC.popupBar.subtitle
        }
        
        if let popupContent = popupContentViewController as? PopupContentTableViewController {
            popupContent.albumArtImage = self.containerVC.popupBar.image
            popupContent.songTitle = self.containerVC.popupBar.title
            popupContent.albumTitle = self.containerVC.popupBar.subtitle
        }
        return true
    }
    
    func popupController(_ popupController: PBPopupController, willOpen popupContentViewController: UIViewController) {
        PBLog("willOpen - state: \(popupController.popupPresentationState.description)")

        if let popupContentView = self.containerVC.popupContentView {
            if let bottomModule = popupContentView.popupBottomModule {
                bottomModule.alpha = 1.0
            }
        }
        popupContentViewController.view.backgroundColor = UIColor.secondarySystemBackground
        popupContentViewController.view.alpha = 1
    }

    func popupController(_ popupController: PBPopupController, didOpen popupContentViewController: UIViewController) {
        PBLog("didOpen - state: \(popupController.popupPresentationState.description)")
    }
    
    func popupController(_ popupController: PBPopupController, shouldClose popupContentViewController: UIViewController) -> Bool {
        PBLog("shouldClose - state: \(popupController.popupPresentationState.description)")
        return true
    }
    
    func popupController(_ popupController: PBPopupController, willClose popupContentViewController: UIViewController) {
        PBLog("willClose - state: \(popupController.popupPresentationState.description)")
    }
    
    func popupController(_ popupController: PBPopupController, didClose popupContentViewController: UIViewController) {
        PBLog("didClose - state: \(popupController.popupPresentationState.description)")
    }
    
    func popupController(_ popupController: PBPopupController, stateChanged state: PBPopupPresentationState, previousState: PBPopupPresentationState) {
        PBLog("stateChanged state: \(state.description) - previousState: \(previousState.description)", error: true)
        switch state {
        case .transitioning, .opening:
            self.label?.pauseLabel()
            self.sublabel?.pauseLabel()
        case .closed:
            self.label?.unpauseLabel()
            self.sublabel?.unpauseLabel()
        default:
            break
        }
    }
    
    func popupController(_ popupController: PBPopupController, interactivePresentationFor popupContentViewController: UIViewController, state: PBPopupPresentationState, progress: CGFloat, location: CGFloat) {
        if state == .closed {
            if let popupContentView = self.containerVC.popupContentView {
                if let bottomModule = popupContentView.popupBottomModule {
                    bottomModule.alpha = progress
                }
            }
            
            if let popupContentView = self.containerVC.popupContentView, let popupEffectView = popupContentView.popupEffectView, popupEffectView.effect == nil {
                return
            }

            let alpha = (0.30 - progress) / 0.30
            popupContentViewController.view.backgroundColor = UIColor.secondarySystemBackground
            popupContentViewController.view.alpha = 1 - alpha
        }
        //
    }
}

// MARK: - PBPopupBar dataSource

extension FirstTableViewController: PBPopupBarDataSource {
    func titleLabel(for popupBar: PBPopupBar) -> UILabel? {
        return self.label
    }
    
    func subtitleLabel(for popupBar: PBPopupBar) -> UILabel? {
        return self.sublabel
    }
}

// MARK: - Tab bar controller delegate

extension FirstTableViewController: UITabBarControllerDelegate {
        
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is NavigationController {
            let nc = viewController as! UINavigationController
            if nc.topViewController is DemoCollectionViewController {
                let vc = nc.topViewController as! DemoCollectionViewController
                vc.firstVC = self
            }
            if nc.topViewController is DemoTableViewController {
                let vc = nc.topViewController as! DemoTableViewController
                vc.firstVC = self
            }
        }
        if viewController is DemoCollectionViewController {
            let vc = viewController as! DemoCollectionViewController
            vc.firstVC = self
        }
        if viewController is DemoTableViewController {
            let vc = viewController as! DemoTableViewController
            vc.firstVC = self
        }
        return true
    }
    
    /*
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        tabBarController.setNeedsStatusBarAppearanceUpdate()
    }
    */
}

// MARK: - PBPopupBarPreviewingDelegate

extension FirstTableViewController: PBPopupBarPreviewingDelegate, UIPopoverPresentationControllerDelegate {
    
    func previewingViewControllerFor(_ popupBar: PBPopupBar) -> UIViewController? {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PeekViewController") {
            return vc
        }
        else {
            let blur = UIBlurEffect(style: .extraLight)
            let vc = UIViewController()
            vc.view = UIVisualEffectView(effect: blur)
            vc.view.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
            vc.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
            
            let label = UILabel()
            label.text = "Hello from\n3D Touch!"
            label.numberOfLines = 0
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 50, weight: .black)
            label.sizeToFit()
            label.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleTopMargin]
            
            let vib = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blur))
            vib.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            vib.contentView.addSubview(label)
            
            (vc.view as! UIVisualEffectView).contentView.addSubview(vib)
            
            return vc
        }
    }
    
    func popupBar(_ popupBar: PBPopupBar, commit viewControllerToCommit: UIViewController) {
        self.definesPresentationContext = true
        viewControllerToCommit.modalPresentationStyle = .popover
        viewControllerToCommit.popoverPresentationController?.delegate = self
        viewControllerToCommit.popoverPresentationController?.sourceView = self.view
        viewControllerToCommit.popoverPresentationController?.sourceRect = self.view.bounds
        viewControllerToCommit.popoverPresentationController?.permittedArrowDirections = []
        self.blurView()
        present(viewControllerToCommit, animated: true) {
            //
        }
    }
    
    func blurView() {
        let blur = UIBlurEffect(style: .light)
        self.effectView = UIVisualEffectView(effect: blur)
        self.effectView.frame = self.view.bounds
        self.effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let vib = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blur))
        vib.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.effectView.contentView.addSubview(vib)
        self.tabBarController?.view.addSubview(self.effectView)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if let effectView = self.effectView {
            effectView.removeFromSuperview()
            self.effectView = nil
        }
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        if let effectView = self.effectView {
            UIView.animate(withDuration: 1.5, animations: {
                effectView.effect = nil
            }) { (_ ) in
            }
        }
        return true
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension FirstTableViewController: UIContextMenuInteractionDelegate
{
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        // Disable interaction if a preview view controller is about to be presented.
        self.containerVC.popupController.popupBarTapGestureRecognizer.isEnabled = false
        self.containerVC.popupController.popupBarPanGestureRecognizer.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.containerVC.popupController.popupBarTapGestureRecognizer.isEnabled = true
            self.containerVC.popupController.popupBarPanGestureRecognizer.isEnabled = true
        })
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: nil)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        animator?.addCompletion {
            let avc = UIActivityViewController(activityItems: [URL(string: "https://github.com/iDevelopper/PBPopupController")!], applicationActivities: nil)
            avc.modalPresentationStyle = .formSheet
            avc.popoverPresentationController?.sourceView = self.containerVC.popupBar
            self.present(avc, animated: true, completion: nil)
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        print("willDisplayMenuFor")
    }
}

// MARK: - PBPopupController dataSource

#if targetEnvironment(macCatalyst)
extension FirstTableViewController {
    func popupController(_ popupController: PBPopupController, insetsFor bottomBarView: UIView) -> UIEdgeInsets {
            return self.insetsForBottomBar()
    }
    
    func insetsForBottomBar() -> UIEdgeInsets {
        if self.navigationController != nil {
            return .zero
        }
        var insets: UIEdgeInsets = .zero
        if let vc = self.tabBarController?.selectedViewController {
            insets = vc.view.window?.safeAreaInsets ?? .zero
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: self.containerVC.view.frame.height - insets.top - self.containerVC.bottomBar.frame.height - self.containerVC.popupBar.frame.height, right: 0)
    }
}
#endif

// MARK: - NSToolbar & NSToolbarDelegate

extension FirstTableViewController {
    func setupToolbarIfNeeded() {
#if targetEnvironment(macCatalyst)
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        guard let windowScene = window?.windowScene else {
            return
        }
        if let titlebar = windowScene.titlebar {
            if titlebar.toolbar == nil {
                let toolbar = NSToolbar(identifier: "testToolbar")
                
                if let tbc = tabBarController {
                    tbc.tabBar.isHidden = self.navigationController == nil ? true : false
                    toolbar.isVisible = self.navigationController == nil ? true : false
                }
                toolbar.delegate = self
                toolbar.allowsUserCustomization = true
                toolbar.centeredItemIdentifier = NSToolbarItem.Identifier(rawValue: "testGroup")
                titlebar.titleVisibility = .hidden
                
                titlebar.toolbar = toolbar
            }
        }
#endif
    }
}

#if targetEnvironment(macCatalyst)
extension FirstTableViewController: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "testGroup")) {
            /*
            var titles = [String]()
            if let tbc = self.tabBarController, let items = tbc.tabBar.items {
                for item in items {
                    titles.append(item.title ?? "")
                }
            }
            */
            let titles = ["First 1", "First 2", "First 3", "Collection", "Table"]
            //let group = NSToolbarItemGroup(itemIdentifier: NSToolbarItem.Identifier(rawValue: "testGroup"), titles: ["Favorites", "Favorites", "Favorites", "Most viewed", "Most viewed"], selectionMode: .selectOne, labels: ["First", "Second", "Third", "Fourth", "Fifth"], target: self, action: #selector(toolbarGroupSelectionChanged))
            let group = NSToolbarItemGroup(itemIdentifier: NSToolbarItem.Identifier(rawValue: "testGroup"), titles: titles, selectionMode: .selectOne, labels: nil, target: self, action: #selector(toolbarGroupSelectionChanged))
            
            group.setSelected(true, at: 0)
            
            return group
        }
        
        return nil
    }
    
    @objc func toolbarGroupSelectionChanged(sender: NSToolbarItemGroup) {
        print("testGroup selection changed to index: \(sender.selectedIndex)")
        
        if let tbc = self.tabBarController, let vcs = tbc.viewControllers {
            let vc = vcs[sender.selectedIndex]
            if self.tabBarController(tbc, shouldSelect: vc) {
                tbc.selectedIndex = sender.selectedIndex
            }
        }
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        print("Identifier: \([NSToolbarItem.Identifier(rawValue: "testGroup")])")
        return [NSToolbarItem.Identifier(rawValue: "testGroup")]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }
}
#endif
