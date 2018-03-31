//  PlaygroundTools.swift
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb Kierum. All rights reserved.
//

import Metal
import MetalKit
import Foundation
import SpriteKit


public func playgroundError(message: String) {
    fatalError(message)
}

public func randomColor() -> Color {
    let x:CGFloat = Random.floatLinear(start: 0.0, end: 1.0)
    let y:CGFloat = Random.floatLinear(start: 0.0, end: 1.0)
    let time = Random.floatLinear(start: 0.0, end: 2.0 * 3.1415)
    
    let r:CGFloat = 0.5 + 0.5*cos(time + x)
    let g:CGFloat = 0.5 + 0.5*cos(time + 2 + y)
    let b:CGFloat = 0.5 + 0.5*cos(time + 4 + x)
    return Color(r: r, g: g, b: b)
}

public func ensure<T>(_ expr: @autoclosure () throws -> T?, orError message: @autoclosure () -> String = "Error") -> T
{
    do {
        if let result = try expr() { return result }
        else { print(message()) }
    }
    catch {
        print(message())
        print("error: \(error)")
    }
    fatalError("ISSUES")
}

public class TextureTools {
    public static func createTexture(ofSize size: CGFloat) -> MTLTexture {
        if (metalState.sharedDevice == nil) {
            playgroundError(message: "Must create a metal device before creating a texture")
        }
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(size), height: Int(size), mipmapped: false)
        let usage:MTLTextureUsage = [MTLTextureUsage.shaderWrite, MTLTextureUsage.shaderRead, MTLTextureUsage.renderTarget]
        descriptor.usage = usage
        return ensure(metalState.sharedDevice?.makeTexture(descriptor: descriptor))
    }
}


public class FPS {
    static var last:CFAbsoluteTime?
    public static func frame() -> Double {
        var delta:Double = 0
        let curr = CFAbsoluteTimeGetCurrent();
        if let l = last {
            delta = curr - l
            //print(delta)
        }
        last = curr
        return delta
    }
}
extension Point {
    public static func += (left: inout Point, right: Point) {
        left.x += right.x
        left.y += right.y
    }
    public mutating func rotate(_ by: CGFloat) {
        let sx = x
        let sy = y
        x = sx * cos(by) - sy * sin(by)
        y = sx * sin(by) + sy * cos(by)
    }
    
}
