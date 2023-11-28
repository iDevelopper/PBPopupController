//
//  DemoBottomSheetViewController.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 26/11/2023.
//  Copyright © 2023 Patrick BODET. All rights reserved.
//

import UIKit

class DemoBottomSheetViewController: UIViewController {
    var timerSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
        setupSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let container = self.popupContainerViewController {
            let contentHeight = self.timerSwitch.frame.maxY
            container.popupContentView.popupContentSize = CGSize(width: container.view.safeAreaLayoutGuide.layoutFrame.width - 40, height: contentHeight + 8.0)
        }
    }
    
    private func setupSubviews() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .countDownTimer
        
        self.view.addSubview(datePicker)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.0).isActive = true
        datePicker.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0).isActive = true
        datePicker.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8.0).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        let minutes = 9
        let seconds = minutes * 60
        datePicker.countDownDuration = TimeInterval(seconds)
        
        let timerLabel = UILabel()
        var font = UIFont.systemFont(ofSize: 17, weight: .regular)
        font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: font)
        timerLabel.adjustsFontForContentSizeCategory = true
        timerLabel.text = "Timer"
        if #available(iOS 13.0, *) {
            timerLabel.textColor = UIColor.label
        }
        
        self.view.addSubview(timerLabel)
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timerLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20.0).isActive = true
        timerLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16.0).isActive = true

        self.timerSwitch = UISwitch()
        timerSwitch.onTintColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
        self.view.addSubview(timerSwitch)
        
        timerSwitch.translatesAutoresizingMaskIntoConstraints = false

        timerSwitch.centerYAnchor.constraint(equalTo: timerLabel.centerYAnchor, constant: 0.0).isActive = true
        timerSwitch.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16.0).isActive = true
        timerLabel.rightAnchor.constraint(equalTo: timerSwitch.leftAnchor, constant: -8.0).isActive = true
    }
}
