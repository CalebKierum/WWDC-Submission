//: Playground - noun: a place where people can play

import PlaygroundSupport
import Foundation
import SpriteKit

let mtl = playgroundMetalView(size: 300.0)

let buffer = VertexBufferCreator()
buffer.addVertex(x: -1, y: -1, color: Color.purple)
buffer.addVertex(x: 0, y: 1, color: Color.green)
buffer.addVertex(x: 1, y: -1, color: Color.blue)
buffer.addVertex(x: 1, y: -1, color: Color.red)
buffer.addVertex(x: 1, y: 1, color: Color.green)
buffer.addVertex(x: 0, y: 1, color: Color.green)


buffer.addRectangle(center: Point(x: 0.3, y: 0), width: 0.1, height: 0.3, rotation: 3.141592 * 0.25, color: Color.red)
buffer.addLine(from: Point(x: -0.5, y: 0.2), to: Point(x: 0.5, y: 0.0), width: 0.1, color: Color.red)
buffer.addSquare(center: Point(x: -0.5, y: -0.5), width: 1.0)
buffer.addCircle(center: Point(x: -0.5, y: 0.0), radius: 0.2, color: Color.yellow)

func createSplat(center: Point, color: Color = Color.red) -> VertexBufferCreator {
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
    let practicalScalar = 0.25 * spaceScalar
    
    
    if (major) {
        //Central ball
        let majorSize = Random.floatBiasHigh(factor: 4, start: 0.4, end: 1.0) * practicalScalar
        
        //-Bounded
        if (bounded) {
            let size = Random.floatLinear(start: majorSize * 0.4, end: majorSize * 0.7)
            let displacement = Random.floatLinear(start: majorSize * 0.6, end: majorSize * 0.8)
            let theta = Random.randomRadian()
            
            var point = Point(x: cos(theta) * displacement, y: sin(theta) * displacement)
            point += center
            
            buffer.addCircle(center: point, radius: size, color: color)
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
                        let targetSize = majorSize / 3.0
                        let displacementScale = Random.floatLinear()
                        let displacement = majorSize + displacementScale * majorSize * 2
                        let size = Random.floatLinear(start: targetSize * 0.5, end: targetSize) * pow(1 - displacementScale, 3.0)
                        
                        let mag:CGFloat = (2.0 * 3.141592) / 52.0
                        let waver = Random.floatLinear(start: -mag, end: mag)
                        var point = Point(x: cos(theta + waver) * displacement, y: sin(theta + waver) * displacement)
                        point += center
                        
                        buffer.addCircle(center: point, radius: size, color: color)
                    }
                }
                
                let size = Random.putInRange(scalar, start: targetSize * 0.85, end: targetSize * 1.0)
                theta += Random.randomRadian()
                let displacement = Random.floatLinear(start: majorSize - size, end: majorSize * 1.1)
                
                var point = Point(x: cos(theta) * displacement, y: sin(theta) * displacement)
                point += center
                
                buffer.addCircle(center: point, radius: size, color: color)
            }
        }
        
        //-Random
        if (random) {
            let randomCount = Random.int(start: 6, end: 13)
            for _ in 0..<randomCount {
                let scalar = Random.floatBiasLow(factor: 1.5)
                let displacement = majorSize*1.1 + majorSize * 2.5 * scalar
                let targetSize = practicalScalar / 10
                let scale = targetSize * pow(1.0 - scalar, 2.0) * Random.floatLinear(start: 0.9, end: 1.1)
                let theta = Random.randomRadian()
                
                var point = Point(x: cos(theta) * displacement, y: sin(theta) * displacement)
                point += center
                
                buffer.addCircle(center: point, radius: scale, color: color)
            }
        }
        
        //-Lines
        if (lines) {
            let count = Random.int(start: 1, end: 12)
            for _ in 0..<count {
                let width = Random.floatBiasLow(factor: 1.2, start: majorSize * 0.1, end: majorSize * 0.3)
                let length = Random.floatBiasLow(factor: 2.0, start: majorSize * 0.1, end: majorSize * 1.2)
                let theta = Random.randomRadian()
                
                let core = majorSize * 0.5
                let outset = majorSize + length
                
                var p1 = Point(x: cos(theta) * core, y: sin(theta) * core)
                p1 += center
                
                var p2 = Point(x: cos(theta) * outset, y: sin(theta) * outset)
                p2 += center
                
                buffer.addLine(from: p1, to: p2, width: width, color: color)
                
                
                if (cap) {
                    let width = width * Random.floatLinear(start: 1.2, end: 1.5)
                    buffer.addCircle(center: p2, radius: width, color: color)
                }
            }
        }
        
        buffer.addCircle(center: center, radius: majorSize, color: color)
    }
    return buffer
}

let buffer2 = createSplat(center: Point(x: 0.5, y: 0.5), color: Color.blue)
/*let buffer3 = createSplat(center: Point(x: -0.5, y: -0.5), color: Color.red)
 let buffer4 = createSplat(center: Point(x: -0.5, y: 0.5), color: Color.green)
 let buffer5 = createSplat(center: Point(x: 0.5, y: -0.5), color: Color.yellow)
 let buffer6 = createSplat(center: Point(x: 0, y: 0), color: Color.purple)*/

//Next is to draw on texture


let vertex = mtl.compileShader(named: "vertexShader")
let fragment = mtl.compileShader(named: "fragmentShader")
let pipeline = mtl.createRenderPipeline(vertex: vertex, fragment: fragment)

mtl.setBackground(color: Color.white)
mtl.prepareFrame()

let bgTexture = TextureTools.createTexture(ofSize: 4000)
mtl.drawable = bgTexture
let render =  mtl.getDefaultRenderEncoder()

render.setRenderPipelineState(pipeline)
render.drawTriangles(buffer: buffer)
render.drawTriangles(buffer: buffer2)
/*render.drawTriangles(buffer: buffer3)
 render.drawTriangles(buffer: buffer4)
 render.drawTriangles(buffer: buffer5)
 render.drawTriangles(buffer: buffer6)*/
mtl.finishEncoding(encoder: render)
mtl.blur(texture: bgTexture, ammount: 0.05)
mtl.finishFrame()


let pvc = GridHolder()
pvc.view(image: bgTexture.displayInPlayground()!)

PlaygroundPage.current.liveView = pvc


