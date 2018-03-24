//: Playground - noun: a place where people can play

import PlaygroundSupport


let view = playgroundMetal(frame: Rect(x: 0, y: 0, width: 400, height: 400))
let buffer = VertexBufferCreator()
buffer.addVertex(x: -1, y: -1, color: Color.red)
buffer.addVertex(x: 0, y: 1, color: Color.green)
buffer.addVertex(x: 1, y: -1, color: Color.blue)
let object = buffer.getBufferObject()
let vertex = view.compileShader(named: "vertex_main")
let fragment = view.compileShader(named: "fragment_main")
let pipeline = view.createRenderPipeline(vertex: vertex, fragment: fragment)

view.setBackground(color: Color.cyan)
view.prepareFrame()
let render =  view.getRenderEncoder()

render.setRenderPipelineState(pipeline)
render.setVertexBuffer(object, offset: 0, index: 0)
render.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

view.finishEncoding(encoder: render)
view.finishFrame()

PlaygroundPage.current.liveView = view
//PlaygroundPage.current.needsIndefiniteExecution = true

