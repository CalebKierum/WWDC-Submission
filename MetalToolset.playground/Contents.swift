//: Playground - noun: a place where people can play

import PlaygroundSupport
import Foundation

let mtl = playgroundMetalView(size: 300.0)

let buffer = VertexBufferCreator()
buffer.addVertex(x: -1, y: -1, color: Color.purple)
buffer.addVertex(x: 0, y: 1, color: Color.green)
buffer.addVertex(x: 1, y: -1, color: Color.blue)
buffer.addVertex(x: 1, y: -1, color: Color.red)
buffer.addVertex(x: 1, y: 1, color: Color.green)
buffer.addVertex(x: 0, y: 1, color: Color.green)

let buffer2 = GeometryCreator.rectangle(center: Point(x: 0.3, y: 0), width: 0.1, height: 0.3, rotation: 3.141592 * 0.25, color: Color.red)
let buffer3 = GeometryCreator.circle(center: Point(x: -0.5, y: 0.0), radius: 0.2, color: Color.yellow)
let buffer4 = GeometryCreator.line(from: Point(x: -0.5, y: 0.2), to: Point(x: 0.5, y: 0.0), width: 0.1, color: Color.red)
let buffer5 = GeometryCreator.square(center: Point(x: -0.5, y: -0.5), width: 1.0)

let vertex = mtl.compileShader(named: "vertexShader")
let fragment = mtl.compileShader(named: "fragmentShader")
let pipeline = mtl.createRenderPipeline(vertex: vertex, fragment: fragment)

mtl.setBackground(color: Color.cyan)
mtl.prepareFrame()
let render =  mtl.getRenderEncoder()


render.setRenderPipelineState(pipeline)
render.drawTriangles(buffer: buffer)
render.drawTriangles(buffer: buffer2)
render.drawTriangles(buffer: buffer3)
render.drawTriangles(buffer: buffer4)
render.drawTriangles(buffer: buffer5)

mtl.finishEncoding(encoder: render)
mtl.finishFrame()

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
        view = View(frame: Rect(x: 0, y: 0, width: 400, height: 400))
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


