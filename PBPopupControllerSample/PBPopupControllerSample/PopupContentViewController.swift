//
//  PopupContentViewController.swift
//  PBPopBarPrivateTest
//
//  Created by Patrick BODET on 09/04/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class PopupContentViewController: UIViewController {
        
    var images: [UIImage]!
    var titles: [String]!
    var subtitles: [String]!

    var indexOfCurrentSong: Int = 0

    var isPlaying: Bool = false
    
    var backgroundView: UIImageView! {
        didSet {
            backgroundView.contentMode = .scaleAspectFill
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var imageModule: UIView! {
        didSet {
            if let containerVC = self.popupContainerViewController {
                containerVC.popupContentView.popupImageModule = imageModule
            }
            imageModule.layer.backgroundColor = UIColor.clear.cgColor
            imageModule.layer.shadowOpacity = 0.0
        }
    }
    @IBOutlet weak var imageModuleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageModuleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageModuleTrailingConstraint: NSLayoutConstraint!

    var albumArtImage: UIImage! {
        didSet {
            if isViewLoaded {
                self.albumArtImageView.image = albumArtImage
                if let containerVC = self.popupContainerViewController/*, !self.firstVC.isPopupContentTableView*/ {
                    containerVC.popupContentView.popupImageView = albumArtImageView
                }
            }
        }
    }
    
    @IBOutlet weak var albumArtImageView: UIImageView! {
        didSet {
            albumArtImageView.layer.cornerRadius = 10
            albumArtImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var albumArtImageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var albumArtImageViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var albumArtImageViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var albumArtImageViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topModule: UIView! {
        didSet {
            if let containerVC = self.popupContainerViewController {
                containerVC.popupContentView.popupTopModule = topModule
            }
        }
    }
    @IBOutlet weak var bottomModule: UIView! {
        didSet {
            if let containerVC = self.popupContainerViewController {
                containerVC.popupContentView.popupBottomModule = bottomModule
            }
        }
    }
    
    @IBOutlet weak var bottomModuleTopConstraint: NSLayoutConstraint! {
        didSet {
            if let containerVC = self.popupContainerViewController {
                containerVC.popupContentView.popupBottomModuleTopConstraint = bottomModuleTopConstraint
            }
        }
    }
    
    @IBOutlet weak var progressView: UIProgressView!

    var songTitle: String! {
        didSet {
            if isViewLoaded {
                songNameLabel.text = songTitle
            }
        }
    }
    
    @IBOutlet weak var songNameLabel: MarqueeLabel! {
        didSet {
            songNameLabel.animationDelay = 2
            songNameLabel.speed = .rate(15)
            songNameLabel.textColor = UIColor.label
            songNameLabel.font = UIFont.preferredFont(forTextStyle: .body)
            songNameLabel.adjustsFontForContentSizeCategory = true
        }
    }

    var albumTitle: String! {
        didSet {
            if isViewLoaded {
                albumNameLabel.text = albumTitle
            }
        }
    }
    
    @IBOutlet weak var albumNameLabel: MarqueeLabel! {
        didSet {
            albumNameLabel.textColor = UIColor.red
            albumNameLabel.animationDelay = 2
            albumNameLabel.speed = .rate(20)
            albumNameLabel.textColor = UIColor.systemPink
            let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            albumNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
            albumNameLabel.adjustsFontForContentSizeCategory = true
        }
    }
    
    @IBOutlet weak var prevButton: UIButton! {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .default)
            prevButton.setImage(UIImage(systemName: "backward.fill", withConfiguration: config), for: .normal)
            prevButton.tintColor = UIColor.label
        }
    }
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .regular, scale: .default)
            self.playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
            playPauseButton.tintColor = UIColor.label
        }
    }
    
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .default)
            nextButton.setImage(UIImage(systemName: "forward.fill", withConfiguration: config), for: .normal)
            nextButton.tintColor = UIColor.label
        }
    }
    
    @IBOutlet weak var timerButton: UIButton! {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .default)
            timerButton.setImage(UIImage(systemName: "timer", withConfiguration: config), for: .normal)
            timerButton.tintColor = UIColor.systemPink
        }
    }
    
    @IBOutlet weak var volumeSlider: UISlider! {
        didSet {
            volumeSlider.tintColor = UIColor.label
        }
    }
    
    let accessibilityDateComponentsFormatter = DateComponentsFormatter()
    
    var timer: Timer?
    
    // MARK: - Status bar
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        // FIXME: iOS 17 beta bug (deck animation fails)
        if #available(iOS 17.0, *) {
            return super.preferredStatusBarStyle
        }
        guard let containerVC = self.popupContainerViewController else {return.default}
        guard let popupContentView = containerVC.popupContentView else {return .default}
        
        if popupContentView.popupPresentationStyle != .deck {
            return .default
        }
        return containerVC.popupController.popupStatusBarStyle
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.albumArtImageView.image = self.albumArtImage
        self.songNameLabel.text = self.songTitle
        self.albumNameLabel.text = self.albumTitle
        if let containerVC = self.popupContainerViewController {
            containerVC.popupContentView.popupImageView = self.albumArtImageView
        }

        self.view.backgroundColor = UIColor.secondarySystemBackground
        
        self.setupImageViewForPlaying()

        self.accessibilityDateComponentsFormatter.unitsStyle = .spellOut
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PBLog("viewWillAppear")
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        PBLog("viewDidAppear")
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        PBLog("viewWillDisappear")
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        PBLog("viewDidDisappear")
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.view.backgroundColor = UIColor.secondarySystemBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Let's add a vibrancy effect to the popup close button.
        
        if self.visualEffectView != nil {
            return
        }
        guard let backgroundView = self.backgroundView else { return }
        
        backgroundView.frame = self.view.bounds
        self.view.insertSubview(backgroundView, at: 0)

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        self.visualEffectView = UIVisualEffectView(effect: blurEffect)
        self.view.insertSubview(self.visualEffectView, at: 1)
        self.visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.visualEffectView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        self.visualEffectView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        self.visualEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        self.visualEffectView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true

        guard let containerVC = self.popupContainerViewController else { return }
        
        let vibEffect = UIVibrancyEffect(blurEffect: self.visualEffectView.effect as! UIBlurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibEffect)
        vibrancyEffectView.contentView.addSubview(containerVC.popupContentView.popupCloseButton)
        self.visualEffectView.contentView.addSubview(vibrancyEffectView)
        let size = containerVC.popupContentView.popupCloseButton.sizeThatFits(.zero)
        
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyEffectView.topAnchor.constraint(equalTo: self.visualEffectView.topAnchor, constant: 20).isActive = true
        vibrancyEffectView.centerXAnchor.constraint(equalTo: self.visualEffectView.centerXAnchor, constant: 0).isActive = true
        vibrancyEffectView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        vibrancyEffectView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    deinit {
        PBLog("deinit \(self)")
        
        self.stopTimer()
    }
    
    // MARK: - Setups
    
    func setupImageViewForPlaying() {
        if self.isPlaying == true
        {
            self.albumArtImageViewTopConstraint.constant -= 10
            self.albumArtImageViewLeadingConstraint.constant -= 10
            self.albumArtImageViewTrailingConstraint.constant -= 10
            
            self.bottomModuleTopConstraint.constant -= 10
            
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }) { (_ ) in
                //
            }
            
            self.imageModule.layer.shadowColor = UIColor.black.cgColor
            self.imageModule.layer.shadowOpacity = 0.8
            self.imageModule.layer.shadowOffset = CGSize(width: 0.0, height: 20.0)
            self.imageModule.layer.shadowRadius = 20
        }
        else
        {
            self.albumArtImageViewTopConstraint.constant += 10
            self.albumArtImageViewLeadingConstraint.constant += 10
            self.albumArtImageViewTrailingConstraint.constant += 10
            
            self.bottomModuleTopConstraint.constant += 10
            
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }) { (_ ) in
                //
            }
            self.imageModule.layer.backgroundColor = UIColor.clear.cgColor
            self.imageModule.layer.shadowOpacity = 0.0
        }
    }

    func setupTimer() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    // MARK: - Actions
    
    @IBAction func playPauseAction(_ sender: Any?) {
        PBLog("playPauseAction")
        
        self.isPlaying = !self.isPlaying

        var config: UIImage.SymbolConfiguration
        config = UIImage.SymbolConfiguration(pointSize: 44, weight: .regular, scale: .default)
        self.playPauseButton.setImage(self.isPlaying ? UIImage(systemName: "pause.fill", withConfiguration: config) : UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        
        guard let containerVC = self.popupContainerViewController,
              let popupBar = containerVC.popupBar else {return}
        
        var image: UIImage!
        let scaleConfig = UIImage.SymbolConfiguration(scale: popupBar.isFloating || popupBar.popupBarStyle == .compact ? .medium : .large)
        let weightConfig = UIImage.SymbolConfiguration(weight: .semibold)
        config = scaleConfig.applying(weightConfig)

        image = self.isPlaying ? UIImage(systemName: "pause.fill") :  UIImage(systemName: "play.fill")
        image = image.applyingSymbolConfiguration(config)?.withAlignmentRectInsets(.zero).imageWithoutBaseline()
        if popupBar.popupBarStyle == .prominent {
            popupBar.rightBarButtonItems?.first?.image = image
        }
        let dev = UIDevice.current.userInterfaceIdiom
        popupBar.leftBarButtonItems?[dev == .phone ? 0 : 1].image = image
        popupBar.leftBarButtonItems?[dev == .phone ? 0 : 1].accessibilityLabel = NSLocalizedString(self.isPlaying ? "Pause" : "Play", comment: "")
        self.setupImageViewForPlaying()
        if self.isPlaying {
            self.setupTimer()
        }
        else {
            self.stopTimer()
        }
    }

    @IBAction func prevAction(_ sender: Any) {
        PBLog("prevAction")

        if self.indexOfCurrentSong > 0 {
            self.indexOfCurrentSong -= 1
        }
        else {
            self.indexOfCurrentSong = self.images.count - 1
        }
        
        guard let containerVC = self.popupContainerViewController,
              let popupBar = containerVC.popupBar else {return}

        popupBar.image = self.images[self.indexOfCurrentSong]
        popupBar.title = self.titles[self.indexOfCurrentSong]
        popupBar.subtitle = self.subtitles[self.indexOfCurrentSong]
        
        self.albumArtImage = popupBar.image!
        self.songTitle = popupBar.title!
        self.albumTitle = popupBar.subtitle!
    }
    
    @IBAction func nextAction(_ sender: Any) {
        PBLog("nextAction")
        
        if self.indexOfCurrentSong < images.count - 1 {
            self.indexOfCurrentSong += 1
        }
        else {
            self.indexOfCurrentSong = 0
        }
        
        guard let containerVC = self.popupContainerViewController,
              let popupBar = containerVC.popupBar else {return}

        popupBar.image = self.images[self.indexOfCurrentSong]
        popupBar.title = self.titles[self.indexOfCurrentSong]
        popupBar.subtitle = self.subtitles[self.indexOfCurrentSong]
        
        self.albumArtImage = popupBar.image!
        self.songTitle = popupBar.title!
        self.albumTitle = popupBar.subtitle!
    }
    
    @IBAction func timerAction(_ sender: Any?) {
        PBLog("timerAction")
        
        let safeAreaInsetsBottom = self.view.safeAreaInsets.bottom
        let viewController = DemoBottomSheetViewController()
        self.popupController.delegate = self
        self.popupContentView.wantsPopupDimmerView = false
        self.popupContentView.additionalFloatingBottomInset = safeAreaInsetsBottom == 0 ? 8.0 : 0.0
        self.presentPopup(withPopupContentViewController: viewController, animated: true)
    }

    
    @IBAction func moreAction(_ sender: Any) {
        PBLog("moreAction")
    }
    
    @objc func tick() {
        guard let containerVC = self.popupContainerViewController,
              let popupBar = containerVC.popupBar else {return}

        popupBar.progress += 0.002
        popupBar.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
        
        
        let totalTime = TimeInterval(250)
        popupBar.accessibilityProgressValue = "\(accessibilityDateComponentsFormatter.string(from: TimeInterval(popupBar.progress) * totalTime)!) \(NSLocalizedString("of", comment: "")) \(accessibilityDateComponentsFormatter.string(from: totalTime)!)"
        
        self.progressView.progress = popupBar.progress
        
        if popupBar.progress >= 1.0 {
            popupBar.progress = 0
            self.progressView.setProgress(0, animated: false)
            self.playPauseAction(nil)
        }
    }
}

extension PopupContentViewController: PBPopupControllerDelegate {
    func popupControllerPanGestureShouldBegin(_ popupController: PBPopupController, state: PBPopupPresentationState) -> Bool {
        return false
    }
}
