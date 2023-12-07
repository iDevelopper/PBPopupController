//
//  DemoTableViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 20/04/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

class DemoTableViewController: UITableViewController {

    @IBOutlet weak var headerView: UIView!

    var images = [UIImage]()
    var titles = [String]()
    var subtitles = [String]()
            
    weak var firstVC: FirstTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for idx in 1...self.tableView(tableView, numberOfRowsInSection: 0) {
            let imageName = String(format: "Cover%02d", idx)
            images += [UIImage(named: imageName)!]
            titles += [LoremIpsum.title]
            subtitles += [LoremIpsum.sentence]
        }
        
        self.tableView.backgroundColor = .systemBackground
    
        self.tableView.tableFooterView = UIView()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80.0
        
        self.navigationItem.largeTitleDisplayMode = .automatic

        let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(pushNext(_:)))
        self.navigationItem.rightBarButtonItems?.append(rightBarButtonItem)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.tableHeaderView = nil
        if (self.navigationController == nil) {
            self.tableView.tableHeaderView = self.headerView
        }
        
        self.tableView.reloadData()
    }
    
    deinit {
        PBLog("deinit \(self)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    
    @objc func pushNext(_ sender: Any) {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DemoTableViewController") as? DemoTableViewController {
            nextVC.firstVC = self.firstVC
            nextVC.title = self.title
            self.show(nextVC, sender: sender)
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true)
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
        
        cell.albumArtImageView.image = self.images[indexPath.row]
        cell.songNameLabel.text = self.titles[indexPath.row]
        cell.albumNameLabel.text = self.subtitles[indexPath.row]
        
        var font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.songNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        cell.songNameLabel.adjustsFontForContentSizeCategory = true
        
        font = UIFont.systemFont(ofSize: 13, weight: .regular)
        cell.albumNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        cell.albumNameLabel.adjustsFontForContentSizeCategory = true
        
        cell.songNameLabel.textColor = UIColor.label
        cell.albumNameLabel.textColor = UIColor.secondaryLabel
        
        cell.selectionStyle = .none
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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
