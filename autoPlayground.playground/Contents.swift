//: Playground - noun: a place where people can play

import PlaygroundSupport
import Foundation
import SpriteKit
import MetalKit

let mtl = metalState()

let buffer2 = GeometryCreator.splat(center: Point(x: 0, y: 0), color: Color.red)

let vertex = mtl.compileShader(named: "vertexShader")
let fragment = mtl.compileShader(named: "fragmentShader")
let pipeline = mtl.createRenderPipeline(vertex: vertex, fragment: fragment)
mtl.setBackground(color: Color.black)
mtl.prepareFrame()
let bgTexture = TextureTools.createTexture(ofSize: 5000)
let img = Image(named: "Square.png")!
let tex2 = TextureTools.loadTexture(image: img)
mtl.drawable = bgTexture
//mtl.drawable = tex2

let render =  mtl.getDefaultRenderEncoder()

render.setRenderPipelineState(pipeline)
render.drawTriangles(buffer: buffer2)

mtl.finishEncoding(encoder: render)
mtl.blur(texture: bgTexture, ammount: 0.5)
mtl.finishFrame()


let pvc = GridHolder()
pvc.gridOn()

pvc.view(image: bgTexture.displayInPlayground()!)
pvc.view(image: tex2.displayInPlayground()!)
pvc.gridOff()

PlaygroundPage.current.liveView = pvc

PlaygroundPage.current.needsIndefiniteExecution = true

