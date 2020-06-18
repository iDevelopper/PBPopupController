//
//  MusicCollectionViewCell.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 13/11/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

class MusicCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView?.layer.masksToBounds = true
        self.imageView?.layer.cornerRadius = 5
    }
}
