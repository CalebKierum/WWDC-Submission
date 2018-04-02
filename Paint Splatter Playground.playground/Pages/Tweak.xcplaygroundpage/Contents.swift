/*:
 # Tweaking
 
 Now that you know how this was generated you can tweak the parameters to make the simulation look better. Below are a sample of the parameters that control the simulation try editing some of them
 */

import PlaygroundSupport

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

/*: Here are the parameters you can manipulate

These are just a SAMPLING of the settings that can tweak this simulation
Experiment with changing these values and see what they do
Be wary that some should be changed by smaller or larger ammount and some should not be negative
*/

//:# Splat Generation Settings
//:1. Shape Parameters
//How big the entire splat is
SplatConstants.totalScale = 0.13
//The lowest scalar for the central circle
SplatConstants.majorLow = 0.9
//Scalar for the size of all circles in the splat
SplatConstants.sizeScalar = 0.8
//Scales how far out elements go from the center
SplatConstants.displacementScalar = 1.2
//Whether or not the main ball is there
SplatConstants.major = true
//Whether or not the bounded balls (small on the edge of the main) are there
SplatConstants.bounded = true
//Whether or not there is stuff thrown out from the orbiters
SplatConstants.orbiters = true
//Whether or not to draw larger lumps on the edges of the main circle
SplatConstants.spinoffs = true
//Whether random circles are thrown out from the main sphere
SplatConstants.random = true
//Whether lines are sent out form the splatter
SplatConstants.lines = true
//Give those lines a cap at the end
SplatConstants.cap = true
//Max lines to be drawn
SplatConstants.maxLines = 6
//Max random thingies
SplatConstants.maxRandom = 15
//:2. Rendering Parameters
//The contribution of the first (natural) noise texture
SplatConstants.noise1Contrib = 0.35 //Initially 0.35
//The contribution of the first (smooth) noise texture
SplatConstants.noise2Contrib = 0.24 //Initially 0.24
//The ammount to blur the source texture
SplatConstants.blurAmmount = 0.2 //Initially 0.2
//The clamps center
SplatConstants.clampCenter = 0.473 //Initially 0.473

//:# Water Simulation Settings
//How far a spot looks for other parts of the paper
WaterSimConstants.lookDistance = 3.0 //Initially 3
//Strength of water barrier before diffusion
WaterSimConstants.overflowStrength = 0.24 //Initially 0.2
//Strenght of the current color vs others
WaterSimConstants.diffusionBoost = 0.05 //Initially 0.05
//SPeed that the canvas dries
WaterSimConstants.drySpeed = 0.003 //Initially 0.03
//The ammount that color spreads to adjacent things
WaterSimConstants.colorSpread = 0.9 //Initially 0.9
//The ammount of wetness given to each new splat
WaterSimConstants.splatWetness = 1.0 //Initially 10.0
