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

    weak var firstVC: FirstTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            #if compiler(>=5.1)
            self.tableView.backgroundColor = UIColor.PBRandomAdaptiveColor()
            #else
            self.tableView.backgroundColor = UIColor.PBRandomExtraLightColor()
            #endif
        } else {
            self.tableView.backgroundColor = UIColor.PBRandomExtraLightColor()
        }
    
        self.tableView.tableFooterView = UIView()
        
        self.tableView.tableHeaderView = nil
        if (self.navigationController == nil) {
            self.tableView.tableHeaderView = self.headerView
        }
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80.0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion <= 10 {
            let insets = UIEdgeInsets.init(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    @IBAction func dismiss(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vc = self.firstVC else {return 0}
        return vc.images.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicTableViewCell", for: indexPath) as! MusicTableViewCell

        // Configure the cell...
        cell.albumArtImageView.image = self.firstVC!.images[indexPath.row]
        cell.songNameLabel.text = self.firstVC!.titles[indexPath.row]
        cell.albumNameLabel.text = self.firstVC!.subtitles[indexPath.row]

        if #available(iOS 11.0, *) {
            var font = UIFont.systemFont(ofSize: 17, weight: .regular)
            cell.songNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
            cell.songNameLabel.adjustsFontForContentSizeCategory = true
            
            font = UIFont.systemFont(ofSize: 13, weight: .regular)
            cell.albumNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
            cell.albumNameLabel.adjustsFontForContentSizeCategory = true
        }
        else {
            cell.songNameLabel.font = UIFont.preferredFont(forTextStyle: .body)
            cell.albumNameLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
            if #available(iOS 10.0, *) {
                cell.songNameLabel.adjustsFontForContentSizeCategory = true
                cell.albumNameLabel.adjustsFontForContentSizeCategory = true
            }
        }
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            cell.songNameLabel.textColor = UIColor.label
            cell.albumNameLabel.textColor = UIColor.secondaryLabel
        }
        #endif

        cell.backgroundColor = UIColor.clear
        
        return cell
    }

    // MARK: - Table view delegate
    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    */
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cell = tableView.cellForRow(at: indexPath) as! MusicTableViewCell
        
        self.firstVC!.containerVC.popupBar.image = cell.albumArtImageView.image
        self.firstVC!.containerVC.popupBar.title = cell.songNameLabel.text
        self.firstVC!.containerVC.popupBar.subtitle = cell.albumNameLabel.text
        
        if self.firstVC!.containerVC.popupController.popupPresentationState == .hidden {
            self.firstVC!.presentPopBar(cell)
        }
    }
}
