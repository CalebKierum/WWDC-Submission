//  PlaygroundMetalView.swift
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb Kierum. All rights reserved.
//

import Metal
import MetalKit
import MetalPerformanceShaders

public enum States {
    case Idle
    case Preparing
    case Rendering
    case Computing
}

public class metalState {
    public var device:MTLDevice? = nil
    private var queue:MTLCommandQueue? = nil
    private var state:States = .Idle
    private var buffer:MTLCommandBuffer? = nil
    private var clear:MTLClearColor = MTLClearColorMake(0, 0, 0, 1.0)
    public static var sharedDevice:MTLDevice? = nil
    private var shouldDrawBlank:Bool = true
    private var drawable:MTLTexture?
    
    private var synchronizeList:[MTLTexture] = []
    
    public init () {
        device = getHighPoweredDev()
        metalState.sharedDevice = device
        queue = device?.makeCommandQueue()
    }
    public func getState() -> States{
        return state
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
    public func setDrawable(to: MTLTexture) {
        if let d = drawable {
            synchronizeList.append(d)
        }
        drawable = to
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
    public func getRenderEncoder() -> MTLRenderCommandEncoder {
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
    public func combine(blurred: MTLTexture, weight w1: Float, noise: MTLTexture, weight w2: Float, color: Color, onto: MTLTexture? = nil) -> MTLTexture {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        
        let cvertex = compileShader(named: "vertex_copy")
        let cfragment = compileShader(named: "fragment_copy")
        let cpipeline = createRenderPipeline(vertex: cvertex, fragment: cfragment)
        var ctex:MTLTexture!
        if let t = onto {
            ctex = t
        } else {
            ctex = TextureTools.createTexture(ofSize: CGFloat(max(blurred.width, noise.width)))
        }
        setDrawable(to: ctex)
        let render = getRenderEncoder()
        render.setRenderPipelineState(cpipeline)
        render.setFragmentTexture(blurred, index: 0)
        render.setFragmentTexture(noise, index: 1)
        
        var c_weight1 = w1
        var c_weight2 = w2
        let intermediate = CIColor.convert(color: color)
        var color:float3 = float3(Float(intermediate.red), Float(intermediate.green), Float(intermediate.blue))
        render.setFragmentBytes(&c_weight1, length: MemoryLayout<Float>.stride, index: 0)
        render.setFragmentBytes(&c_weight2, length: MemoryLayout<Float>.stride, index: 1)
        render.setFragmentBytes(&color, length: MemoryLayout<float3>.stride, index: 2)
        
        render.drawFullScreen()
        finishEncoding(encoder: render)
        
        return ctex
    }
    public func viewAlpha(texture: MTLTexture, onto: MTLTexture) {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        shouldDrawBlank = false
        let cvertex = compileShader(named: "vertex_alpha")
        let cfragment = compileShader(named: "fragment_alpha")
        let cpipeline = createRenderPipeline(vertex: cvertex, fragment: cfragment)
        setDrawable(to: onto)
        let render = getRenderEncoder()
        render.setRenderPipelineState(cpipeline)
        render.setFragmentTexture(texture, index: 0)
        render.drawFullScreen()
        finishEncoding(encoder: render)
    }
    public func clamp(texture: inout MTLTexture, wall: CGFloat, tolerance: CGFloat, onto: MTLTexture? = nil) {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        
        let cvertex = compileShader(named: "vertex_clamp")
        let cfragment = compileShader(named: "fragment_clamp")
        let cpipeline = createRenderPipeline(vertex: cvertex, fragment: cfragment)
        var clamped:MTLTexture!
        if let t = onto {
            clamped = t
        } else {
            clamped = TextureTools.createTexture(ofSize: CGFloat(max(texture.width, texture.width)))
        }
        setDrawable(to: clamped)
        let render2 = getRenderEncoder()
        render2.setRenderPipelineState(cpipeline)
        var wall:Float = Float(wall)
        var tolerance:Float = Float(tolerance)
        render2.setFragmentBytes(&wall, length: MemoryLayout<Float>.stride, index: 0)
        render2.setFragmentBytes(&tolerance, length: MemoryLayout<Float>.stride, index: 1)
        render2.setFragmentTexture(texture, index: 0)
        render2.drawFullScreen()
        finishEncoding(encoder: render2)
        
        texture = clamped
    }
    public func draw(geometry: VertexBufferCreator, to: MTLTexture) {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        
        let vertex = compileShader(named: "vertexShader")
        let fragment = compileShader(named: "fragmentShader")
        setDrawable(to: to)
        let pipeline = createRenderPipeline(vertex: vertex, fragment: fragment)
        let render =  getRenderEncoder()
        render.setRenderPipelineState(pipeline)
        render.drawTriangles(buffer: geometry)
        finishEncoding(encoder: render)
    }
    public func finishFrame() {
        if (state != .Preparing) {
            playgroundError(message: "Invalid Command! Must be preparing current state is \(state)")
        }
        if (shouldDrawBlank) {
            finishEncoding(encoder: getRenderEncoder())
        }
        for tex in synchronizeList {
            synchronize(texture: tex, buffer: buffer!)
        }
        synchronizeList = []
        synchronize(texture: drawable!, buffer: buffer!)
        buffer?.commit()
        buffer?.waitUntilCompleted()
        state = .Idle
    }
}

