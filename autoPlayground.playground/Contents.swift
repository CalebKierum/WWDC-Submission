//: Playground - noun: a place where people can play

import PlaygroundSupport
import Foundation
import SpriteKit

let mtl = metalState()
 
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
 
 
 
 let buffer2 = GeometryCreator.splat(center: Point(x: 0.5, y: 0.5), color: Color.blue)
 
 let vertex = mtl.compileShader(named: "vertexShader")
 let fragment = mtl.compileShader(named: "fragmentShader")
 let pipeline = mtl.createRenderPipeline(vertex: vertex, fragment: fragment)
 
 mtl.setBackground(color: Color.white)
 mtl.prepareFrame()
 
 let bgTexture = TextureTools.createTexture(ofSize: 5000)
 mtl.drawable = bgTexture
 
 let render =  mtl.getDefaultRenderEncoder()
 render.setRenderPipelineState(pipeline)
 render.drawTriangles(buffer: buffer)
 render.drawTriangles(buffer: buffer2)
 
 mtl.finishEncoding(encoder: render)
 mtl.blur(texture: bgTexture, ammount: 0.05)
 mtl.finishFrame()


let pvc = GridHolder()
pvc.gridOn()

pvc.view(image: bgTexture.displayInPlayground()!)
//pvc.gridOff()

PlaygroundPage.current.liveView = pvc

PlaygroundPage.current.needsIndefiniteExecution = true

