//  PlaygroundMetalView.swift
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb Kierum. All rights reserved.
//

import Metal
import MetalKit
import MetalPerformanceShaders

enum States {
    case Idle
    case Preparing
    case Rendering
    case Computing
}

public class metalState {
    private var device:MTLDevice? = nil
    private var queue:MTLCommandQueue? = nil
    private var state:States = .Idle
    private var buffer:MTLCommandBuffer? = nil
    private var clear:MTLClearColor = MTLClearColorMake(0, 0, 0, 1.0)
    internal static var sharedDevice:MTLDevice? = nil
    private var shouldDrawBlank:Bool = true
    public var drawable:MTLTexture? = nil
    
    public init () {
        device = ensure(MTLCreateSystemDefaultDevice())
        metalState.sharedDevice = device
        queue = device?.makeCommandQueue()
    }
    private func renderPassDescriptor() -> MTLRenderPassDescriptor? {
        if let draw = drawable {
            let descriptor = MTLRenderPassDescriptor()
            descriptor.colorAttachments[0].texture = draw
            descriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
            descriptor.colorAttachments[0].storeAction = MTLStoreAction.store
            descriptor.colorAttachments[0].clearColor = clear
            return descriptor
        }
        return nil
    }
    public func setBackground(color: Color) {
        let intermediate = CIColor.convert(color: color)
        clear = MTLClearColor(red: Double(intermediate.red), green: Double(intermediate.green), blue: Double(intermediate.blue), alpha: 1.0)
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
    public func getRenderEncoderFor(texture: MTLTexture) -> MTLRenderCommandEncoder {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        shouldDrawBlank = false
        state = .Rendering
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = texture
        descriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
        descriptor.colorAttachments[0].storeAction = MTLStoreAction.store
        descriptor.colorAttachments[0].clearColor = clear
        return ensure(buffer?.makeRenderCommandEncoder(descriptor: descriptor))
    }
    public func getDefaultRenderEncoder() -> MTLRenderCommandEncoder {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        if let desc = renderPassDescriptor() {
            shouldDrawBlank = false
            state = .Rendering
            return ensure(buffer?.makeRenderCommandEncoder(descriptor: desc))
        } else {
            playgroundError(message: "You must have a drawable to draw to for a render command encoder")
        }
        fatalError("Error")
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
    public func blur(texture passIn: MTLTexture, ammount: CGFloat) {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        let screenUnits = (ammount / (2.0 * 10.0)) * CGFloat(passIn.width)
        let kernel = MPSImageGaussianBlur(device: device!, sigma: Float(screenUnits))
        
        // not the safest way, but it works for brevity's sake
        var texture: MTLTexture = passIn
        kernel.encode(commandBuffer: buffer!, inPlaceTexture: &texture, fallbackCopyAllocator: nil)
    }
    public func finishFrame() {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        if (shouldDrawBlank) {
            finishEncoding(encoder: getDefaultRenderEncoder())
        }
        synchronize(texture: drawable!, buffer: buffer!)
        buffer?.commit()
        buffer?.waitUntilCompleted()
        state = .Idle
    }
}

