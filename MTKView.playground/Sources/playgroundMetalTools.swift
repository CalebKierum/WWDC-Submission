//
//  TRASH.swift
//  MTKView
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb. All rights reserved.
//

import Foundation
import MetalKit
import simd
import Foundation
import CoreGraphics
import MetalKit
import Accelerate

//TO SWITCH! Switch typedefs uncomment line in display in playground and sync texture

//public typealias Color = UIColor //NSColor
//public typealias Image = UIImage //NSImage
//public typealias Rect = CGRect //NSRect
//public typealias View = UIView //NSView
//public typealias ImageView = UIImageView //NSImageView
//public typealias Size = CGSize
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


public typealias Color = NSColor
public typealias Image = NSImage
public typealias Rect = NSRect
public typealias View = NSView
public typealias ImageView = NSImageView
public typealias Size = NSSize
extension CIColor {
    static func convert(color: NSColor) -> CIColor {
        return CIColor(color: color)!
    }
 }





public class Settings {
    public static var sampleCount:Int = 2
    public static var colorFormat:MTLPixelFormat = .rgba8Unorm
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
public func playgroundError(message: String) {
    print(message)
}

enum States {
    case Idle
    case Preparing
    case Rendering
    case Computing
}

struct Vertex {
    var position:vector_float4
    var color:vector_float4
}

public class VertexBufferCreator {
    private var data:[Vertex] = []
    
    public init() {
        
    }
    
    public func addVertex(x: Float, y: Float) {
        addVertex(x: x, y: y, color: CIColor(red: 1, green: 1, blue: 1, alpha: 1))
    }
    public func addVertex(x: Float, y: Float, color: Color) {
        addVertex(x: x, y: y, color: CIColor.convert(color: color))
    }
    public func addVertex(x: Float, y: Float, color: CIColor) {
        data.append(Vertex(position: vector_float4(x, y, 0.0, 1.0), color: vector_float4(Float(color.red), Float(color.green), Float(color.blue), Float(color.alpha))))
    }
    public func getBufferObject() -> MTLBuffer {
        if (playgroundMetal.sharedDevice == nil) {
            playgroundError(message: "Must create a metal device before creating a point buffer")
        }
        let size = data.count * MemoryLayout.size(ofValue: data[0])
        return ensure(playgroundMetal.sharedDevice?.makeBuffer(bytes: data, length: size, options: [MTLResourceOptions.storageModeShared]))
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
        guard let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                      space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return nil }
        guard let cgImage = context.makeImage() else { return nil }
        
        
        return Image(cgImage: cgImage, size: Size(width: width, height: height))
    }
}
public class TextureTools {
    public static func createTexture(ofSize size: CGSize) -> MTLTexture {
        if (playgroundMetal.sharedDevice == nil) {
            playgroundError(message: "Must create a metal device before creating a texture")
        }
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(size.width), height: Int(size.height), mipmapped: false)
        let usage:MTLTextureUsage = [MTLTextureUsage.shaderWrite, MTLTextureUsage.shaderRead, MTLTextureUsage.renderTarget]
        descriptor.usage = usage
        return ensure(playgroundMetal.sharedDevice?.makeTexture(descriptor: descriptor))
    }
}

