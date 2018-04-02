/*:
 # Shapes
 
 Now we render shapes! To do that we need three things. First we need a vertex buffer which essentially hold each of the points of our shape. Then we need shaders which come together into a pipeline. Finally we need to do a draw call with those elements to render it to the screen
 
 Use the live view to help you out with the coordinate system
 
 Now try and make it draw a rectangle then go on to the [next page](@next)
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

//Create a triangles vertices
let triangle = VertexBufferCreator()
triangle.addVertex(x: -1, y: -1, color: Color.blue)
triangle.addVertex(x: 0, y: 1, color: Color.red)
triangle.addVertex(x: 1, y: -1, color: Color.green)

//Compile shaders and use them to make a pipeline
let vertex = state.compileShader(named: "vertexShader")
let fragment = state.compileShader(named: "fragmentShader")
let pipeline = state.createRenderPipeline(vertex: vertex, fragment: fragment)

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
PlaygroundPage.current.liveView = gridViewController
