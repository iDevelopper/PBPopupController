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

    var closeButton: PBPopupCloseButton!
    
    var isPlaying: Bool = false
    
    @IBOutlet weak var imageModule: UIView! {
        didSet {
            if let firstVC = self.firstVC {
                if let popupContentView = firstVC.containerVC.popupContentView {
                    popupContentView.popupImageModule = imageModule
                }
            }
            
            imageModule.layer.backgroundColor = UIColor.clear.cgColor
            imageModule.layer.shadowOpacity = 0.0
        }
    }
    @IBOutlet weak var imageModuleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageModuleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageModuleTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var albumArtImageView: UIImageView! {
        didSet {
            if let firstVC = self.firstVC {
                if let popupContentView = firstVC.containerVC.popupContentView {
                    popupContentView.popupImageView = albumArtImageView
                }
            }
            // DemoChildViewController
            else if let containerVC = self.popupContainerViewController {
                containerVC.popupContentView.popupImageView = albumArtImageView
            }
            
            albumArtImageView.layer.cornerRadius = 10
            albumArtImageView.layer.masksToBounds = true
        }
    }
    
    var albumArtImage: UIImage? {
        get {
            return self.albumArtImageView.image
        }
        set (newValue) {
            self.albumArtImageView.image = newValue
        }
    }
    
    @IBOutlet weak var topModule: UIView! {
        didSet {
            if let firstVC = self.firstVC {
                if let popupContentView = firstVC.containerVC.popupContentView {
                    popupContentView.popupTopModule = self.topModule
                }
            }
        }
    }
    @IBOutlet weak var bottomModule: UIView! {
        didSet {
            if let firstVC = self.firstVC {
                if let popupContentView = firstVC.containerVC.popupContentView {
                    popupContentView.popupBottomModule = bottomModule
                }
            }
        }
    }
    @IBOutlet weak var bottomModuleTopConstraint: NSLayoutConstraint! {
        didSet {
            if let firstVC = self.firstVC {
                if let popupContentView = firstVC.containerVC.popupContentView {
                    popupContentView.popupBottomModuleTopConstraint = bottomModuleTopConstraint
                }
            }
        }
    }
    
    @IBOutlet weak var progressView: UIProgressView!

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
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
        if let firstVC = self.firstVC {
            if let popupBar = firstVC.containerVC.popupBar {
                self.albumArtImage = popupBar.image
                self.songNameLabel.text = popupBar.title
                self.albumNameLabel.text = popupBar.subtitle
            }
        }
        // DemoChildViewController
        else if let containerVC = self.popupContainerViewController {
            if let popupBar = containerVC.popupBar {
                self.albumArtImage = popupBar.image
                self.songNameLabel.text = popupBar.title
                self.albumNameLabel.text = popupBar.subtitle
            }
        }
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
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
        }
        #endif
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        guard let firstVC = self.firstVC else {return .lightContent}
        guard let popupContentView = firstVC.containerVC.popupContentView else {return .default}
        
        if popupContentView.popupPresentationStyle != .deck {
            return .default
        }
        return .lightContent
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    deinit {
        PBLog("deinit \(self)")
        self.closeButton = nil
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
        self.playPauseButton.setImage(self.isPlaying ? #imageLiteral(resourceName: "nowPlaying_pause") : #imageLiteral(resourceName: "nowPlaying_play"), for: .normal)
        
        guard let firstVC = self.firstVC else {return}
        
        guard let popupBar = firstVC.containerVC.popupBar else {return}
        if popupBar.popupBarStyle == .prominent {
            popupBar.rightBarButtonItems?.first?.image = self.isPlaying ? #imageLiteral(resourceName: "pause-small") : #imageLiteral(resourceName: "play-small")
        }
        let dev = UIDevice.current.userInterfaceIdiom
        popupBar.leftBarButtonItems?[dev == .phone ? 0 : 1].image = self.isPlaying ? #imageLiteral(resourceName: "pause-small") : #imageLiteral(resourceName: "play-small")
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
        
        guard let popupBar = firstVC.containerVC.popupBar else {return}
        
        self.albumArtImage = popupBar.image
        self.songNameLabel.text = popupBar.title
        self.albumNameLabel.text = popupBar.subtitle
    }
    
    @IBAction func nextAction(_ sender: Any) {
        PBLog("nextAction")
        
        guard let firstVC = self.firstVC else {return}
        
        firstVC.nextAction(self)
        
        guard let popupBar = firstVC.containerVC.popupBar else {return}
        
        self.albumArtImage = popupBar.image
        self.songNameLabel.text = popupBar.title
        self.albumNameLabel.text = popupBar.subtitle
    }
    
    @objc func tick() {
        guard let firstVC = self.firstVC else {return}
        
        guard let popupBar = firstVC.containerVC.popupBar else {return}
        
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
