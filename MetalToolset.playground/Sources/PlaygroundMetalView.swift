//  PlaygroundMetalView.swift
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb Kierum. All rights reserved.
//

import Metal
import MetalKit

enum States {
    case Idle
    case Preparing
    case Rendering
    case Computing
}

public class playgroundMetalView:View {
    private var device:MTLDevice? = nil
    private var queue:MTLCommandQueue? = nil
    private var state:States = .Idle
    private var buffer:MTLCommandBuffer? = nil
    public var drawable:MTLTexture? = nil
    private var clear:MTLClearColor = MTLClearColorMake(0, 0, 0, 1.0)
    private var dimensions:Rect? = nil
    private var defaultRenderPassDescriptor:MTLRenderPassDescriptor? = nil
    internal static var sharedDevice:MTLDevice? = nil
    private var shouldDrawBlank:Bool = true
    
    
    public init (size: CGFloat) {
        let frame = Rect(x: 0, y: 0, width: size, height: size)
        dimensions = frame
        super.init(frame: frame)
        device = ensure(MTLCreateSystemDefaultDevice())
        playgroundMetalView.sharedDevice = device
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
        synchronize(texture: drawable!, buffer: buffer!)
        buffer?.commit()
        buffer?.waitUntilCompleted()
        state = .Idle
        viewDrawable()
    }
    private func viewDrawable() {
        updateViewer()
    }
    
    func debug() -> MTLTexture {
        return ensure(drawable)
    }
    
    var viewLayer:CALayer?
}

