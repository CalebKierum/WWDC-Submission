//  Compatability.swift
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb Kierum. All rights reserved.
//

/*
 Explanation: To build the playground on a Mac I needed the code to be easily compiled on both MacOS and iOS. This file exposes extensions and typedefs that allow for the code to be compiled on iOS or macOS
 
 I do not use ifdef(os) here because I use the iOS compiler on Mac to test for iOS compilation
 
 This is all because when a playground runs in iOS mode it will try to use an iOS simulator iOS simulators can not run metal only compile code
 */


import Metal

import UIKit
public typealias Color = UIColor //NSColor
public typealias Image = UIImage //NSImage
public typealias Rect = CGRect //NSRect
public typealias View = UIView //NSView
public typealias ImageView = UIImageView //NSImageView
public typealias Size = CGSize
public typealias Point = CGPoint
public typealias Font = UIFont
public typealias Text = UITextField
public typealias Bezier = UIBezierPath
public typealias Alignment = NSTextAlignment
public typealias ViewController = UIViewController
public let round = CGLineCap.round
public let compat_yScalar:CGFloat = -1
extension CIColor {
    static func convert(color: UIColor) -> CIColor {
        return CIColor(color: color)
    }
}
extension UIImage {
    convenience init(cgImage: CGImage, size: Size) {
        self.init(cgImage: cgImage)
    }
}
extension UIView {
    var wantsLayer: Bool { set {} get {return false} }
}
extension UITextField {
    convenience init(labelWithString: String) {
        self.init()
        self.text = labelWithString
    }
    var alignment:NSTextAlignment {
        set (data) {
            self.textAlignment = data
        }
        get {
            return NSTextAlignment.left
        }
    }
}
extension UIBezierPath {
    func line(to: Point) {
        return addLine(to: to)
    }
}
extension playgroundMetalView {
    func updateViewer() {
        if let curr = viewLayer {
            curr.removeFromSuperlayer()
        }

        viewLayer = CALayer()
        viewLayer?.frame = Rect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        viewLayer?.contentsGravity = kCAGravityResizeAspectFill
        viewLayer?.contents = drawable?.displayInPlayground()?.cgImage
        //This may look weird but its a good way to get it to work on UIView and NSView
        if let laya = (layer as Any) as? CALayer {
            laya.insertSublayer(viewLayer!, at: 0)
        }
    }
}
func synchronize(texture: MTLTexture, buffer: MTLCommandBuffer) {}

//import Cocoa
//public typealias Color = NSColor
//public typealias Image = NSImage
//public typealias Rect = NSRect
//public typealias View = NSView
//public typealias ImageView = NSImageView
//public typealias Size = NSSize
//public typealias Point = NSPoint
//public typealias Font = NSFont
//public typealias Text = NSTextField
//public typealias Bezier = NSBezierPath
//public typealias Alignment = NSTextAlignment
//public typealias ViewController = NSViewController
//public let round = NSBezierPath.LineCapStyle.roundLineCapStyle
//public let compat_yScalar:CGFloat = 1
//extension CIColor {
//    static func convert(color: NSColor) -> CIColor {
//        return CIColor(color: color)!
//    }
//}
//func synchronize(texture: MTLTexture, buffer: MTLCommandBuffer) {
//    let syncEncoder = buffer.makeBlitCommandEncoder()!
//    syncEncoder.synchronize(resource: texture)
//    syncEncoder.endEncoding()
//}
//extension playgroundMetalView {
//    func updateViewer() {
//        layer = CALayer()
//        layer?.contentsGravity = kCAGravityResizeAspectFill
//        layer?.contents = drawable?.displayInPlayground()
//        wantsLayer = true
//    }
//}
//extension NSView {
//    var backgroundColor:Color { get { return NSColor.red } set {}  }
//}
//
//
