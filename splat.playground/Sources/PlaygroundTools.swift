//  PlaygroundTools.swift
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb Kierum. All rights reserved.
//

import Metal
import MetalKit
import Foundation
import SpriteKit
import PlaygroundSupport


public func playgroundError(message: String) {
    fatalError(message)
}

/*
public func randomColor() -> Color {
    let x:CGFloat = Random.floatLinear(start: 0.0, end: 1.0)
    let y:CGFloat = Random.floatLinear(start: 0.0, end: 1.0)
    let time = Random.floatLinear(start: 0.0, end: 2.0 * 3.1415)
    
    let r:CGFloat = 0.5 + 0.5*cos(time + x)
    let g:CGFloat = 0.5 + 0.5*cos(time + 2 + y)
    let b:CGFloat = 0.5 + 0.5*cos(time + 4 + x)
    return Color(r: r, g: g, b: b)
}*/
/*float palette( in float a, in float b, in float c, in float d, in float x ) {
    return 0.5 + 0.5 * cos(6.28318 * (1.0 * x + d));
}*/
func helper(x: CGFloat, d: CGFloat) -> CGFloat {
    return 0.5 + 0.5 * cos(6.28318 * (1.0 * x + d));
}
var x:CGFloat = 0
public func randomColor() -> Color {
    //d=0, 0.33, 0.67 random 0-1
   // let x = Random.floatLinear(start: 0, end: 2)
    x += Random.floatLinear(start: 0.05, end: 0.12)
    let r:CGFloat = helper(x: x, d: 0)
    let g:CGFloat = helper(x: x, d: 0.33)
    let b:CGFloat = helper(x: x, d: 0.67)
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
    fatalError(message)
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
public func executeContinuously(block: @escaping () -> Void) {
    PlaygroundPage.current.needsIndefiniteExecution = true
    let date = Date()
    let copy = block
    var count = 0
    let timer2 = Timer(fire: date, interval: 1.0 / 15.0, repeats: true, block: { _ in
        count += 1
        if (count < 2500) {
            copy()
        } else {
            PlaygroundPage.current.finishExecution()
        }
    })
    RunLoop.main.add(timer2, forMode: RunLoopMode.commonModes)
}
