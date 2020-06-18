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
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                songNameLabel.textColor = UIColor.label
            }
            #endif
        }
    }
    
    @IBOutlet weak var albumNameLabel: MarqueeLabel! {
        didSet {
            albumNameLabel.textColor = UIColor.red
            albumNameLabel.animationDelay = 2
            albumNameLabel.speed = .rate(20)
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                albumNameLabel.textColor = UIColor.systemPink
            }
            #endif
        }
    }

    @IBOutlet weak var prevButton: UIButton! {
        didSet {
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                prevButton.tintColor = UIColor.label
            }
            #endif
        }
    }
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                playPauseButton.tintColor = UIColor.label
            }
            #endif
        }
    }
    
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                nextButton.tintColor = UIColor.label
            }
            #endif
        }
    }
    
    @IBOutlet weak var volumeSlider: UISlider! {
        didSet {
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                volumeSlider.tintColor = UIColor.label
            }
            #endif
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
