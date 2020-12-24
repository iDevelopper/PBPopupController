//
//  CGMath.swift
//  PBPopupController
//
//  Created by Patrick BODET on 29/03/2018.
//  Copyright © 2018-2020 Patrick BODET. All rights reserved.
//
//  From Emilio Peláez on 11/10/16.
//  https://github.com/EmilioPelaez/CGMathSwift//
//

import CoreGraphics

internal func lerp(start: CGFloat, end: CGFloat, progress: CGFloat) -> CGFloat {
    return (1 - progress) * start + progress * end
}

internal func lerp(start: CGPoint, end: CGPoint, progress: CGFloat) -> CGPoint {
    return CGPoint(x: lerp(start: start.x, end: end.x, progress: progress),
                   y: lerp(start: start.y, end: end.y, progress: progress))
}

internal func lerp(start: CGSize, end: CGSize, progress: CGFloat) -> CGSize {
    return CGSize(width: lerp(start: start.width, end: end.width, progress: progress),
                  height: lerp(start: start.height, end: end.height, progress: progress))
}

internal func lerp(start: CGRect, end: CGRect, progress: CGFloat) -> CGRect {
    let origin = lerp(start: start.origin, end: end.origin, progress: progress)
    let size = lerp(start: start.size, end: end.size, progress: progress)
    return CGRect(origin: origin, size: size)
}
