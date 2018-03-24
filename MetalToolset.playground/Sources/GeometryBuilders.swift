//  GeometryBuilders.swift
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb Kierum. All rights reserved.
//

import Metal
import MetalKit


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
        if (playgroundMetalView.sharedDevice == nil) {
            playgroundError(message: "Must create a metal device before creating a point buffer")
        }
        let size = data.count * MemoryLayout.size(ofValue: data[0])
        return ensure(playgroundMetalView.sharedDevice?.makeBuffer(bytes: data, length: size, options: [MTLResourceOptions.storageModeShared]))
    }
}
