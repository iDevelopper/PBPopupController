//
//  FirstTableViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 22/10/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class FirstTableViewController: UITableViewController, PBPopupControllerDelegate, PBPopupControllerDataSource, PBPopupBarDataSource {

    // MARK: - Properties
    
    @IBOutlet weak var headerView: UIView!
    
    var popupContentVC: UIViewController!
    
    weak var containerVC: UIViewController!

    var popupPlayButtonItemForProminent: UIBarButtonItem!
    var popupNextButtonItemForProminent: UIBarButtonItem!
    var popupPrevButtonItemForCompact: UIBarButtonItem!
    var popupPlayButtonItemForCompact: UIBarButtonItem!
    var popupNextButtonItemForCompact: UIBarButtonItem!
    var popupMoreButtonItemForCompact: UIBarButtonItem!

    var popupBarStyle: PBPopupBarStyle!
    var progressViewStyle: PBPopupBarProgressViewStyle!
    var popupPresentationStyle: PBPopupPresentationStyle!
    var popupCloseButtonStyle: PBPopupCloseButtonStyle!
    var popupContentIsTableView: Bool = false
    
    var isPlaying: Bool = false
    
    var indexOfCurrentSong: Int = 0
    
    var images = [UIImage]()
    var titles = [String]()
    var subtitles = [String]()
    
    var effectView: UIVisualEffectView!
    
    lazy var label: MarqueeLabel = {
        let marqueeLabel = MarqueeLabel(frame: .zero, rate: 15, fadeLength: 10)
        marqueeLabel.leadingBuffer = 0.0
        marqueeLabel.trailingBuffer = 5.0
        marqueeLabel.animationDelay = 1.0
        marqueeLabel.type = .continuous
        return marqueeLabel
    }()
    
    lazy var sublabel: MarqueeLabel = {
        let marqueeLabel = MarqueeLabel(frame: .zero, rate: 20, fadeLength: 10)
        marqueeLabel.leadingBuffer = 0.0
        marqueeLabel.trailingBuffer = 5.0
        marqueeLabel.animationDelay = 1.0
        marqueeLabel.type = .continuous
        return marqueeLabel
    }()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.tabBarController?.delegate = self
        
        for idx in 1...self.tableView(tableView, numberOfRowsInSection: 2) {
            
            let imageName = String(format: "Cover%02d", idx)
            images += [UIImage(named: imageName)!]
            titles += [LoremIpsum.title]
            subtitles += [LoremIpsum.sentence]
        }
        
        self.tableView.backgroundColor = UIColor.PBRandomExtraLightColor()

        self.tableView.tableFooterView = UIView()
        
        self.tableView.tableHeaderView = nil
        if (self.navigationController == nil) {
            self.tableView.tableHeaderView = self.headerView
        }

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80.0

        self.setupContainerVC()

        self.commonSetup()
        
        self.createBarButtonItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion <= 10 {
            let insets = UIEdgeInsets.init(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            //self.tableView.reloadData()
        }, completion: nil)
    }

    /*
    override var prefersStatusBarHidden: Bool {
        return true
    }
    */
    
    // MARK: - Setups
    
    deinit {
        PBLog("deinit \(self)")
    }

    func setupContainerVC() {
        if let splitViewController = self.splitViewController as? SplitViewController {
            if splitViewController.globalIsContainer == true {
                self.containerVC = splitViewController
            }
            else {
                if splitViewController.masterIsContainer == true {
                    self.containerVC = splitViewController.viewControllers.first
                }
                else {
                    self.containerVC = splitViewController.viewControllers.last
                }
                self.containerVC.popupContentView.popupPresentationStyle = .fullScreen
            }
        }
        
        else if let tabBarController = self.tabBarController {
            self.containerVC = tabBarController
            if let navigationController = self.navigationController {
                navigationController.isToolbarHidden = true
                if navigationController.isToolbarHidden == false {
                    self.containerVC = navigationController
                }
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
        }
        else {
            self.containerVC = self
        }
    }
    
    func commonSetup() {
        self.popupBarStyle = self.containerVC.popupBar.popupBarStyle
        
        self.progressViewStyle = self.containerVC.popupBar.progressViewStyle
        
        self.popupPresentationStyle = self.containerVC.popupContentView.popupPresentationStyle
        
        self.popupCloseButtonStyle = self.containerVC.popupContentView.popupCloseButtonStyle
        
        self.containerVC.popupController.delegate = self
        self.containerVC.popupController.dataSource = self
        
        self.containerVC.popupContentView.popupContentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height * 0.80)

        self.tableView.reloadData()
    }
    
    func setupCustomPopupBar() {
        if let popupBar = self.containerVC.popupBar {
            if self.popupBarStyle == .custom {
                let customPopupBarVC = storyboard!.instantiateViewController(withIdentifier: "CustomPopupBarViewController") as! CustomPopupBarViewController
                customPopupBarVC.view.backgroundColor = UIColor.clear
                
                popupBar.customPopupBarViewController = customPopupBarVC
            }
        }
    }
    
    func setupPopupBar(_ sender: Any) {
        if let popupBar = self.containerVC.popupBar {
            popupBar.PBPopupBarShowColors = false
            popupBar.dataSource = self
            popupBar.previewingDelegate = self
            
            popupBar.inheritsVisualStyleFromBottomBar = false
            
            popupBar.shadowImageView.shadowOpacity = 0
            
            if sender is MusicTableViewCell {
                let cell = sender as! MusicTableViewCell
                popupBar.image = cell.albumArtImageView.image
                popupBar.title = cell.songNameLabel.text
                popupBar.subtitle = cell.albumNameLabel.text
            }
            else if popupBar.image == nil {
                popupBar.image = images[0]
                popupBar.title = titles[0]
                popupBar.subtitle = subtitles[0]
            }
            
            popupBar.image?.accessibilityLabel = NSLocalizedString("Cover", comment: "")

            popupBar.tintColor = self.popupBarStyle == .compact ? UIColor.red : UIColor.black
            
            self.configureBarButtonItems()
            
            //popupBar.semanticContentAttribute = .forceRightToLeft
            //popupBar.barButtonItemsSemanticContentAttribute = .forceRightToLeft
            
            /*
            let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byTruncatingTail
            containerVC.popupBar.titleTextAttributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.backgroundColor: UIColor.clear, NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)]
            */
        }
    }
    
    func createBarButtonItems() {
        //let fixedButton = UIButton(type: .system)
        //fixedButton.setImage(#imageLiteral(resourceName: "pause-small"), for: .normal)
        //self.popupPlayButtonItem = UIBarButtonItem(customView: fixedButton)
        //fixedButton.addTarget(self, action: #selector(playPauseAction(_:)), for: .touchUpInside)
        
        self.popupPlayButtonItemForProminent = UIBarButtonItem(image: #imageLiteral(resourceName: "play-small"), style: .plain, target: self, action: #selector(playPauseAction(_:)))
        self.popupPlayButtonItemForProminent.accessibilityLabel = NSLocalizedString("Play", comment: "")
        
        self.popupNextButtonItemForProminent = UIBarButtonItem(image: #imageLiteral(resourceName: "next-small"), style: .plain, target: self, action: #selector(nextAction(_:)))
        self.popupNextButtonItemForProminent.accessibilityLabel = NSLocalizedString("Next track", comment: "")

        self.popupMoreButtonItemForCompact = UIBarButtonItem(image: #imageLiteral(resourceName: "more"), style: .plain, target: self, action: #selector(moreAction(_:)))
        self.popupMoreButtonItemForCompact.accessibilityLabel = NSLocalizedString("More", comment: "")

        self.popupPlayButtonItemForCompact = UIBarButtonItem(image: #imageLiteral(resourceName: "play-small"), style: .plain, target: self, action: #selector(playPauseAction(_:)))
        self.popupPlayButtonItemForCompact.accessibilityLabel = NSLocalizedString("Play", comment: "")

        self.popupNextButtonItemForCompact = UIBarButtonItem(image: #imageLiteral(resourceName: "next-small"), style: .plain, target: self, action: #selector(nextAction(_:)))
        self.popupNextButtonItemForCompact.accessibilityLabel = NSLocalizedString("Next track", comment: "")

        self.popupPrevButtonItemForCompact = UIBarButtonItem(image: #imageLiteral(resourceName: "prev-small"), style: .plain, target: self, action: #selector(prevAction(_:)))
        self.popupPrevButtonItemForCompact.accessibilityLabel = NSLocalizedString("Previous track", comment: "")
    }
    
    func configureBarButtonItems() {
        if let popupBar = self.containerVC.popupBar {
            if UIDevice.current.userInterfaceIdiom == .phone {
                if popupBar.popupBarStyle == .prominent {
                    popupBar.leftBarButtonItems = nil
                    popupBar.rightBarButtonItems = [self.popupPlayButtonItemForProminent, self.popupNextButtonItemForProminent]
                }
                else {
                    popupBar.leftBarButtonItems = [self.popupPlayButtonItemForCompact]
                    popupBar.rightBarButtonItems = [self.popupMoreButtonItemForCompact]
                }
            }
            else {
                if popupBar.popupBarStyle == .prominent {
                    popupBar.leftBarButtonItems = nil
                    popupBar.rightBarButtonItems = [self.popupPlayButtonItemForProminent, self.popupNextButtonItemForProminent]
                }
                else {
                    popupBar.leftBarButtonItems = [self.popupPrevButtonItemForCompact, self.popupPlayButtonItemForCompact, self.popupNextButtonItemForCompact]
                    popupBar.rightBarButtonItems = [self.popupMoreButtonItemForCompact]
                }
            }
        }
    }
    
    // MARK: - Toolbar container actions
    
    @IBAction func defaultToolbarStyle(_ sender: UIBarButtonItem) {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.toolbar.barStyle = .default
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.toolbar.barTintColor = nil
        navigationController?.navigationBar.tintColor = self.view.tintColor
        navigationController?.toolbar.tintColor = self.view.tintColor
        (navigationController?.toolbar.items as NSArray?)?.enumerateObjects({ obj, idx, stop in
            (obj as! UIBarButtonItem).tintColor = self.view.tintColor
        })

        navigationController?.updatePopupBarAppearance()
    }

    @IBAction func hideToolbar(_ sender: UIBarButtonItem) {
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    @IBAction func changeToolbarStyle(_ sender: Any) {
        if let aStyle = UIBarStyle(rawValue: 1 - (navigationController?.toolbar.barStyle.rawValue ?? 0)) {
            navigationController?.toolbar.barStyle = aStyle
        }
        if let aColor = navigationController?.toolbar.barStyle != nil ? UIColor.PBRandomLightColor() : view.tintColor {
            navigationController?.toolbar.tintColor = aColor
        }
        
        if let aColor = navigationController?.toolbar.barStyle != nil ? UIColor.PBRandomExtraLightColor() : view.backgroundColor {
            navigationController?.toolbar.barTintColor = aColor
        }
        
        (navigationController?.toolbar.items as NSArray?)?.enumerateObjects({ obj, idx, stop in
            (obj as! UIBarButtonItem).tintColor = self.navigationController?.toolbar.tintColor
        })
        if let aStyle = navigationController?.toolbar.barStyle {
            navigationController?.navigationBar.barStyle = aStyle
        }
        if let aColor = navigationController?.toolbar.tintColor {
            navigationController?.navigationBar.tintColor = aColor
        }
        if let aColor = navigationController?.toolbar.barTintColor {
            navigationController?.navigationBar.barTintColor = aColor
        }
        
        navigationController?.updatePopupBarAppearance()
    }
    
    // MARK: - Setup Styles Actions

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
            // Test a new instance of custom popupBar controller
            self.setupCustomPopupBar()
            return
        }
        if let popupBar = self.containerVC.popupBar {
            popupBar.popupBarStyle = self.popupBarStyle
            popupBar.tintColor = self.popupBarStyle == .compact ? UIColor.red : UIColor.black
            self.configureBarButtonItems()
        }
        
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
            self.progressViewStyle = .none
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
            self.popupCloseButtonStyle = .none
        default:
            break
        }
        if self.popupCloseButtonStyle == nil {
            self.containerVC.popupContentView.popupCloseButtonStyle = .none
        }
        else {
            if !self.popupContentIsTableView {
                self.containerVC.popupContentView.popupCloseButtonStyle = self.popupCloseButtonStyle
            }
            else {
                // none for table view
                sender.selectedSegmentIndex = 3
            }
        }
        self.commonSetup()
    }
    
    @IBAction func popupContentViewChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.popupContentIsTableView = false
            self.popupCloseButtonStyle = .default
            self.containerVC.popupContentView.popupCloseButtonStyle = .default
        case 1:
            self.popupContentIsTableView = true
            self.popupCloseButtonStyle = .none
            self.containerVC.popupContentView.popupCloseButtonStyle = .none
        default:
            break
        }
        
        self.commonSetup()
        if self.containerVC.popupController.popupPresentationState == .closed {
            // Present the popup bar with another popup
            self.presentPopBar(sender)
        }
    }
    
    // MARK: - Popup Bar Actions
    
    @IBAction func presentPopBar(_ sender: Any) {
        self.commonSetup()
        self.setupPopupBar(sender)
        self.setupCustomPopupBar()
        
        if !self.popupContentIsTableView {
            self.popupContentVC = self.storyboard?.instantiateViewController(withIdentifier: "PopupContentViewController") as? PopupContentViewController
            (self.popupContentVC as! PopupContentViewController).firstVC = self
        }
        else {
            // Table view
            self.popupContentVC = self.storyboard?.instantiateViewController(withIdentifier: "PopupContentTableViewController") as? PopupContentTableViewController
            (self.popupContentVC as! PopupContentTableViewController).firstVC = self
        }

        self.containerVC.popupContentView.popupEffectView.effect = nil
        //self.containerVC.popupContentView.popupPresentationDuration = 6
        
        DispatchQueue.main.async {
            self.containerVC.presentPopupBar(withPopupContentViewController: self.popupContentVC, animated: true, completion: {
                PBLog("Popup Bar Presented")
            })
            
            /*
            self.containerVC.presentPopupBar(withPopupContentViewController: self.popupContentVC, openPopup: true, animated: true)
            */
        }
    }
    
    @IBAction func dismissPopBar(_ sender: Any) {
        self.containerVC.dismissPopupBar(animated: true, completion: {
            PBLog("Popup Bar Dismissed")
        })
    }
    
    // MARK: - Menu Actions
    
    @IBAction func presentPopupContentViewController(_ sender: UIButton) {
        var popupController: UIViewController
        // Reinstantiate to be sure of the initial state
        if !self.popupContentIsTableView {
            popupController = self.storyboard?.instantiateViewController(withIdentifier: "PopupContentViewController") as! PopupContentViewController
        }
        else {
            popupController = self.storyboard?.instantiateViewController(withIdentifier: "PopupContentTableViewController") as! PopupContentTableViewController
        }
        
        /*
        popupController.modalPresentationStyle = .popover
        popupController.popoverPresentationController?.delegate = self
        popupController.popoverPresentationController?.sourceView = self.view
        popupController.popoverPresentationController?.permittedArrowDirections = []
        
        self.containerVC.present(popupController, animated: true) {
            //
        }
        */
        
        popupController.modalPresentationStyle = .fullScreen
        self.containerVC.present(popupController, animated: true) {
            //
        }
    }
    
   @IBAction func pushNext(_ sender: Any) {
        if let firstVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstTableViewController") as? FirstTableViewController {
            firstVC.hidesBottomBarWhenPushed = true
            if let navigationController = self.navigationController as? NavigationController {
                navigationController.toolbarIsShown = false
            }
            firstVC.title = self.title
            self.show(firstVC, sender: sender)
        }
    }
    
    // MARK: - Controls Actions
    
    @IBAction func playPauseAction(_ sender: Any) {
        PBLog("PopupBar playPauseAction")
        
        self.isPlaying = !self.isPlaying
        self.popupPlayButtonItemForProminent.image = self.isPlaying ? #imageLiteral(resourceName: "pause-small") : #imageLiteral(resourceName: "play-small")
        self.popupPlayButtonItemForProminent.accessibilityLabel = NSLocalizedString(self.isPlaying ? "Pause" : "Play", comment: "")
        self.popupPlayButtonItemForCompact.image = self.isPlaying ? #imageLiteral(resourceName: "pause-small") : #imageLiteral(resourceName: "play-small")
        self.popupPlayButtonItemForCompact.accessibilityLabel = NSLocalizedString(self.isPlaying ? "Pause" : "Play", comment: "")
        (self.popupContentVC as! PopupContentViewController).playPauseAction(sender)
    }
    
    @IBAction func prevAction(_ sender: Any) {
        PBLog("prevAction")

        if self.indexOfCurrentSong > 0 {
            self.indexOfCurrentSong -= 1
        }
        else {
            self.indexOfCurrentSong = self.images.count - 1
        }
        self.containerVC.popupBar.image = images[self.indexOfCurrentSong]
        self.containerVC.popupBar.title = titles[self.indexOfCurrentSong]
        self.containerVC.popupBar.subtitle = subtitles[self.indexOfCurrentSong]
    }
    
    @IBAction func nextAction(_ sender: Any) {
        PBLog("nextAction")

        if self.indexOfCurrentSong < images.count - 1 {
            self.indexOfCurrentSong += 1
        }
        else {
            self.indexOfCurrentSong = 0
        }
        self.containerVC.popupBar.image = images[self.indexOfCurrentSong]
        self.containerVC.popupBar.title = titles[self.indexOfCurrentSong]
        self.containerVC.popupBar.subtitle = subtitles[self.indexOfCurrentSong]
    }
    
    @IBAction func moreAction(_ sender: Any) {
        PBLog("")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.containerVC != nil {
            return 3
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 4
        case 2:
            return 22
        default:
            break
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        switch indexPath.section {
        case 0:
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
                self.popupBarStyle = self.containerVC.popupBar?.popupBarStyle
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
                for idx in 0..<PBPopupPresentationStyle.strings.count {
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
                //cell.segmentedControl.insertSegment(withTitle: "Third", at: 2, animated: false)
                cell.segmentedControl.selectedSegmentIndex = self.popupContentIsTableView ? 1 : 0
                cell.segmentedControl.removeTarget(nil, action: nil, for: .valueChanged)
                cell.segmentedControl.addTarget(self, action: #selector(popupContentViewChanged(_:)), for: .valueChanged)
                cell.selectionStyle = .none
                
            default:
                break
            }
            
            cell.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
            
            if #available(iOS 10.0, *) {
                cell.titleLabel.adjustsFontForContentSizeCategory = true
            }
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonTableViewCell", for: indexPath) as! ButtonTableViewCell
            switch indexPath.row {
            case 0:
                // Present Popup Bar
                cell.button.setTitle("Present Popup Bar", for: .normal)
                cell.button.removeTarget(nil, action: nil, for: .touchUpInside)
                cell.button.addTarget(self, action: #selector(presentPopBar(_:)), for: .touchUpInside)
                cell.selectionStyle = .none
                
            case 1:
                // Dismiss Popup Bar
                cell.button.setTitle("Dismiss Popup Bar", for: .normal)
                cell.button.removeTarget(nil, action: nil, for: .touchUpInside)
                cell.button.addTarget(self, action: #selector(dismissPopBar(_:)), for: .touchUpInside)
                cell.selectionStyle = .none
                
            case 2:
                // Present PopupContentViewController
                cell.button.setTitle("Present PopupContentViewController", for: .normal)
                cell.button.removeTarget(nil, action: nil, for: .touchUpInside)
                cell.button.addTarget(self, action: #selector(presentPopupContentViewController(_:)), for: .touchUpInside)
                cell.selectionStyle = .none
                
            case 3:
                // Push next
                cell.button.setTitle("Next", for: .normal)
                cell.button.removeTarget(nil, action: nil, for: .touchUpInside)
                cell.button.addTarget(self, action: #selector(pushNext(_:)), for: .touchUpInside)
                cell.selectionStyle = .none
                
            default:
                break
            }
            
            cell.button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            if #available(iOS 10.0, *) {
                cell.button.titleLabel?.adjustsFontForContentSizeCategory = true
            }
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "musicTableViewCell", for: indexPath) as! MusicTableViewCell
            cell.albumArtImageView.image = images[indexPath.row]
            cell.songNameLabel.text = titles[indexPath.row]
            cell.albumNameLabel.text = subtitles[indexPath.row]
            cell.selectionStyle = .default

            if #available(iOS 11.0, *) {
                var font = UIFont.systemFont(ofSize: 17, weight: .regular)
                cell.songNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
                cell.songNameLabel.adjustsFontForContentSizeCategory = true
                
                font = UIFont.systemFont(ofSize: 13, weight: .regular)
                cell.albumNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
                cell.albumNameLabel.adjustsFontForContentSizeCategory = true
            }
            else {
                cell.songNameLabel.font = UIFont.preferredFont(forTextStyle: .body)
                cell.albumNameLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
                if #available(iOS 10.0, *) {
                    cell.songNameLabel.adjustsFontForContentSizeCategory = true
                    cell.albumNameLabel.adjustsFontForContentSizeCategory = true
                }
            }
            cell.albumNameLabel.textColor = UIColor.gray

            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            let cell = tableView.cellForRow(at: indexPath) as! MusicTableViewCell

            self.containerVC.popupBar.image = images[indexPath.row]
            self.containerVC.popupBar.title = titles[indexPath.row]
            self.containerVC.popupBar.subtitle = subtitles[indexPath.row]
            
            self.indexOfCurrentSong = indexPath.row
            
            if self.containerVC.popupController.popupPresentationState == .hidden {
                self.presentPopBar(cell)
            }
        }
    }
    
    // MARK: - Navigation

    @IBAction func dismiss(_ sender: Any) {
        self.popupContentVC = nil
        
        self.containerVC?.dismissPopupBar(animated: false)
        
        self.performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    // MARK: - PBPopupController delegate
    
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
    
    func popupController(_ popupController: PBPopupController, willOpen popupContentViewController: UIViewController) {
        PBLog("willOpen - state: \(popupController.popupPresentationState.description)")
        
        if let popupContentView = self.containerVC.popupContentView {
            if let controlsModule = popupContentView.popupControlsModule {
                controlsModule.alpha = 1.0
            }
        }
        popupContentViewController.view.backgroundColor = UIColor.white
        if popupContentViewController is PopupContentTableViewController {
            (popupContentViewController as! PopupContentTableViewController).popupContentVC.view.backgroundColor = UIColor.white
        }
    }
    
    func popupController(_ popupController: PBPopupController, didOpen popupContentViewController: UIViewController) {
        PBLog("didOpen - state: \(popupController.popupPresentationState.description)")
    }
    
    func popupController(_ popupController: PBPopupController, willClose popupContentViewController: UIViewController) {
        PBLog("willClose - state: \(popupController.popupPresentationState.description)")
    }
    
    func popupController(_ popupController: PBPopupController, didClose popupContentViewController: UIViewController) {
        PBLog("didClose - state: \(popupController.popupPresentationState.description)")
    }
    
    func popupController(_ popupController: PBPopupController, stateChanged state: PBPopupPresentationState, previousState: PBPopupPresentationState) {
        PBLog("stateChanged state: \(state.description) - previousState: \(previousState.description)")
    }
    
    func popupController(_ popupController: PBPopupController, interactivePresentationFor popupContentViewController: UIViewController, state: PBPopupPresentationState, progress: CGFloat, location: CGFloat) {
        let state = popupController.popupPresentationState
        if state == .closed {
            
            if let popupContentView = self.containerVC.popupContentView {
                if let controlsModule = popupContentView.popupControlsModule {
                    controlsModule.alpha = progress
                }
            }
            
            if self.containerVC.popupContentView.popupEffectView.effect == nil {
                return
            }

            let alpha = (0.30 - progress) / 0.30
            popupContentViewController.view.backgroundColor = UIColor(white: 1, alpha: 1 - alpha)
            if popupContentViewController is PopupContentTableViewController {
                (popupContentViewController as! PopupContentTableViewController).popupContentVC.view.backgroundColor = UIColor(white: 1, alpha: 1 - alpha)
            }
        }
    }

    // MARK: - PBPopupBar dataSource
    
    func titleLabel(for popupBar: PBPopupBar) -> UILabel? {
        return self.label
    }
    
    func subtitleLabel(for popupBar: PBPopupBar) -> UILabel? {
        return self.sublabel
    }
}

extension FirstTableViewController: UITabBarControllerDelegate {
    
    // MARK: - Tab bar controller delegate
    
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
}

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
        //
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
        //self.view.backgroundColor = UIColor.clear
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
        self.effectView.removeFromSuperview()
        self.effectView = nil
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        UIView.animate(withDuration: 5, animations: {
            self.effectView.effect = nil
        }) { (_ ) in
        }
        return true
    }
/*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            if (touch.view == self.view) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
 */
}
