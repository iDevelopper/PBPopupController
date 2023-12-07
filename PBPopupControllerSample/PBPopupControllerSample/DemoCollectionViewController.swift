//
//  DemoCollectionViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 13/11/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

private let reuseIdentifier = "musicCollectionViewCell"

class DemoCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    
    fileprivate var itemsPerRow: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {return 4}
        var statusBarOrientation: UIInterfaceOrientation = .unknown
#if !targetEnvironment(macCatalyst)
        statusBarOrientation = self.view.window?.windowScene?.interfaceOrientation ?? .unknown
#endif
        if statusBarOrientation == .portrait || statusBarOrientation == .portraitUpsideDown {return 2}
        return 4
    }
    
    var images = [UIImage]()
    var titles = [String]()
    var subtitles = [String]()
    
    weak var firstVC: FirstTableViewController!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for idx in 1...self.collectionView(collectionView, numberOfItemsInSection: 0) {
            let imageName = String(format: "Cover%02d", idx)
            images += [UIImage(named: imageName)!]
            titles += [LoremIpsum.title]
            subtitles += [LoremIpsum.sentence]
        }
        
        self.collectionView.backgroundColor = .systemBackground

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
        self.dismiss(animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 22
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MusicCollectionViewCell
        
        cell.imageView.image = self.images[indexPath.row]
        cell.title.text = self.titles[indexPath.row]
        cell.subtitle.text = self.subtitles[indexPath.row]
        
        cell.title.textColor = UIColor.label
        cell.subtitle.textColor = UIColor.secondaryLabel
        
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
        print("\(String(describing: self.popupContainerViewController()))")
        if let containerVC = popupContainerViewController, let popupBar = containerVC.popupBar {
            popupBar.image = images[indexPath.row]
            popupBar.title = titles[indexPath.row]
            popupBar.subtitle = subtitles[indexPath.row]
        }
        
        if let firstVC = self.firstVC, let containerVC = firstVC.containerVC {
            if containerVC.popupController.popupPresentationState == .hidden {
                containerVC.presentPopupBar(withPopupContentViewController: firstVC.isPopupContentTableView ? firstVC.popupContentTVC : firstVC.popupContentVC, animated: true, completion: {
                    PBLog("Popup Bar Presented")
                })
            }
        }
    }
}
