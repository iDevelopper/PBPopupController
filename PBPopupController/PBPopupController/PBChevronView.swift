//
//  PBChevronView.swift
//  PBPopupController
//
//  Created by Patrick BODET on 25/04/2018.
//  Copyright © 2018-2020 Patrick BODET. All rights reserved.
//

import UIKit

/**
 Available states of PBChevronView.
 */
internal enum PBChevronViewState : Int {
    case up = -1
    case flat = 0
    case down = 1
}

private let _PBChevronDefaultWidth: CGFloat = 4.67
private let _PBChevronAngleCoefficient: CGFloat = 42.5714286
private let _PBChevronDefaultAnimationDuration: TimeInterval = 0.3

internal class PBChevronView: UIView {
    var state: PBChevronViewState! {
        didSet {
            self.setState(state, animated: false)
        }
    }
    
    var width: CGFloat = 5.5 {
        didSet {
            self.setNeedsLayout()
        }
    }
    var animationDuration: TimeInterval = 0.0
    
    var effectView: UIVisualEffectView!
    
    private var leftView: UIView!
    private var rightView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._commonInit()
    }
    
    func _commonInit() {
        self.tintColor = nil
        self.width = _PBChevronDefaultWidth
        self.animationDuration = _PBChevronDefaultAnimationDuration
        self.isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.leftView == nil {
            self.leftView = UIView(frame: CGRect.zero)
            self.leftView.backgroundColor = self.tintColor
            self.leftView.isUserInteractionEnabled = false
            self.rightView = UIView(frame: CGRect.zero)
            self.rightView.backgroundColor = self.tintColor
            self.rightView.isUserInteractionEnabled = false
            self.addSubview(self.leftView)
            self.addSubview(self.rightView)
        }
        var leftFrame: CGRect
        var rightFrame: CGRect
        let tuple = bounds.divided(atDistance: bounds.size.width * 0.5, from: .minXEdge)
        leftFrame = tuple.slice
        rightFrame = tuple.remainder
        leftFrame.size.height = self.width
        rightFrame.size.height = leftFrame.size.height
        let angle: CGFloat = bounds.size.height / bounds.size.width * _PBChevronAngleCoefficient
        let dx: CGFloat = leftFrame.size.width * (1 - cos(angle * .pi / 180.0)) / 2.0
        leftFrame = leftFrame.offsetBy(dx: width / 2 + dx - 0.75, dy: 0.0)
        rightFrame = rightFrame.offsetBy(dx: -(width / 2) - dx + 0.75, dy: 0.0)
        self.leftView.bounds = leftFrame
        self.rightView.bounds = rightFrame
        self.leftView.center = CGPoint(x: leftFrame.midX, y: bounds.midY)
        self.rightView.center = CGPoint(x: rightFrame.midX, y: bounds.midY)
        self.leftView.layer.cornerRadius = width / 2.0
        self.rightView.layer.cornerRadius = width / 2.0
        self.setState(state, animated: false)
    }
    
    override func tintColorDidChange() {
        guard self.leftView != nil else {
            return
        }
        self.leftView.backgroundColor = self.tintColor
        self.rightView.backgroundColor = self.tintColor
    }
    
    private func setState(_ state: PBChevronViewState, animated: Bool) {
        if self.leftView == nil {
            return
        }
        
        let angle: CGFloat = self.bounds.size.height / self.bounds.size.width * _PBChevronAngleCoefficient
        
        let transition: (() -> Void)? = {() -> Void in
            self.leftView.transform = CGAffineTransform(rotationAngle: CGFloat(-state.rawValue) * angle * .pi / 180.0)
            self.rightView.transform = CGAffineTransform(rotationAngle: CGFloat(state.rawValue) * angle * .pi / 180.0)
        }
        if animated == false {
            if let aTransition = transition {
                UIView.performWithoutAnimation(aTransition)
            }
        } else {
            if let aTransition = transition {
                UIView.animate(withDuration: animationDuration, animations: aTransition)
            }
        }
    }
}
