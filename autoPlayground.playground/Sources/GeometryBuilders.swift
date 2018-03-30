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
    public static func splat(center: Point, color: Color = Color.red) -> VertexBufferCreator {
        let buffer = VertexBufferCreator()
        
        let major = true
        let bounded = true
        let orbiters = true
        let spinoffs = true
        let random = true
        let lines = true
        let cap = true
        
        //Should be how much the frame it keeps up
        let spaceScalar:CGFloat = 1
        
        //Scalars for the main blob
        let practicalScalar = SlotContants.totalScale * spaceScalar
        
        
        if (major) {
            //Central ball
            let majorSize = Random.floatBiasHigh(factor: 4, start: SlotContants.majorLow, end: 1.0) * practicalScalar
            
            //-Bounded
            if (bounded) {
                let count = Random.int(start: 1, end: 8)
                for _ in 0..<count {
                    let size = Random.floatLinear(start: majorSize * 0.4, end: majorSize * 0.7)
                    var displacement = Random.floatLinear(start: majorSize * 0.6, end: majorSize * 0.8)
                    let theta = Random.randomRadian()
                    
                    displacement *= SlotContants.displacementScalar
                    
                    var point = Point(x: cos(theta) * displacement, y: sin(theta) * displacement)
                    point += center
                    
                    buffer.addCircle(center: point, radius: size * SlotContants.sizeScalar * 0.7, color: color)
                }
            }
            
            //-Orbiters
            if (orbiters) {
                let counter = Random.int(start: 2, end: 8)
                var theta = Random.randomRadian()
                for _ in 0..<counter {
                    let targetSize = majorSize / 3.5
                    
                    let scalar = Random.floatLinear()
                    
                    if (spinoffs && (Random.floatLinear(start: scalar / 2, end: 1.0) > scalar)) {
                        let spinCount = Random.int(start: 1, end: 4)
                        for _ in 0..<spinCount {
                            let targetSize = majorSize / 1.5
                            let displacementScale = Random.floatLinear()
                            var displacement = majorSize + displacementScale * majorSize * 2
                            let size = Random.floatLinear(start: targetSize * 0.5, end: targetSize) * pow(1 - displacementScale, 3.0)
                            
                            let mag:CGFloat = (2.0 * 3.141592) / 52.0
                            let waver = Random.floatLinear(start: -mag, end: mag)
                            displacement *= SlotContants.displacementScalar
                            var point = Point(x: cos(theta + waver) * displacement, y: sin(theta + waver) * displacement)
                            point += center
                            
                            buffer.addCircle(center: point, radius: size * SlotContants.sizeScalar, color: color)
                        }
                    }
                    
                    let size = Random.putInRange(scalar, start: targetSize * 0.85, end: targetSize * 1.0)
                    theta += Random.randomRadian()
                    var displacement = Random.floatLinear(start: majorSize - size, end: majorSize * 1.1)
                    displacement *= SlotContants.displacementScalar
                    var point = Point(x: cos(theta) * displacement, y: sin(theta) * displacement)
                    point += center
                    
                    buffer.addCircle(center: point, radius: size * SlotContants.sizeScalar * 0.9, color: color)
                }
            }
            
            //-Random
            if (random) {
                let randomCount = Random.int(start: 6, end: 15)
                for _ in 0..<randomCount {
                    let scalar = Random.floatLinear()
                    var displacement = majorSize*1.4 + majorSize * 2.5 * scalar
                    let targetSize = practicalScalar / 8.2
                    let scale = targetSize * pow(1.0 - scalar, 1.2) * Random.floatLinear(start: 0.9, end: 1.0)
                    let theta = Random.randomRadian()
                    
                    displacement *= SlotContants.displacementScalar
                    var point = Point(x: cos(theta) * displacement, y: sin(theta) * displacement)
                    point += center
                    
                    buffer.addCircle(center: point, radius: scale * SlotContants.sizeScalar, color: color)
                }
            }
            
            //-Lines
            if (lines) {
                let count = Random.int(start: 1, end: 6)
                for _ in 0..<count {
                    let width = Random.floatBiasLow(factor: 1.2, start: practicalScalar * 0.12, end: practicalScalar * 0.13)
                    let length = Random.floatBiasLow(factor: 1.5, start: majorSize * 0.4, end: majorSize * 1.5)
                    let theta = Random.randomRadian()
                    
                    let core = majorSize * 0.5
                    var outset = majorSize + length
                    
                    var p1 = Point(x: cos(theta) * core, y: sin(theta) * core)
                    p1 += center
                    
                    outset *= SlotContants.displacementScalar
                    var p2 = Point(x: cos(theta) * outset, y: sin(theta) * outset * SlotContants.displacementScalar)
                    p2 += center
                    
                    
                    buffer.addLine(from: p1, to: p2, width: width * SlotContants.sizeScalar, color: color)
                    
                    
                    if (cap) {
                        let width = width * Random.floatLinear(start: 1.00, end: 1.1)
                        buffer.addCircle(center: p2, radius: width * SlotContants.sizeScalar, color: color)
                    }
                }
            }
            
            buffer.addCircle(center: center, radius: majorSize  * SlotContants.sizeScalar * 1.1, color: color)
        }
        return buffer
    }
    
    public static func square(center: Point, width: CGFloat, rotation: CGFloat = 0, color: Color = Color.red) -> VertexBufferCreator {
        return GeometryCreator.rectangle(center: center, width: width, height: width, rotation: rotation, color: color)
    }
    public static func circle(center: Point, radius: CGFloat, color: Color = Color.red) -> VertexBufferCreator {
        
        let data = VertexBufferCreator()
        if (!radius.isNaN) {
            let resolution:Int = Int(20 * radius)+10
            
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
    
    public func addSquare(center: Point, width: CGFloat, rotation: CGFloat = 0, color: Color = Color.red) {
        let add = GeometryCreator.square(center: center, width: width, rotation: rotation, color: color)
        for v in add.data {
            data.append(v)
        }
    }
    
    public func addCircle(center: Point, radius: CGFloat, color: Color = Color.red) {
        let add = GeometryCreator.circle(center: center, radius: radius, color: color)
        for v in add.data {
            data.append(v)
        }
    }
    
    public func addLine(from: Point, to: Point, width: CGFloat, color: Color = Color.red) {
        let add = GeometryCreator.line(from: from, to: to, width: width, color: color)
        for v in add.data {
            data.append(v)
        }
    }
    
    public func addRectangle(center: Point, width: CGFloat, height: CGFloat, rotation: CGFloat = 0, color: Color = Color.red) {
        let add = GeometryCreator.rectangle(center: center, width: width, height: height, rotation: rotation, color: color)
        for v in add.data {
            data.append(v)
        }
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
        if (metalState.sharedDevice == nil) {
            playgroundError(message: "Must create a metal device before creating a point buffer")
        }
        let size = data.count * MemoryLayout.size(ofValue: data[0])
        return ensure(metalState.sharedDevice?.makeBuffer(bytes: data, length: size, options: [MTLResourceOptions.storageModeShared]))
    }
    public func getVertexCount() -> Int {
        return data.count
    }
}
