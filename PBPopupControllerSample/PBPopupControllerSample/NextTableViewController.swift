//
//  NextTableViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 17/12/2022.
//  Copyright © 2022 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class NextTableViewController: UITableViewController {
    
    var images = [UIImage]()
    var titles = [String]()
    var subtitles = [String]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for idx in 1...self.tableView(tableView, numberOfRowsInSection: 0) {
            let imageName = String(format: "Cover%02d", idx)
            images += [UIImage(named: imageName)!]
            titles += [LoremIpsum.title]
            subtitles += [LoremIpsum.sentence]
        }
        
        self.tableView.backgroundColor = UIColor.PBRandomAdaptiveColor()
        
        self.tableView.tableFooterView = UIView()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(pushNext(_:)))
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80.0
    }
    
    @objc func pushNext(_ sender: Any) {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "NextTableViewController") as? NextTableViewController {
            self.show(nextVC, sender: sender)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 22
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicTableViewCell", for: indexPath) as! MusicTableViewCell
        cell.albumArtImageView.image = images[indexPath.row]
        cell.songNameLabel.text = titles[indexPath.row]
        cell.albumNameLabel.text = subtitles[indexPath.row]
        cell.selectionStyle = .default
        
        var font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.songNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        cell.songNameLabel.adjustsFontForContentSizeCategory = true
        
        font = UIFont.systemFont(ofSize: 13, weight: .regular)
        cell.albumNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        cell.albumNameLabel.adjustsFontForContentSizeCategory = true
        
        cell.songNameLabel.textColor = UIColor.label
        cell.albumNameLabel.textColor = UIColor.secondaryLabel
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("\(String(describing: self.popupContainerViewController()))")
        if let containerVC = popupContainerViewController, let popupBar = containerVC.popupBar {
            popupBar.image = images[indexPath.row]
            popupBar.title = titles[indexPath.row]
            popupBar.subtitle = subtitles[indexPath.row]
        }
    }
}
