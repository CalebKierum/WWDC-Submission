//: Playground - noun: a place where people can play

import PlaygroundSupport
import Cocoa
import Foundation
import CoreGraphics
import MetalKit
import Accelerate


extension MTLTexture {
    
    func bytes() -> UnsafeMutableRawPointer {
        let width = self.width
        let height   = self.height
        let rowBytes = self.width * 4
        let p = UnsafeMutableRawPointer.allocate(bytes: width * height * 4, alignedTo: 0)
        
        self.getBytes(p, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        return p
    }
    func anythingHere() -> Bool {
        let texture = self
        let width = texture.width
        let height = texture.height
        let bytesPerRow = width * 4
        
        let data = UnsafeMutableRawPointer.allocate(bytes: bytesPerRow * height, alignedTo: 4)
        defer {
            data.deallocate(bytes: bytesPerRow * height, alignedTo: 4)
        }
        
        let region = MTLRegionMake2D(0, 0, width, height)
        texture.getBytes(data, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        var bind = data.assumingMemoryBound(to: UInt8.self)
        
        var bind2 = data.assumingMemoryBound(to: UInt8.self)
        var message = ""
        for _ in 0..<4 {
            message += " " + String(describing: bind2.pointee)
            bind2 = bind2.advanced(by: 1)
        }
        print(message)
        
        for _ in 0..<bytesPerRow * height {
            if bind.pointee != 0 {
                return true
            }
            bind = bind.advanced(by: 1)
        }
        return false
    }
    func toImage() -> NSImage? {
        let texture = self
        let width = texture.width
        let height = texture.height
        let bytesPerRow = width * 4
        
        let data = UnsafeMutableRawPointer.allocate(bytes: bytesPerRow * height, alignedTo: 4)
        defer {
            data.deallocate(bytes: bytesPerRow * height, alignedTo: 4)
        }
        
        let region = MTLRegionMake2D(0, 0, width, height)
        texture.getBytes(data, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        var buffer = vImage_Buffer(data: data, height: UInt(height), width: UInt(width), rowBytes: bytesPerRow)
        
        let map: [UInt8] = [2, 1, 0, 3]
        vImagePermuteChannels_ARGB8888(&buffer, &buffer, map, 0)
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear) else { return nil }
        guard let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                      space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return nil }
        guard let cgImage = context.makeImage() else { return nil }
        
        
        return NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
    }
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
    PlaygroundPage.current.finishExecution()
}


public struct ThreadgroupSizes
{
    var threadsPerThreadgroup: MTLSize
    var threadgroupsPerGrid: MTLSize
    
    public static let zeros = ThreadgroupSizes(
        threadsPerThreadgroup: MTLSize(),
        threadgroupsPerGrid: MTLSize())
}

//Setup the view
var view = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
PlaygroundPage.current.liveView = view
//PlaygroundPage.current.needsIndefiniteExecution = true

//Prepare the levels of encoding
let device = ensure(MTLCreateSystemDefaultDevice(), orError: "Couldnt initialize metal")
let queue = ensure(device.makeCommandQueue())
let buffer = ensure(queue.makeCommandBuffer())
let encoder = ensure(buffer.makeComputeCommandEncoder())

//Load the shader and make a compute state for it
let shader = ensure(try String.init(contentsOf:  #fileLiteral(resourceName: "Shaders.metal")), orError: "Couldnt read shader")
let library = ensure(try device.makeLibrary(source: shader, options: nil), orError: "Could not compile shader")
let green = ensure(library.makeFunction(name: "green"), orError: "Couldnt compile")
let greenPipeline = ensure(try device.makeComputePipelineState(function: green))

//Create our texture
let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 100, height: 100, mipmapped: false)
let usage:MTLTextureUsage = [MTLTextureUsage.shaderWrite, MTLTextureUsage.shaderRead]
descriptor.usage = usage
let texture = ensure(device.makeTexture(descriptor: descriptor))
let tex = texture.toImage()!
print(texture.anythingHere())

//GO!
print("GO")
encoder.setComputePipelineState(greenPipeline)
encoder.setTexture(texture, index: 0)
let w = greenPipeline.threadExecutionWidth
let h = greenPipeline.maxTotalThreadsPerThreadgroup / w
let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
let threadgroupsPerGrid = MTLSize(width: (texture.width + w - 1) / w,
                                  height: (texture.height + h - 1) / h,
                                  depth: 1)
encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
encoder.endEncoding()

let syncEncoder = buffer.makeBlitCommandEncoder()!
syncEncoder.synchronize(resource: texture)
syncEncoder.endEncoding()

buffer.commit()
buffer.waitUntilCompleted()


let tex2 = texture.toImage()!
print(texture.anythingHere())

//Debug pixel


print("Successsss")

/*
PlaygroundPage.current.liveView = view

Playground
let shaderSource = ensure(try String(contentsOf:playgroundSharedDataDirectory.appendingPathComponent("Shaders.metal")), orError: "unable to read shader source file")

let device = ensure(MTLCreateSystemDefaultDevice(), orError: "Couldnt create metal device")
let library = ensure(try device.makeLibrary(source: shaderSource, options: nil),
                      orError: "compiling shaders failed")


*/
