/*:
 # Animations
 
 Now imagine if we had to manually add vertices each time we wanted to draw a shape! That would be repetitive and too much work so I have added functions to the VertexBufferCreator that allow you to create shapes like lines, rectangles, circles, and squares. Although they might not look like it each of them are made of triangles
 
 Now we will create a run loop to help us animate the frame. Create a function wtih no arguments our return value and pass it into executeContinuously() inside of that function put the code designated and something else to animate the shapes drawn
 */

import PlaygroundSupport

//Create the metal state
let state = metalState()

//Create the grid view
let gridViewController = GridHolder()
gridViewController.gridOn()

//Create a texture and set it as the drawable
let drawOn = TextureTools.createTexture(ofSize: 200)

//Set the drawable
state.setDrawable(to: drawOn)

//Compile shaders and use them to make a pipeline
let vertex = state.compileShader(named: "vertexShader")
let fragment = state.compileShader(named: "fragmentShader")
let pipeline = state.createRenderPipeline(vertex: vertex, fragment: fragment)

//TODO: Below here goes in the run loop

//Create a triangles vertices
let triangle = VertexBufferCreator()
triangle.addSquare(center: Point(x: 0, y: -0.5), width: 0.4, rotation: 0, color: Color.green)
triangle.addCircle(center: Point(x: 0, y: 0.5), radius: 0.4, color: Color.yellow)

//Prepare and finish the frame
state.prepareFrame()

//Get the render encoder
let render =  state.getRenderEncoder()
render.setRenderPipelineState(pipeline)
render.drawTriangles(buffer: triangle)
state.finishEncoding(encoder: render)

//Finish the frame
state.finishFrame()

//To see your results
let tex = drawOn.displayInPlayground()
gridViewController.view(image: tex!)

//TODO: Above here goes in the run loop

PlaygroundPage.current.liveView = gridViewController

//TODO: Register your run loop here:
