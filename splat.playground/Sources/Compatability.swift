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
import MetalKit
//
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
//func synchronize(texture: MTLTexture, buffer: MTLCommandBuffer) {}
//extension GridView {
//    public func updateImageFrame(img: Image, origin: Point, size: Size, length: CGFloat, majorThick: CGFloat) {
//
//        if (grid) {
//            var ypos = origin.y
//            if (compat_yScalar == -1) {
//                ypos = size.height - origin.y - (length + majorThick / 2)
//            }
//            imageView!.frame = Rect(x: origin.x, y: ypos, width: length + (majorThick / 2), height: length + (majorThick / 2))
//        } else {
//            let padding:CGFloat = 10
//            let size = frame.width - 2.0 * padding
//            imageView!.frame = Rect(x: (frame.width * 0.5) - size * 0.5, y: (frame.height * 0.5) - size * 0.5, width: size, height: size)
//        }
//
//        imageView!.layer.contentsGravity = kCAGravityResizeAspectFill
//        imageView!.layer.contents = img.cgImage
//        imageView!.wantsLayer = true
//    }
//    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isMultipleTouchEnabled = true
//        for touch in touches {
//            if let g = holder {
//                if let view = imageView {
//                    view.isMultipleTouchEnabled = true
//                    var location = touch.location(in: view)
//                    location.x /= view.frame.width
//                    location.y /= view.frame.height
//                    location.x *= 2
//                    location.y *= 2
//                    location.x -= 1
//                    location.y -= 1
//                    location.y *= -1
//                    g.pos(pos: location)
//                }
//            }
//        }
//    }
//}
//public class GridHolder:ViewController {
//    public var grid:GridView
//    public var image:Image? = nil
//    public var waterDelegate:WatercolorSimulation?
//
//    public init () {
//        grid = GridView()
//        grid.translatesAutoresizingMaskIntoConstraints  = false
//        super.init(nibName: nil, bundle: nil)
//        view.addSubview(grid)
//        grid.holder = self
//    }
//    public func pos(pos: Point) {
//        if let splotch = waterDelegate {
//            splotch.paintSplatter(pos: pos)
//        }
//    }
//    private func resize() {
//        let size = min(view.frame.width, view.frame.height)
//
//        //grid.removeFromSuperview()
//        //grid = GridView(size: size)
//        if let img = image {
//            grid.view(image: img)
//        }
//        //view.addSubview(grid)*/
//
//        let center = Point(x: view.frame.width / 2, y: view.frame.height / 2)
//
//        grid.frame = Rect(x: center.x - (size / 2), y: center.y - (size / 2), width: size, height: size)
//        grid.refresh()
//
//        view.isMultipleTouchEnabled = true
//
//    }
//    public override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        resize()
//    }
//    public override func updateViewConstraints() {
//        super.updateViewConstraints()
//        resize()
//    }
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    public func view(image: Image) {
//        self.image = image
//        resize()
//    }
//    public func gridOff() {
//        grid.gridOff()
//    }
//    public func gridOn() {
//        grid.gridOn()
//    }
//}
//extension TextureTools {
//    public static func loadTexture(image: UIImage) -> MTLTexture {
//        let textureLoader = MTKTextureLoader(device: metalState.sharedDevice!)
//
//        let options = [
//            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.renderTarget.rawValue),
//            MTKTextureLoader.Option.SRGB: false
//        ]
//
//        return ensure(try textureLoader.newTexture(cgImage: image.cgImage!, options: options))
//    }
//}
//extension Color {
//    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
//        self.init(displayP3Red: r, green: g, blue: b, alpha: 1.0)
//    }
//}
//public func getHighPoweredDev() -> MTLDevice {
//    return  ensure(MTLCreateSystemDefaultDevice())
//}

//==--==--==--==--==--==--==--==--==--===--==--==--==--==--==--==--==--==--==--==--==--==--==
//--==--==--==--==--==--==--==--==--===--==--==--==--==--==--==--==--==--==--==--==--==--==--
//==--==--==--==--==--==--==--==--==--===--==--==--==--==--==--==--==--==--==--==--==--==--==
//--==--==--==--==--==--==--==--==--===--==--==--==--==--==--==--==--==--==--==--==--==--==--
//==--==--==--==--==--==--==--==--==--===--==--==--==--==--==--==--==--==--==--==--==--==--==

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

extension NSView {
    var backgroundColor:Color { get { return NSColor.red } set {}  }
    var clearsContextBeforeDrawing:Bool { get { return false} set {}  }
    public func setNeedsDisplay() {
        draw(frame)
    }
}
public func liveWidth() -> CGFloat {
    return 500
}
public func liveHeight() -> CGFloat {
    return liveWidth()
}
class MouseDetector:NSView {
    var superThing:GridHolder?
    public override func mouseDown(with event: NSEvent) {
        if let above = superThing {
            above.click(pos: event.locationInWindow)
        }
    }
}
public class GridHolder:ViewController {
    public var grid:GridView
    public var waterDelegate:WatercolorSimulation?
    public init () {
        grid = GridView(size: liveHeight())
        grid.translatesAutoresizingMaskIntoConstraints  = false
        super.init(nibName: nil, bundle: nil)
        view = MouseDetector(frame: Rect(x: 0, y: 0, width: liveWidth(), height: liveHeight()))
        if let detector = view as? MouseDetector {
            detector.superThing = self
        }
        view.addSubview(grid)
    }

    public func click(pos: Point) {
        var location = pos
        if let view = grid.imageView {
            location.x -= view.frame.minX
            location.y -= view.frame.minY
            location.x /= view.frame.width
            location.y /= view.frame.height
            location.x *= 2
            location.y *= 2
            location.x -= 1
            location.y -= 1
            if let splotch = waterDelegate {
                splotch.paintSplatter(pos: location)
            }
        }
    }
    public override func viewWillAppear() {
        let size = min(liveWidth(), liveHeight())
        view.frame = Rect(x: 0, y: 0, width: liveWidth(), height: liveHeight())

        let center = Point(x: view.frame.width / 2, y: view.frame.height / 2)

        grid.frame = Rect(x: center.x - (size / 2), y: center.y - (size / 2), width: size, height: size)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func view(image: Image) {
        grid.view(image: image)
    }
    public func gridOff() {
        grid.gridOff()
    }
    public func gridOn() {
        grid.gridOn()
    }
}
extension GridView {
    public func updateImageFrame(img: Image, origin: Point, size: Size, length: CGFloat, majorThick: CGFloat) {
        if (grid) {
            var ypos = origin.y
            if (compat_yScalar == -1) {
                ypos = size.height - origin.y - (length + majorThick / 2)
            }
            imageView!.frame = Rect(x: origin.x, y: ypos, width: length + (majorThick / 2), height: length + (majorThick / 2))
        } else {
            let padding:CGFloat = 10
            let size = frame.width - 2.0 * padding
            imageView!.frame = Rect(x: (frame.width * 0.5 + frame.minX) - size * 0.5, y: (frame.height * 0.5 + frame.minY) - size * 0.5, width: size, height: size)
        }
        imageView!.layer = CALayer()
        imageView!.layer!.contentsGravity = kCAGravityResizeAspectFill
        imageView!.layer!.contents = img
        imageView!.wantsLayer = true
    }
}
extension NSImage {
    public var CGImage: CGImage {
        get {
            var imageRect:CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            //gImage(forProposedRect:context:hints:)
            return cgImage(forProposedRect: &imageRect, context: nil, hints: nil)!
        }
    }
}
extension TextureTools {
    public static func loadTexture(image: NSImage) -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: metalState.sharedDevice!)

        let options = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.renderTarget.rawValue),
            MTKTextureLoader.Option.SRGB: false
        ]

        return ensure(try textureLoader.newTexture(cgImage: image.CGImage, options: options))
    }
}
extension Image {
    public convenience init?(named: String) {
       self.init(named: NSImage.Name(named))
    }
}
extension Color {
    public convenience init (r:CGFloat, g:CGFloat, b:CGFloat) {
        self.init(srgbRed: r, green: g, blue: b, alpha: 1)
    }
}
func getHighPoweredDev() -> MTLDevice {
    var device:MTLDevice? = nil
    let devs = MTLCopyAllDevices()
    for d in devs {
        if (!d.isLowPower) {
            device = d
        }
    }
    if (device == nil) {
        device = ensure(MTLCreateSystemDefaultDevice())
    }
    return ensure(device)
}

