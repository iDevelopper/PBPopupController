//
//  UIView+Snapshot.swift
//  PBPopupController
//
//  Created by Patrick BODET on 05/05/2018.
//  Copyright © 2018-2020 Patrick BODET. All rights reserved.
//

import UIKit

internal extension UIView
{
    func makeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func makeSnapshot(from rect: CGRect? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
        
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // If no `rect` provided, return image of whole view
        guard let image = wholeImage, let rect = rect else { return wholeImage }
        
        // Otherwise, grab specified `rect` of image
        let scale = image.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }

    func snapshot() -> UIImageView {
        return UIImageView(image: asImage())
    }
    
    func asImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
