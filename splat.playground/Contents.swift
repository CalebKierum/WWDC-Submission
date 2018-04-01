//: Playground - noun: a place where people can play

import PlaygroundSupport

//Initial
Random.initialize()
let gridViewController = GridHolder()
let metal = metalState()
let water = WatercolorSimulation(state: metal, resolution: 850)
gridViewController.waterDelegate = water
gridViewController.gridOn()
func simulate() {
    metal.prepareFrame()
    
    let result = water.simulate()
    
    metal.finishFrame()
    gridViewController.view(image: result!.displayInPlayground()!)
}

PlaygroundPage.current.liveView = gridViewController

executeContinuously(block: simulate)
