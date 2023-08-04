//
//  PopupContentTableViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 07/10/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class PopupContentTableViewController: UITableViewController {
    
    var images: [UIImage]!
    var titles: [String]!
    var subtitles: [String]!
        
    var indexOfCurrentSong: Int = 0

    var isPlaying: Bool = false
    
    var albumArtImage: UIImage! {
        didSet {
            if isViewLoaded {
                let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PlayerTableViewCell
                cell.albumArtImageView.image = albumArtImage
                if let containerVC = self.popupContainerViewController {
                    containerVC.popupContentView.popupImageView = cell.albumArtImageView
                }
            }
        }
    }
    
    var songTitle: String! {
        didSet {
            if isViewLoaded {
                let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PlayerTableViewCell
                cell.songNameLabel.text = songTitle
            }
        }
    }
    
    var albumTitle: String! {
        didSet {
            if isViewLoaded {
                let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PlayerTableViewCell
                cell.albumNameLabel.text = albumTitle
            }
        }
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
#if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            self.tableView.backgroundColor = UIColor.secondarySystemBackground
        }
#endif
        self.tableView.insetsContentViewsToSafeArea = true
        self.tableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
#if !targetEnvironment(macCatalyst)
        let insets = UIEdgeInsets.init(top: 0, left: 0, bottom: self.view.safeAreaInsets.bottom, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
#endif
    }
    
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.tableView.reloadData()
        }, completion: nil)
    }
    
    deinit {
        PBLog("deinit \(self)")
    }
    
    // MARK: - Close button action
    
    @objc func closePopupContent() {
        if self.modalPresentationStyle == .custom {
            self.popupContainerViewController.closePopup(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 1}
        return 22
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "playerTableViewCell", for: indexPath) as! PlayerTableViewCell
            
            cell.albumArtImageView.image = self.albumArtImage
            cell.songNameLabel.text = self.songTitle
            cell.albumNameLabel.text = self.albumTitle
            if let containerVC = self.popupContainerViewController {
                containerVC.popupContentView.popupImageView = cell.albumArtImageView
            }
            
            cell.selectionStyle = .none
            
            cell.backgroundColor = UIColor.clear
            
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "musicTableViewCell", for: indexPath) as! MusicTableViewCell
            cell.albumArtImageView.image = self.images[indexPath.row]
            cell.songNameLabel.text = self.titles[indexPath.row]
            cell.albumNameLabel.text = self.subtitles[indexPath.row]

#if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                cell.songNameLabel.textColor = UIColor.label
                cell.albumNameLabel.textColor = UIColor.secondaryLabel
            }
#endif
            
            cell.selectionStyle = .default
            
            cell.backgroundColor = UIColor.clear
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.view.bounds.height
        }
        return 60
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            if self.popupContainerViewController != nil, let popupBar = self.popupContainerViewController.popupBar {
                popupBar.image = self.images[indexPath.row]
                popupBar.title = self.titles[indexPath.row]
                popupBar.subtitle = self.subtitles[indexPath.row]

                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .top, animated: false)
                    self.albumArtImage = self.images[indexPath.row]
                    self.songTitle = self.titles[indexPath.row]
                    self.albumTitle = self.subtitles[indexPath.row]
                }
            }
        }
    }
    
    // MARK: - Scroll view delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        if self.popupContainerViewController != nil, let popupContentView = self.popupContainerViewController.popupContentView, let popupCloseButton = popupContentView.popupCloseButton {
            popupCloseButton.isHidden = contentOffset.y <= 0 ? false : true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func playPauseAction(_ sender: Any?) {
        PBLog("playPauseAction")
        
        self.isPlaying = !self.isPlaying
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PlayerTableViewCell
        cell.playPauseButton.setImage(self.isPlaying ? UIImage(named: "nowPlaying_pause") : UIImage(named: "nowPlaying_play"), for: .normal)

        guard let containerVC = self.popupContainerViewController,
              let popupBar = containerVC.popupBar else {return}
        
        if popupBar.popupBarStyle == .prominent {
            popupBar.rightBarButtonItems?.first?.image = self.isPlaying ? UIImage(named: "pause-small") : UIImage(named: "play-small")
        }
        let dev = UIDevice.current.userInterfaceIdiom
        popupBar.leftBarButtonItems?[dev == .phone ? 0 : 1].image = self.isPlaying ? UIImage(named: "pause-small") : UIImage(named: "play-small")
        popupBar.leftBarButtonItems?[dev == .phone ? 0 : 1].accessibilityLabel = NSLocalizedString(self.isPlaying ? "Pause" : "Play", comment: "")
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

        self.albumArtImage = self.images[self.indexOfCurrentSong]
        self.songTitle = self.titles[self.indexOfCurrentSong]
        self.albumTitle = self.subtitles[self.indexOfCurrentSong]
    }
    
    @IBAction func moreAction(_ sender: Any) {
        PBLog("moreAction")
    }
}
