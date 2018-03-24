//: Playground - noun: a place where people can play

import PlaygroundSupport
import Foundation

let mtl = playgroundMetalView(frame: Rect(x: 0, y: 0, width: 30, height: 30))
let buffer = VertexBufferCreator()
buffer.addVertex(x: -1, y: -1, color: Color.red)
buffer.addVertex(x: 0, y: 1, color: Color.green)
buffer.addVertex(x: 1, y: -1, color: Color.blue)
let object = buffer.getBufferObject()
let vertex = mtl.compileShader(named: "vertexShader")
let fragment = mtl.compileShader(named: "fragmentShader")
let pipeline = mtl.createRenderPipeline(vertex: vertex, fragment: fragment)

mtl.setBackground(color: Color.cyan)
mtl.prepareFrame()
let render =  mtl.getRenderEncoder()

render.setRenderPipelineState(pipeline)
render.setVertexBuffer(object, offset: 0, index: 0)
render.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

mtl.finishEncoding(encoder: render)
mtl.finishFrame()

//view.addSubview(mtl)

let grid = GridView(size: Size(width: 300, height: 300))
grid.RenderViewReference = mtl


public class PVC:ViewController{
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    public func addView(viewer: View) {
        view.addSubview(viewer)
    }
}


let pvc = PVC()
pvc.addView(viewer: grid)
PlaygroundPage.current.liveView = pvc
PlaygroundPage.current.needsIndefiniteExecution = true

grid.refresh()


