/*
 MIT License

 Copyright (c) 2018 Christian Schnorr

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import CoreGraphics


extension CGVector {

    // MARK: - Operators

    internal static prefix func +(vector: CGVector) -> CGVector {
        return vector
    }

    internal static prefix func -(vector: CGVector) -> CGVector {
        return CGVector(dx: -vector.dx, dy: -vector.dy)
    }

    internal static func +(lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

    internal static func -(lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }

    internal static func *(scalar: CGFloat, vector: CGVector) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }

    internal static func *(scalar: Int, vector: CGVector) -> CGVector {
        return vector * CGFloat(scalar)
    }

    internal static func *(vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }

    internal static func *(vector: CGVector, scalar: Int) -> CGVector {
        return vector * CGFloat(scalar)
    }

    internal static func /(vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
    }

    internal static func /(vector: CGVector, scalar: Int) -> CGVector {
        return vector / CGFloat(scalar)
    }

    internal static func +=(lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs + rhs
    }

    internal static func -=(lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs - rhs
    }

    internal static func *=(vector: inout CGVector, scalar: CGFloat) {
        vector = vector * scalar
    }

    internal static func *=(vector: inout CGVector, scalar: Int) {
        vector = vector * scalar
    }

    internal static func /=(vector: inout CGVector, scalar: CGFloat) {
        vector = vector / scalar
    }

    internal static func /=(vector: inout CGVector, scalar: Int) {
        vector = vector / scalar
    }

    internal static func *(lhs: CGVector, rhs: CGVector) -> CGFloat {
        return lhs.dx * rhs.dx + lhs.dy * rhs.dy
    }


    // MARK: - Miscellaneous

    internal init(from source: CGPoint = .zero, to target: CGPoint) {
        let dx = target.x - source.x
        let dy = target.y - source.y

        self = CGVector(dx: dx, dy: dy)
    }

    internal var pointee: CGPoint {
        return CGPoint(x: self.dx, y: self.dy)
    }

    internal var length: CGFloat {
        return hypot(self.dx, self.dy)
    }

    internal var normalized: CGVector {
        return self / self.length
    }

    internal var magnitude: CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
}


// MARK: - Functions

internal func abs(_ vector: CGVector) -> CGFloat {
    return vector.length
}
