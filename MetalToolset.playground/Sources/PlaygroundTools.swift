//  PlaygroundTools.swift
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb Kierum. All rights reserved.
//

import Metal
import Accelerate

public func playgroundError(message: String) {
    print(message)
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
    public static func createTexture(ofSize size: CGSize) -> MTLTexture {
        if (playgroundMetalView.sharedDevice == nil) {
            playgroundError(message: "Must create a metal device before creating a texture")
        }
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(size.width), height: Int(size.height), mipmapped: false)
        let usage:MTLTextureUsage = [MTLTextureUsage.shaderWrite, MTLTextureUsage.shaderRead, MTLTextureUsage.renderTarget]
        descriptor.usage = usage
        return ensure(playgroundMetalView.sharedDevice?.makeTexture(descriptor: descriptor))
    }
}

public extension MTLTexture {
    func displayInPlayground() -> Image? {
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
        
        let map: [UInt8] = [0, 1, 2, 3]
        vImagePermuteChannels_ARGB8888(&buffer, &buffer, map, 0)
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear) else { return nil }
        guard let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return nil }
        guard let cgImage = context.makeImage() else { return nil }
        
        return Image(cgImage: cgImage, size: Size(width: width, height: height))
    }
}
