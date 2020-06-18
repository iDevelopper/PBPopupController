//
//  DemoChildViewController_iPad.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 10/02/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import UIKit

private let reuseIdentifier = "musicCollectionViewCell"

class DemoChildViewController_iPad: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
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
    
    weak var containerController: DemoContainerController_iPad!
    
    var images = [UIImage]()
    var titles = [String]()
    var subtitles = [String]()

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for idx in 1...self.collectionView(collectionView, numberOfItemsInSection: 0) {
            let imageName = String(format: "Cover%02d", idx)
            images += [UIImage(named: imageName)!]
            titles += [LoremIpsum.title]
            subtitles += [LoremIpsum.sentence]
        }
        
        if #available(iOS 13.0, *) {
            #if compiler(>=5.1)
            self.collectionView.backgroundColor = UIColor.PBRandomAdaptiveColor()
            #else
            self.collectionView.backgroundColor = UIColor.PBRandomExtraLightColor()
            #endif
        } else {
            self.collectionView.backgroundColor = UIColor.PBRandomExtraLightColor()
        }
        
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .always
        }
        
        let home = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(dismiss(_:)))
        self.navigationItem.rightBarButtonItem = home

        if let container = self.containerController {
            self.title = container.title
            container.popupBar.image = self.images[0]
            container.popupBar.title = self.titles[0]
            container.popupBar.subtitle = self.subtitles[0]
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let insets = UIEdgeInsets.init(top: 0, left: 0, bottom: 64, right: 0)
        self.collectionView.contentInset = insets
        self.collectionView.scrollIndicatorInsets = insets
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.reloadData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
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
        if let container = self.containerController {
            container.dismissPopup()
            self.performSegue(withIdentifier: "unwindToHome", sender: self)
        }
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

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MusicCollectionViewCell
        
        if let container = self.containerController {
            container.popupBar.image = cell.imageView.image
            container.popupBar.title = cell.title.text
            container.popupBar.subtitle = cell.subtitle.text
            
            container.presentPopup()
        }
    }
}
