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
            albumArtImageView.layer.cornerCurve = .continuous
            albumArtImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var songNameLabel: MarqueeLabel! {
        didSet {
            songNameLabel.animationDelay = 2
            songNameLabel.speed = .rate(15)
            songNameLabel.textColor = UIColor.label
            let fontSize: CGFloat = 17
            let fontWeight: UIFont.Weight = .semibold
            let textStyle: UIFont.TextStyle = .body
            songNameLabel.font = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: UIFont.systemFont(ofSize: fontSize, weight: fontWeight))
            songNameLabel.adjustsFontForContentSizeCategory = true
            songNameLabel.setContentHuggingPriority(.required, for: .vertical)
        }
    }
    
    @IBOutlet weak var albumNameLabel: MarqueeLabel! {
        didSet {
            albumNameLabel.textColor = UIColor.red
            albumNameLabel.animationDelay = 2
            albumNameLabel.speed = .rate(20)
            albumNameLabel.textColor = UIColor.systemPink
            let fontSize: CGFloat = 15
            let fontWeight: UIFont.Weight = .medium
            let textStyle: UIFont.TextStyle = .subheadline
            albumNameLabel.font = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: UIFont.systemFont(ofSize: fontSize, weight: fontWeight))
            albumNameLabel.adjustsFontForContentSizeCategory = true
            albumNameLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
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
    
    @IBOutlet weak var timerButton: UIButton! {
        didSet {
            let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .default)
            timerButton.setImage(UIImage(systemName: "timer", withConfiguration: configuration), for: .normal)
            timerButton.tintColor = UIColor.systemPink
        }
    }
    
    @IBOutlet weak var volumeSlider: UISlider! {
        didSet {
            volumeSlider.tintColor = UIColor.label
        }
    }
    
    @IBOutlet weak var airPlayAudioButton: UIButton! {
        didSet {
            var image: UIImage?
            let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .default)
            if #available(iOS 18.0, *) {
                image = UIImage(systemName: "airplay.audio", withConfiguration: configuration)
            }
            else {
                image = UIImage(systemName: "airplayaudio", withConfiguration: configuration)
            }
            airPlayAudioButton.setImage(image, for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
