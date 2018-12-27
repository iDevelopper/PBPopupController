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
    
    @IBOutlet weak var imageModule: UIView!
    @IBOutlet weak var imageModuleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageModuleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageModuleTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var albumArtImageView: UIImageView!
    
    var albumArtImage: UIImage? {
        get {
            return self.albumArtImageView.image
        }
        set (newValue) {
            self.albumArtImageView.image = newValue
        }
    }
    
    @IBOutlet weak var controlsModule: UIView!
    @IBOutlet weak var controlsModuleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsModuleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsModuleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var progressView: UIProgressView!

    //@IBOutlet weak var songNameLabel: UILabel!
    //@IBOutlet weak var albumNameLabel: UILabel!

    @IBOutlet weak var songNameLabel: MarqueeLabel!
    @IBOutlet weak var albumNameLabel: MarqueeLabel!
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var volumeSlider: UISlider!
    
    let accessibilityDateComponentsFormatter = DateComponentsFormatter()
    var timer: Timer?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.songNameLabel.animationDelay = 2
        self.songNameLabel.speed = .rate(15)
        self.albumNameLabel.animationDelay = 2
        self.albumNameLabel.speed = .rate(20)
        
        self.closeButton = PBPopupCloseButton(style: .round)
        let statusBarFrame = UIApplication.shared.statusBarFrame
        self.closeButton.frame = CGRect(x: 8, y: statusBarFrame.height + 8.0, width: 25, height: 25)
        self.closeButton.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)

        self.setupImageViewForPlaying(self.isPlaying)

        self.accessibilityDateComponentsFormatter.unitsStyle = .spellOut
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PBLog("viewWillAppear")
        super.viewWillAppear(animated)
    
        if self.popupContainerViewController != nil {
            self.albumArtImage = self.popupContainerViewController.popupBar.image
            self.songNameLabel.text = self.popupContainerViewController.popupBar.title
            self.albumNameLabel.text = self.popupContainerViewController.popupBar.subtitle
            
            if let popupContentView = self.popupContainerViewController.popupContentView {
                popupContentView.popupImageModule = self.imageModule
                popupContentView.popupImageView = self.albumArtImageView
                popupContentView.popupControlsModule = self.controlsModule
                popupContentView.popupControlsModuleTopConstraint = self.controlsModuleTopConstraint
            }
        }
        
        if self.modalPresentationStyle != .custom {
            self.view.addSubview(self.closeButton)
        }
        else {
            self.closeButton.removeFromSuperview()
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
    
    /*
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
     
        coordinator.animate(alongsideTransition: { (context) in
        })
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    */
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if self.modalPresentationStyle == .fullScreen {
            return .default
        }
        guard let containerVC = self.popupContainerViewController else {return .default}
        guard let popupContentView = containerVC.popupContentView else {return .default}
        if popupContentView.popupPresentationStyle != .deck {
            return .default
        }
        return .lightContent
    }
    /*
    override var prefersStatusBarHidden: Bool {
        return true
    }
    */
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
    
    func setupImageViewForPlaying(_ playing: Bool) {
        if playing == true {
            
            self.imageModuleTopConstraint.constant -= 20;
            self.imageModuleLeadingConstraint.constant -= 20
            self.imageModuleTrailingConstraint.constant -= 20
            self.controlsModuleTopConstraint.constant -= 20
            
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
        else {
            
            self.imageModuleTopConstraint.constant += 20;
            self.imageModuleLeadingConstraint.constant += 20
            self.imageModuleTrailingConstraint.constant += 20
            self.controlsModuleTopConstraint.constant += 20

            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }) { (_ ) in
                //
            }
            
            self.imageModule.layer.backgroundColor = UIColor.clear.cgColor
            self.imageModule.layer.shadowOpacity = 0.0

            self.albumArtImageView.layer.cornerRadius = 10
            self.albumArtImageView.layer.masksToBounds = true
        }
        
    }

    func setupTimer() {
        if self.timer == nil {
            /*
            self.timer = Timer(timeInterval: 0.01, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.common)
            */
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
        guard let popupContentVC = firstVC.popupContentVC else {return}
        guard let containerVC = popupContentVC.popupContainerViewController else {return}
        guard let popupBar = containerVC.popupBar else {return}
        
        if popupBar.popupBarStyle == .prominent {
            popupBar.rightBarButtonItems?.first?.image = self.isPlaying ? #imageLiteral(resourceName: "pause-small") : #imageLiteral(resourceName: "play-small")
        }
        let dev = UIDevice.current.userInterfaceIdiom
        popupBar.leftBarButtonItems?[dev == .phone ? 0 : 1].image = self.isPlaying ? #imageLiteral(resourceName: "pause-small") : #imageLiteral(resourceName: "play-small")
        self.setupImageViewForPlaying(self.isPlaying)
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
        guard let popupContentVC = firstVC.popupContentVC else {return}
        guard let containerVC = popupContentVC.popupContainerViewController else {return}
        guard let popupBar = containerVC.popupBar else {return}
        
        firstVC.prevAction(self)
        
        self.albumArtImage = popupBar.image
        self.songNameLabel.text = popupBar.title
        self.albumNameLabel.text = popupBar.title
    }
    
    @IBAction func nextAction(_ sender: Any) {
        PBLog("nextAction")
        
        guard let firstVC = self.firstVC else {return}
        guard let popupContentVC = firstVC.popupContentVC else {return}
        guard let containerVC = popupContentVC.popupContainerViewController else {return}
        guard let popupBar = containerVC.popupBar else {return}
        
        firstVC.nextAction(self)
        
        self.albumArtImage = popupBar.image
        self.songNameLabel.text = popupBar.title
        self.albumNameLabel.text = popupBar.title
    }
    
    @objc func tick() {
        guard let firstVC = self.firstVC else {return}
        guard let popupContentVC = firstVC.popupContentVC else {return}
        guard let containerVC = popupContentVC.popupContainerViewController else {return}
        guard let popupBar = containerVC.popupBar else {return}
        
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
    
    // MARK: - Navigation
    
    @objc func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
