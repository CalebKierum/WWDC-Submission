//: Playground - noun: a place where people can play

import PlaygroundSupport
import Foundation
import SpriteKit
import MetalKit

Random.initialize()

SlotContants.totalScale = 0.13
SlotContants.majorLow = 0.9
SlotContants.sizeScalar = 0.9
SlotContants.displacementScalar = 1.4

let pvc = GridHolder()
func newSplat() {
    
    let mtl = metalState()
    
    let buffer2 = GeometryCreator.splat(center: Point(x: 0, y: 0), color: Color.white)
    
    
    mtl.setBackground(color: Color.black)
    mtl.prepareFrame()
    var bgTexture = TextureTools.createTexture(ofSize: 800)
    let img = Image(named: "NewNoise.png")!
    let tex2 = TextureTools.loadTexture(image: img)
    let img2 = Image(named: "natural.png")!
    let tex3 = TextureTools.loadTexture(image: img2)
    
    mtl.draw(geometry: buffer2, to: bgTexture)
    
    mtl.blur(texture: bgTexture, ammount: 0.2)
    
    var textua1 = mtl.combine(blurred: bgTexture, weight: 1.0, noise: tex2, weight: 0.35, color: Color.white)
    var textua2 = mtl.combine(blurred: textua1, weight: 1.0, noise: tex3, weight: 0.24, color: Color.white)
    mtl.clamp(texture: &textua2, wall: 0.82, tolerance: 0.00)
    
    mtl.finishFrame()
    
    
    
    pvc.gridOn()
    
    //pvc.view(image: textua2.displayInPlayground()!)
    //pvc.view(image: tex2.displayInPlayground()!)
    pvc.view(image: textua2.displayInPlayground()!)
    //pvc.view(image: bgTexture.displayInPlayground()!)
}
newSplat()
pvc.gridOn()

PlaygroundPage.current.liveView = pvc

PlaygroundPage.current.needsIndefiniteExecution = true

let date = Date().addingTimeInterval(2)
let timer = Timer(fire: date, interval: 1, repeats: true, block: { _ in
    //print("Async")
    newSplat()
})
RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)

