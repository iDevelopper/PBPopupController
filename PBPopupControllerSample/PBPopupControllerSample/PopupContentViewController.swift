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
    
    weak var firstVC: FirstTableViewController!

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

    var albumArtImage: UIImage!/* = UIImage()*/ {
        didSet {
            if isViewLoaded {
                self.albumArtImageView.image = albumArtImage
                if let containerVC = self.popupContainerViewController, !self.firstVC.isPopupContentTableView {
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

    var songTitle: String!/* = ""*/ {
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
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                songNameLabel.textColor = UIColor.label
            }
            #endif
        }
    }

    var albumTitle: String!/* = ""*/ {
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
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                albumNameLabel.textColor = UIColor.systemPink
            }
            #endif
        }
    }
    
    @IBOutlet weak var prevButton: UIButton! {
        didSet {
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                prevButton.tintColor = UIColor.label
            }
            #endif
        }
    }
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                playPauseButton.tintColor = UIColor.label
            }
            #endif
        }
    }
    
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                nextButton.tintColor = UIColor.label
            }
            #endif
        }
    }
    
    @IBOutlet weak var volumeSlider: UISlider! {
        didSet {
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                volumeSlider.tintColor = UIColor.label
            }
            #endif
        }
    }
    
    let accessibilityDateComponentsFormatter = DateComponentsFormatter()
    
    var timer: Timer?
    
    // MARK: - Status bar
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
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
            containerVC.popupContentView.popupImageView = albumArtImageView
        }

        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
        }
        #endif
        
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
        
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
        }
        #endif
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
        
        var blurEffect: UIBlurEffect!
        
        if #available(iOS 13.0, *) {
            #if compiler(>=5.1)
            blurEffect = UIBlurEffect(style: .systemMaterial)
            #else
            blurEffect = UIBlurEffect(style: .extraLight)
            #endif
        }
        else {
            blurEffect = UIBlurEffect(style: .extraLight)
        }

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
    }
    
    // MARK: - Setups
    
    func setupImageViewForPlaying() {
        if self.isPlaying == true
        {
            self.imageModuleTopConstraint.constant -= 20;
            self.imageModuleLeadingConstraint.constant -= 20
            self.imageModuleTrailingConstraint.constant -= 20
            
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
            self.imageModuleTopConstraint.constant += 20;
            self.imageModuleLeadingConstraint.constant += 20
            self.imageModuleTrailingConstraint.constant += 20

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
        if let firstVC = self.firstVC {
            firstVC.isPlaying = self.isPlaying
        }
        self.playPauseButton.setImage(self.isPlaying ? UIImage(named: "nowPlaying_pause") : UIImage(named: "nowPlaying_play"), for: .normal)
        
        guard let containerVC = self.popupContainerViewController else {return}
        guard let popupBar = containerVC.popupBar else {return}
        if popupBar.popupBarStyle == .prominent {
            popupBar.rightBarButtonItems?.first?.image = self.isPlaying ? UIImage(named: "pause-small") : UIImage(named: "play-small")
        }
        let dev = UIDevice.current.userInterfaceIdiom
        popupBar.leftBarButtonItems?[dev == .phone ? 0 : 1].image = self.isPlaying ? UIImage(named: "pause-small") : UIImage(named: "play-small")
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

        guard let firstVC = self.firstVC else {return}
        
        firstVC.prevAction(self)
        
        guard let popupBar = self.popupContainerViewController.popupBar else {return}

        self.albumArtImage = popupBar.image!
        self.songTitle = popupBar.title!
        self.albumTitle = popupBar.subtitle!
    }
    
    @IBAction func nextAction(_ sender: Any) {
        PBLog("nextAction")
        
        guard let firstVC = self.firstVC else {return}
        
        firstVC.nextAction(self)
        
        guard let popupBar = self.popupContainerViewController.popupBar else {return}

        self.albumArtImage = popupBar.image!
        self.songTitle = popupBar.title!
        self.albumTitle = popupBar.subtitle!
    }
    
    @objc func tick() {
        guard let popupBar = self.popupContainerViewController.popupBar else {return}

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
