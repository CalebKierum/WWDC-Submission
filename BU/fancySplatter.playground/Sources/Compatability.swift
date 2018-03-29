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

//import UIKit
//public typealias Color = UIColor
//public typealias Image = UIImage
//public typealias Rect = CGRect
//public typealias View = UIView
//public typealias ImageView = UIImageView
//public typealias Size = CGSize
//public typealias Point = CGPoint
//public typealias Font = UIFont
//public typealias Text = UITextField
//public typealias Bezier = UIBezierPath
//public typealias Alignment = NSTextAlignment
//public typealias ViewController = UIViewController
//public let round = CGLineCap.round
//public let compat_yScalar:CGFloat = -1
//extension CIColor {
//    static func convert(color: UIColor) -> CIColor {
//        return CIColor(color: color)
//    }
//}
//extension UIImage {
//    convenience init(cgImage: CGImage, size: Size) {
//        self.init(cgImage: cgImage)
//    }
//}
//extension UIView {
//    var wantsLayer: Bool { set {} get {return false} }
//}
//extension UITextField {
//    convenience init(labelWithString: String) {
//        self.init()
//        self.text = labelWithString
//    }
//    var alignment:NSTextAlignment {
//        set (data) {
//            self.textAlignment = data
//        }
//        get {
//            return NSTextAlignment.left
//        }
//    }
//}
//extension UIBezierPath {
//    func line(to: Point) {
//        return addLine(to: to)
//    }
//}
//extension playgroundMetalView {
//    func updateViewer() {
//        if let curr = viewLayer {
//            curr.removeFromSuperlayer()
//        }
//
//        viewLayer = CALayer()
//        viewLayer?.frame = Rect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
//        viewLayer?.contentsGravity = kCAGravityResizeAspectFill
//        viewLayer?.contents = drawable?.displayInPlayground()?.cgImage
//        //This may look weird but its a good way to get it to work on UIView and NSView
//        if let laya = (layer as Any) as? CALayer {
//            laya.insertSublayer(viewLayer!, at: 0)
//        }
//    }
//}
//func synchronize(texture: MTLTexture, buffer: MTLCommandBuffer) {}
//public func liveWidth() -> CGFloat {
//    return UIScreen.main.bounds.width
//}
//public func liveHeight() -> CGFloat {
//    return UIScreen.main.bounds.height
//}

import Cocoa
public typealias Color = NSColor
public typealias Image = NSImage
public typealias Rect = NSRect
public typealias View = NSView
public typealias ImageView = NSImageView
public typealias Size = NSSize
public typealias Point = NSPoint
public typealias Font = NSFont
public typealias Text = NSTextField
public typealias Bezier = NSBezierPath
public typealias Alignment = NSTextAlignment
public typealias ViewController = NSViewController
public let round = NSBezierPath.LineCapStyle.roundLineCapStyle
public let compat_yScalar:CGFloat = 1
extension CIColor {
    static func convert(color: NSColor) -> CIColor {
        return CIColor(color: color)!
    }
}
func synchronize(texture: MTLTexture, buffer: MTLCommandBuffer) {
    let syncEncoder = buffer.makeBlitCommandEncoder()!
    syncEncoder.synchronize(resource: texture)
    syncEncoder.endEncoding()
}
extension playgroundMetalView {
    func updateViewer() {
        layer = CALayer()
        layer?.contentsGravity = kCAGravityResizeAspectFill
        if let tex2 = textureView {
            print("Using alt texture")
            layer?.contents = tex2.displayInPlayground()
        } else {
            layer?.contents = drawable?.displayInPlayground()
        }
        wantsLayer = true
    }
}
extension NSView {
    var backgroundColor:Color { get { return NSColor.red } set {}  }
}
public func liveWidth() -> CGFloat {
    return 500
}
public func liveHeight() -> CGFloat {
    return 300
}
public class GridHolder:ViewController {
    public var grid:GridView
    
    public init () {
        grid = GridView(size: 300)
        grid.translatesAutoresizingMaskIntoConstraints  = false
        super.init(nibName: nil, bundle: nil)
        view = View(frame: Rect(x: 0, y: 0, width: liveWidth(), height: liveHeight()))
        view.addSubview(grid)
    }
    
    public override func viewWillAppear() {
        /*public override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         */
        //let size = min(view.frame.width, view.frame.height)
        let size = min(liveWidth(), liveHeight())
        view.frame = Rect(x: 0, y: 0, width: liveWidth(), height: liveHeight())
        view.layer?.backgroundColor = NSColor.black.cgColor
        
        let center = Point(x: view.frame.width / 2, y: view.frame.height / 2)
        
        grid.frame = Rect(x: center.x - (size / 2), y: center.y - (size / 2), width: size, height: size)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func view(image: Image) {
        grid.view(image: image)
    }
}
extension GridView {
    public func updateImageFrame(img: Image, origin: Point, size: Size, length: CGFloat, majorThick: CGFloat) {
        var ypos = origin.y
        if (compat_yScalar == -1) {
            ypos = size.height - origin.y - (length + majorThick / 2)
        }
        imageView!.frame = Rect(x: origin.x, y: ypos, width: length + (majorThick / 2), height: length + (majorThick / 2))
        
        imageView!.layer = CALayer()
        imageView!.layer!.contentsGravity = kCAGravityResizeAspectFill
        imageView!.layer!.contents = img
        imageView!.wantsLayer = true
    }
}

