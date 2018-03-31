//: Playground - noun: a place where people can play

import PlaygroundSupport
import Foundation
import SpriteKit
import MetalKit

Random.initialize()

let pvc = GridHolder()
let mtl = metalState()
let water = WatercolorSimulation(state: mtl, resolution: 800)
pvc.waterDelegate = water
mtl.setBackground(color: Color.black)
pvc.gridOn()
let toDrawOn = TextureTools.createTexture(ofSize: 200)
func newSplat() {
    //let framerate = FPS.frame()
    mtl.prepareFrame()
    let res = water.simulate()
    let synch = res!.displayInPlayground()!
    mtl.viewAlpha(texture: res!, onto: toDrawOn)
    
    mtl.finishFrame()
    //pvc.view(image: grey.displayInPlayground()!)
    pvc.view(image: res!.displayInPlayground()!)
    //pvc.view(image: toDrawOn.displayInPlayground()!)
}


PlaygroundPage.current.liveView = pvc

PlaygroundPage.current.needsIndefiniteExecution = true

let date = Date().addingTimeInterval(2)
let timer2 = Timer(fire: date, interval: 1.0 / 60.0, repeats: true, block: { _ in
    newSplat()
})
RunLoop.main.add(timer2, forMode: RunLoopMode.commonModes)

