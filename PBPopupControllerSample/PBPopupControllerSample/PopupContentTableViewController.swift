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

    var popupContentVC: PopupContentViewController!
    
    weak var firstVC: FirstTableViewController!

    var playerView: UIView!

    var closeButton: PBPopupCloseButton!
    
    var images: [UIImage]
    var titles: [String]
    var subtitles: [String]
    
    required init?(coder aDecoder: NSCoder) {
        images = []
        titles = []
        subtitles = []
        
        super.init(coder:aDecoder)
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.tableView.insetsContentViewsToSafeArea = true
        }

        for idx in 1...self.tableView(tableView, numberOfRowsInSection: 1) {
            
            let imageName = String(format: "Cover%02d", idx)
            images += [UIImage(named: imageName)!]
            titles += [LoremIpsum.title]
            subtitles += [LoremIpsum.sentence]
        }
        
        self.popupContentVC = self.storyboard?.instantiateViewController(withIdentifier: "PopupContentViewController") as? PopupContentViewController
        self.popupContentVC.modalPresentationStyle = .custom
        self.popupContentVC.firstVC = self.firstVC
        self.playerView = self.popupContentVC?.view
        
        // Test in case of UIModalPresentationStyle == .fullScreen (not presented by popupController, not .custom)
        if self.popupContainerViewController != nil {
            if let popupContentView = self.popupContainerViewController.popupContentView {
                popupContentView.popupImageModule = popupContentVC.imageModule
                popupContentView.popupImageView = popupContentVC.albumArtImageView
                popupContentView.popupControlsModule = popupContentVC.controlsModule
                popupContentView.popupControlsModuleTopConstraint = popupContentVC.controlsModuleTopConstraint
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.popupContainerViewController != nil {
            self.popupContentVC.albumArtImage = self.popupContainerViewController.popupBar.image
            self.popupContentVC.songNameLabel.text = self.popupContainerViewController.popupBar.title
            self.popupContentVC.albumNameLabel.text = self.popupContainerViewController.popupBar.subtitle
        
            self.tableView.reloadData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if self.modalPresentationStyle == .fullScreen {
            return .default
        }
        if self.popupContainerViewController.popupContentView.popupPresentationStyle != .deck {
            return .default
        }
        return .lightContent
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

            // Configure the cell...
            cell.contentView.addSubview(self.playerView)
            cell.contentView.bringSubviewToFront(cell.closeButton)
            cell.closeButton.setImage(nil, for: .normal)
            if self.popupContainerViewController != nil {
                self.popupContainerViewController.popupContentView.popupCloseButton = cell.closeButton
            }
            cell.closeButton.removeTarget(nil, action: nil, for: .touchUpInside)
            cell.closeButton.addTarget(self, action: #selector(closePopupContent), for: .touchUpInside)

            cell.selectionStyle = .none
            
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "musicTableViewCell", for: indexPath) as! MusicTableViewCell
            cell.albumArtImageView.image = images[indexPath.row]
            cell.songNameLabel.text = titles[indexPath.row]
            cell.albumNameLabel.text = subtitles[indexPath.row]
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if self.popupContainerViewController != nil {
                return self.view.bounds.height
            }
            else {
                return self.view.bounds.height
            }
        }
        return 60
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //cell.backgroundColor = UIColor.clear
        if indexPath.section == 0 {
            self.popupContentVC.songNameLabel.restartLabel()
            self.popupContentVC.albumNameLabel.restartLabel()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            //let musicCell = tableView.cellForRow(at: indexPath) as! MusicTableViewCell
            
            if self.popupContainerViewController != nil, let popupBar = self.popupContainerViewController.popupBar {
                self.popupContentVC.albumArtImage = self.images[indexPath.row]
                self.popupContentVC.songNameLabel.text = self.titles[indexPath.row]
                self.popupContentVC.albumNameLabel.text = self.subtitles[indexPath.row]
                popupBar.image = self.images[indexPath.row]
                popupBar.title = self.titles[indexPath.row]
                popupBar.subtitle = self.subtitles[indexPath.row]
                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .top, animated: true)
                }
            }
        }
    }
}
