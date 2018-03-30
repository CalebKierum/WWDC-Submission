//: Playground - noun: a place where people can play

import PlaygroundSupport
import Foundation
import SpriteKit
import MetalKit

let mtl = metalState()

let buffer2 = GeometryCreator.splat(center: Point(x: 0, y: 0), color: Color.white)


mtl.setBackground(color: Color.black)
mtl.prepareFrame()
let bgTexture = TextureTools.createTexture(ofSize: 4000)
let img = Image(named: "perlin.png")!
let tex2 = TextureTools.loadTexture(image: img)


mtl.draw(geometry: buffer2, to: bgTexture)

mtl.blur(texture: bgTexture, ammount: 0.5)

var textua2 = mtl.combine(blurred: bgTexture, weight: 1.0, noise: tex2, weight: 0.2, color: Color.white)
mtl.clamp(texture: &textua2, wall: 0.9, tolerance: 0.1)

mtl.finishFrame()


let pvc = GridHolder()
pvc.gridOn()

//pvc.view(image: bgTexture.displayInPlayground()!)
//pvc.view(image: tex2.displayInPlayground()!)
pvc.view(image: textua2.displayInPlayground()!)

pvc.gridOn()

PlaygroundPage.current.liveView = pvc

PlaygroundPage.current.needsIndefiniteExecution = true

