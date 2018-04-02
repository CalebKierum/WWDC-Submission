/*:
 
 # Welcome
 This playground will give an introduction to procedural art.
 
 We will be making and simulating paint splatters.
 
 Go ahead and open up the Live View and click on it to splatter some paint before moving on to the [next page](@next)
*/

import PlaygroundSupport

//Initialize the random number generator
Random.initialize()

//This is just our view
let gridViewController = GridHolder()
gridViewController.gridOff()

//We are using metal
let metal = metalState()

//Our water simulation goes here
let water = WatercolorSimulation(state: metal, resolution: 850)
gridViewController.waterDelegate = water

//Does one frame
func simulate() {
    //Prepares the frame
    metal.prepareFrame()
    
    //Gets the result of running it
    let result = water.simulate()
    
    //Finish the frame
    metal.finishFrame()
    
    //View the result
    gridViewController.view(image: result!.displayInPlayground()!)
}



executeContinuously(block: simulate)

PlaygroundPage.current.liveView = gridViewController
