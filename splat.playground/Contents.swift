//: Playground - noun: a place where people can play

import PlaygroundSupport
import Foundation
import SpriteKit
import MetalKit

Random.initialize()

let pvc = GridHolder()
let mtl = metalState()
let water = WatercolorSimulation(state: mtl, resolution: 850)
pvc.waterDelegate = water
mtl.setBackground(color: Color.black)
pvc.gridOn()
func newSplat() {
    //let framerate = 1.0 / FPS.frame()
    
    mtl.prepareFrame()
    
    let res = water.simulate()
    
    mtl.finishFrame()
    pvc.view(image: res!.displayInPlayground()!)
}


PlaygroundPage.current.liveView = pvc

executeContinuously(block: newSplat)
