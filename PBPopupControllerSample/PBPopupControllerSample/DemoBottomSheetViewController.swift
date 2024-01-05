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
    var contentHeight: CGFloat = 0.0
    var withSubviews: Bool = true
    
    convenience init() {
        self.init(withSubviews: true)
    }
    
    init(withSubviews: Bool) {
        self.withSubviews = withSubviews
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red

        if withSubviews {
            self.view.backgroundColor = .systemBackground
            setupSubviews()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let container = self.popupContainerViewController, let popupContentView = container.popupContentView {
            
            if let timerSwitch = self.timerSwitch {
                self.contentHeight = timerSwitch.frame.maxY
            }
            if popupContentView.popupContentSize.width <= 0 {
                popupContentView.popupContentSize = CGSize(width: self.view.bounds.width - 40 - safeAreaInsets().left * 2, height: contentHeight > 0 ? contentHeight + 8.0 : 200.0)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if let container = self.popupContainerViewController, let popupContentView = container.popupContentView {
            popupContentView.popupContentSize = CGSize(width: container.view.bounds.size.width - 40 - safeAreaInsets().left * 2, height: contentHeight > 0 ? contentHeight + 8.0 : 200.0)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }
    
    private func layoutFrame() -> CGRect {
        return self.view.window?.safeAreaLayoutGuide.layoutFrame ?? self.view.bounds
    }
    
    private func safeAreaInsets() -> UIEdgeInsets {
        return self.view.window?.safeAreaInsets ?? .zero
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
        timerLabel.textColor = UIColor.label
        
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
