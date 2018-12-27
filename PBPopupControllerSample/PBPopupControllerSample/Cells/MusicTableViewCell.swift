//
//  MusicTableViewCell.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 22/10/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

class MusicTableViewCell: UITableViewCell {
	
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    
	override func layoutSubviews() {
		super.layoutSubviews()
		
        albumArtImageView.layer.masksToBounds = true
		albumArtImageView?.layer.cornerRadius = 3
		
		separatorInset = UIEdgeInsets(top: 0, left: songNameLabel!.frame.origin.x, bottom: 0, right: 0)
	}
}

