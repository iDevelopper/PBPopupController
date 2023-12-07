//
//  PlayerTableViewCell.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 11/11/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell
{
    @IBOutlet weak var albumArtImageView: UIImageView! {
        didSet {
            albumArtImageView.layer.cornerRadius = 10
            albumArtImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var songNameLabel: MarqueeLabel! {
        didSet {
            songNameLabel.animationDelay = 2
            songNameLabel.speed = .rate(15)
            songNameLabel.textColor = UIColor.label
        }
    }
    
    @IBOutlet weak var albumNameLabel: MarqueeLabel! {
        didSet {
            albumNameLabel.textColor = UIColor.red
            albumNameLabel.animationDelay = 2
            albumNameLabel.speed = .rate(20)
            albumNameLabel.textColor = UIColor.systemPink
        }
    }

    @IBOutlet weak var prevButton: UIButton! {
        didSet {
            prevButton.tintColor = UIColor.label
        }
    }
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.tintColor = UIColor.label
        }
    }
    
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.tintColor = UIColor.label
        }
    }
    
    @IBOutlet weak var volumeSlider: UISlider! {
        didSet {
            volumeSlider.tintColor = UIColor.label
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
