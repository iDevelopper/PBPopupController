//
//  DemoCollectionViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 13/11/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

private let reuseIdentifier = "musicCollectionViewCell"

class DemoCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    
    fileprivate var itemsPerRow: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {return 4}
        var statusBarOrientation: UIInterfaceOrientation = .unknown
        #if !targetEnvironment(macCatalyst)
        if #available(iOS 13.0, *) {
            statusBarOrientation = self.view.window?.windowScene?.interfaceOrientation ?? .unknown
        } else {
           statusBarOrientation = UIApplication.shared.statusBarOrientation
        }
        #endif
        if statusBarOrientation == .portrait || statusBarOrientation == .portraitUpsideDown {return 2}
        return 4
    }

    weak var firstVC: FirstTableViewController!

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            #if compiler(>=5.1)
            self.collectionView.backgroundColor = UIColor.PBRandomAdaptiveColor()
            #else
            self.collectionView.backgroundColor = UIColor.PBRandomExtraLightColor()
            #endif
        } else {
            self.collectionView.backgroundColor = UIColor.PBRandomExtraLightColor()
        }
        self.collectionView.contentInsetAdjustmentBehavior = .always
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.reloadData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            if self.isViewLoaded {
                self.collectionView.reloadData()
            }
        }, completion: nil)
    }

    deinit {
        PBLog("deinit \(self)")
    }
    
    // MARK: - Navigation

    @IBAction func dismiss(_ sender: Any) {
        self.firstVC.dismiss(sender)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let firstVC = self.firstVC {
            return firstVC.images.count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MusicCollectionViewCell
    
        cell.imageView.image = self.firstVC.images[indexPath.row]
        cell.title.text = self.firstVC.titles[indexPath.row]
        cell.subtitle.text = self.firstVC.subtitles[indexPath.row]
        
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            cell.title.textColor = UIColor.label
            cell.subtitle.textColor = UIColor.secondaryLabel
        }
        #endif

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath as IndexPath)
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    // MARK: - UICollectionView DelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.navigationController != nil {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.width, height: 32.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MusicCollectionViewCell
        
        if let firstVC = self.firstVC {
            firstVC.containerVC.popupBar.image = cell.imageView.image
            firstVC.containerVC.popupBar.title = cell.title.text
            firstVC.containerVC.popupBar.subtitle = cell.subtitle.text
            if let popupContentVC = firstVC.popupContentVC {
                popupContentVC.albumArtImage = cell.imageView.image!
                popupContentVC.songTitle = cell.title.text!
                popupContentVC.albumTitle = cell.subtitle.text!
            }
            if let popupContentTVC = firstVC.popupContentTVC {
                popupContentTVC.albumArtImage = cell.imageView.image!
                popupContentTVC.songTitle = cell.title.text!
                popupContentTVC.albumTitle = cell.subtitle.text!
            }
            firstVC.presentPopupBar(self)
        }
    }
}
