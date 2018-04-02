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

/*
    The purpose of this class is to provide small tools usefull to the playground as a whole
 */

//Reports an error and finishes the playgrounds execution preventing further errors
public func playgroundError(message: String) {
    print(message)
    PlaygroundPage.current.finishExecution()
}


//Gets a random color on the rainbow
var x:CGFloat = 0
public func randomColor() -> Color {
    func helper(x: CGFloat, d: CGFloat) -> CGFloat {
        return 0.5 + 0.5 * cos(6.28318 * (1.0 * x + d));
    }
    
    //Increase the x by a random amount moving it around the rainbow
    x += Random.floatLinear(start: 0.05, end: 0.12)
    let r:CGFloat = helper(x: x, d: 0)
    let g:CGFloat = helper(x: x, d: 0.33)
    let b:CGFloat = helper(x: x, d: 0.67)
    return Color(r: r, g: g, b: b)
}

//Ensures that the block does not throw an error or return nil otherwise exits the playground
public func ensure<T>(_ expr: @autoclosure () throws -> T?, orError message: @autoclosure () -> String = "Error") -> T
{
    do {
        if let result = try expr() { return result }
        else { print(message()) }
    }
    catch {
        print("error: \(error)" + message())
    }
    playgroundError(message: message())
    fatalError("Err")
}

//Some tools for creating textures
public class TextureTools {

    //Creates a square texture of the dimensions
    public static func createTexture(ofSize size: CGFloat) -> MTLTexture {
        if (metalState.sharedDevice == nil) {
            playgroundError(message: "Must create a metal device before creating a texture")
        }
        
        //Describve it with its hight and turn of mipmaps
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(size), height: Int(size), mipmapped: false)
        
        //Allow it to be used in all scenarios
        let usage:MTLTextureUsage = [MTLTextureUsage.shaderWrite, MTLTextureUsage.shaderRead, MTLTextureUsage.renderTarget]
        descriptor.usage = usage
        
        //Create it
        return ensure(metalState.sharedDevice?.makeTexture(descriptor: descriptor))
    }
    
    //Note: There is also a tool to load a texture from an Image but that is platform dependent and therefore is in the Compatability file
}

//Useful for estimating the framerate of the simulation
public class FPS {
    static var last:CFAbsoluteTime?
    
    //Call in your draw loop returns the delta time (framerate is 1 / dt)
    public static func frame() -> Double {
        var delta:Double = 0
        let curr = CFAbsoluteTimeGetCurrent();
        if let l = last {
            delta = curr - l
        }
        last = curr
        return delta
    }
}

//Extensions for points that allow for basic arithmetic
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

//Schedules a block to be run at 15fps or lower
public func executeContinuously(block: @escaping () -> Void) {
    //If we are going to do this then the playground has to continue running
    PlaygroundPage.current.needsIndefiniteExecution = true
    
    //Get the date and capture the block
    let date = Date()
    let copy = block
    
    //Simulation runs for about a minute
    var count = 0
    let timer2 = Timer(fire: date, interval: 1.0 / 15.0, repeats: true, block: { _ in
        count += 1
        if (count < 1000) {
            //Execute the block passed in
            copy()
        } else {
            PlaygroundPage.current.finishExecution()
        }
    })
    
    //Schedule it to be run on the runloop
    RunLoop.main.add(timer2, forMode: RunLoopMode.commonModes)
}
