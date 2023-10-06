//
//  SwitchTableViewCell.swift
//  ShoutRadiosSwift
//
//  Created by Patrick BODET on 01/10/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var switchSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