public class playgroundMetal:View {
    private var device:MTLDevice? = nil
    private var queue:MTLCommandQueue? = nil
    private var state:States = .Idle
    private var buffer:MTLCommandBuffer? = nil
    private var drawable:MTLTexture? = nil
    private var clear:MTLClearColor = MTLClearColorMake(0, 0, 0, 1.0)
    private var dimensions:Rect? = nil
    private var defaultRenderPassDescriptor:MTLRenderPassDescriptor? = nil
    internal static var sharedDevice:MTLDevice? = nil
    private var viewer:ImageView? = nil
    private var shouldDrawBlank:Bool = true
    
    
    public override init (frame: Rect) {
        dimensions = frame
        super.init(frame: frame)
        viewer = ImageView(frame: Rect(x: 0, y: 0, width: frame.width, height: frame.height))
        viewer!.translatesAutoresizingMaskIntoConstraints = false
        addSubview(viewer!)
        device = ensure(MTLCreateSystemDefaultDevice())
        playgroundMetal.sharedDevice = device
        drawable = TextureTools.createTexture(ofSize: CGSize(width: frame.width, height: frame.height))
        defaultRenderPassDescriptor = renderPassDescriptor()
        queue = device?.makeCommandQueue()
    }
    private func renderPassDescriptor() -> MTLRenderPassDescriptor {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = drawable
        descriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
        descriptor.colorAttachments[0].storeAction = MTLStoreAction.store
        descriptor.colorAttachments[0].clearColor = clear
        return descriptor
    }
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    public func setBackground(color: Color) {
        let intermediate = CIColor.convert(color: color)
        clear = MTLClearColor(red: Double(intermediate.red), green: Double(intermediate.green), blue: Double(intermediate.blue), alpha: 1.0)
        defaultRenderPassDescriptor = renderPassDescriptor()
    }
    public func compileShader(named: String) -> MTLFunction {
        let shader = ensure(try String(contentsOf: #fileLiteral(resourceName: "Shaders.metal")))
        let library = ensure(try device?.makeLibrary(source: shader, options: nil))
        //let library = ensure(device?.makeDefaultLibrary())
        return ensure(library.makeFunction(name: named))
    }
    public func createComputePipeline(function: MTLFunction) -> MTLComputePipelineState {
        return ensure(try device?.makeComputePipelineState(function: function))
    }
    public func createRenderPipeline(vertex: MTLFunction, fragment: MTLFunction) -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.sampleCount = Settings.sampleCount
        pipelineDescriptor.vertexFunction = vertex
        pipelineDescriptor.fragmentFunction = fragment
        
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = Settings.colorFormat
        
        return ensure(try device?.makeRenderPipelineState(descriptor: pipelineDescriptor))
    }
    
    public func prepareFrame() {
        if (state != .Idle) {
            playgroundError(message: "Invalid Command! Must be idle current state is \(state)")
        }
        state = .Preparing
        shouldDrawBlank = true
        buffer = ensure(queue?.makeCommandBuffer())
    }
    public func getRenderEncoder() -> MTLRenderCommandEncoder {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        shouldDrawBlank = false
        state = .Rendering
        return ensure(buffer?.makeRenderCommandEncoder(descriptor: defaultRenderPassDescriptor!))
    }
    public func finishEncoding(encoder: MTLRenderCommandEncoder) {
        if (state != .Rendering) {
            playgroundError(message: "Invalid Command! Must be rendering current state is \(state)")
        }
        encoder.endEncoding()
        state = .Preparing
    }
    public func finishEncoding(encoder: MTLComputeCommandEncoder) {
        if (state != .Computing) {
            playgroundError(message: "Invalid Command! Must be computing current state is \(state)")
        }
        encoder.endEncoding()
        state = .Preparing
    }
    public func getComputeEncoder() -> MTLComputeCommandEncoder {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        state = .Computing
        return ensure(buffer?.makeComputeCommandEncoder())
    }
    
    public func finishFrame() {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        if (shouldDrawBlank) {
            finishEncoding(encoder: getRenderEncoder())
        }
        let syncEncoder = buffer?.makeBlitCommandEncoder()!
        syncEncoder?.synchronize(resource: drawable!)
        syncEncoder?.endEncoding()
        buffer?.commit()
        buffer?.waitUntilCompleted()
        state = .Idle
        viewDrawable()
    }
    private func viewDrawable() {
        viewer?.image = drawable?.displayInPlayground()
    }
    
    func debug() -> MTLTexture {
        return ensure(drawable)
    }
}

func createGrid() -> View? {
    return nil
}
