//
//  PBPopupToolbar.swift
//  PBPopupController
//
//  Created by Patrick BODET on 21/12/2018.
//  Copyright © 2018-2024 Patrick BODET. All rights reserved.
//

import UIKit

internal class _PBPopupToolbar: UIToolbar {
    
    internal var popupBarIsFloating: Bool = false {
        didSet {
            self.setupAppearance()
        }
    }
    
    internal var shadowColor: UIColor! {
        didSet {
            self.setupAppearance()
        }
    }
    
    internal var shadowImage: UIImage! {
        didSet {
            self.setupAppearance()
        }
    }
    
    internal var backgroundImage: UIImage! {
        didSet {
            self.setupAppearance()
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let rv: UIView? = super.hitTest(point, with: event)
        
        if rv != nil && rv != self {
            let frameInBarCoords = convert(rv?.bounds ?? CGRect.zero, from: rv)
            let instetFrame: CGRect = frameInBarCoords.insetBy(dx: 2, dy: 0)
            
            return instetFrame.contains(point) ? rv : self
        }
        
        return rv
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //On iOS 11 reset the semantic content attribute to make sure it propagades to all subviews.
        if #available(iOS 11, *) {
            self.semanticContentAttribute = self.superview!.semanticContentAttribute
        }
    }
    
    func deepSetSemanticContentAttribute(_ semanticContentAttribute: UISemanticContentAttribute, to view: UIView?, startingFrom startingView: UIView?) {
        if view == startingView {
            super.semanticContentAttribute = semanticContentAttribute
        } else {
            view?.semanticContentAttribute = semanticContentAttribute
        }
        
        (view?.subviews as NSArray?)?.enumerateObjects({ obj, idx, stop in
            self.deepSetSemanticContentAttribute(semanticContentAttribute, to: obj as? UIView, startingFrom: startingView)
        })
    }
    
    override var semanticContentAttribute: UISemanticContentAttribute {
        get {
            return super.semanticContentAttribute
        }
        set(semanticContentAttribute) {
            if #available(iOS 11, *) {
                //On iOS 11, due to a bug in UIKit, the semantic content attribute must be propagaded recursively to all subviews, so that the system behaves correctly.
                self.deepSetSemanticContentAttribute(semanticContentAttribute, to: self, startingFrom: self)
            } else {
                super.semanticContentAttribute = semanticContentAttribute
            }
        }
    }
    
    func setupAppearance() {
        let toolbarAppearance = self.standardAppearance
        toolbarAppearance.configureWithDefaultBackground()
        toolbarAppearance.shadowColor = self.popupBarIsFloating ? nil : self.shadowColor
        toolbarAppearance.shadowImage = self.shadowImage
        toolbarAppearance.backgroundImage = self.backgroundImage
        toolbarAppearance.backgroundEffect = nil
        
        self.compactAppearance = toolbarAppearance
        self.standardAppearance = toolbarAppearance
        if #available(iOS 15.0, *) {
            self.scrollEdgeAppearance = toolbarAppearance
            self.compactScrollEdgeAppearance = toolbarAppearance
        }
    }
}
