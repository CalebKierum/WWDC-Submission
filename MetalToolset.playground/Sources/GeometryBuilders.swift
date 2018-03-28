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

public class GeometryCreator {
    public static func square(center: Point, width: CGFloat, rotation: CGFloat = 0, color: Color = Color.red) -> VertexBufferCreator {
        return GeometryCreator.rectangle(center: center, width: width, height: width, rotation: rotation, color: color)
    }
    public static func circle(center: Point, radius: CGFloat, color: Color = Color.red) -> VertexBufferCreator {
        let data = VertexBufferCreator()
        
        let resolution:Int = 100
        for i in 1...resolution {
            let prog = CGFloat(i) / CGFloat(resolution)
            let prog2 = CGFloat(i + 1) / CGFloat(resolution)
            let twoPI:CGFloat = 2 * 3.141592
            let theta1 = prog * twoPI
            let theta2 = prog2 * twoPI
            data.addVertex(x: Float(cos(theta1) * radius + center.x), y: Float(sin(theta1) * radius + center.y), color: color)
            data.addVertex(x: Float(cos(theta2) * radius + center.x), y: Float(sin(theta2) * radius + center.y), color: color)
            data.addVertex(point: center, color: color)
        }
        return data
    }
    public static func line(from: Point, to: Point, width: CGFloat, color: Color = Color.red) -> VertexBufferCreator {
        let dx = to.x - from.x
        let dy = to.y - from.y
        return GeometryCreator.rectangle(center: Point(x: (from.x + to.x) / 2.0, y: (from.y + to.y) / 2.0), width: sqrt(dx * dx + dy * dy), height: width, rotation: atan2(dy, dx), color: color)
    }
    public static func rectangle(center: Point, width: CGFloat, height: CGFloat, rotation: CGFloat = 0, color: Color = Color.red) -> VertexBufferCreator{
        let data = VertexBufferCreator()
        //Spawns 6 points based on the 4 parts that this could be at
        var tl = Point(x: -width / 2.0, y: height / 2.0)
        var tr = Point(x: width / 2.0, y: height / 2.0)
        var bl = Point(x: -width / 2.0, y: -height / 2.0)
        var br = Point(x: width / 2.0, y: -height / 2.0)
        tl.rotate(rotation)
        tr.rotate(rotation)
        bl.rotate(rotation)
        br.rotate(rotation)
        tl += center
        tr += center
        bl += center
        br += center
        
        data.addVertex(point: bl, color: color)
        data.addVertex(point: br, color: color)
        data.addVertex(point: tr, color: color)
        data.addVertex(point: bl, color: color)
        data.addVertex(point: tr, color: color)
        data.addVertex(point: tl, color: color)
        
        return data
    }
}

public class VertexBufferCreator {
    private var data:[Vertex] = []
    
    public init() {
        
    }
    
    public func addVertex(point: Point, color: Color) {
        addVertex(x: Float(point.x), y: Float(point.y), color: color)
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
    public func getVertexCount() -> Int {
        return data.count
    }
}
