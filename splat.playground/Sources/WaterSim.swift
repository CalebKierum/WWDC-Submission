import Metal
import MetalKit

enum Actions {
    case reset
    case paint(MTLTexture)
    case location(Point)
}
public class WatercolorSimulation {
    private var frame:Int = 0
    private var tex1:MTLTexture
    private var tex2:MTLTexture
    private var state:metalState
    private var queue:[Actions] = []
    private var step:MTLRenderPipelineState
    private var clear:MTLRenderPipelineState
    private var paint:MTLRenderPipelineState
    private var simQueue:Int = 0
    private var bgTexture:MTLTexture
    private var noise1:MTLTexture
    private var noise2:MTLTexture
    private var combTex:MTLTexture
    private var combTex2:MTLTexture
    public init(state: metalState, resolution: CGFloat) {
        tex1 = TextureTools.createTexture(ofSize: resolution)
        tex2 = TextureTools.createTexture(ofSize: resolution)
        bgTexture = TextureTools.createTexture(ofSize: resolution)
        combTex = TextureTools.createTexture(ofSize: resolution)
        combTex2 = TextureTools.createTexture(ofSize: resolution)
        self.state = state
        
        let shader = ensure(try String(contentsOf: #fileLiteral(resourceName: "Water.metal")))
        let library = ensure(try metalState.sharedDevice!.makeLibrary(source: shader, options: nil))
        let s_vertex = ensure(library.makeFunction(name: "main_vertex"))
        let s_clear = ensure(library.makeFunction(name: "clear"))
        let s_paint = ensure(library.makeFunction(name: "paint"))
        let s_simulate = ensure(library.makeFunction(name: "step"))
        
        step = state.createRenderPipeline(vertex: s_vertex, fragment: s_simulate)
        clear = state.createRenderPipeline(vertex: s_vertex, fragment: s_clear)
        paint = state.createRenderPipeline(vertex: s_vertex, fragment: s_paint)
        
        let img = Image(named: "NewNoise.png")!
        noise1 = TextureTools.loadTexture(image: img)
        let img2 = Image(named: "natural.png")!
        noise2 = TextureTools.loadTexture(image: img2)
        
        reset()
    }
    public func reset() {
        //If it can does immediately if not queues it up
        if (state.getState() == .Preparing) {
            let output = getOutput()
            
            state.setDrawable(to: output)
            let render = state.getRenderEncoder()
            render.setRenderPipelineState(clear)
            render.drawFullScreen()
            state.finishEncoding(encoder: render)
            
            frame += 1
        } else {
            queue = []
            queue.append(.reset)
        }
    }
    public func paintSplatter(pos: Point) {
        if (state.getState() == .Preparing) {
            let buffer2 = GeometryCreator.splat(center: pos, color: Color.white)
            
            state.draw(geometry: buffer2, to: bgTexture)
            
            state.blur(texture: bgTexture, ammount: 0.2)
            
            let textua1 = state.combine(blurred: bgTexture, weight: 1.0, noise: noise1, weight: 0.35, color: Color.white, onto: combTex)
            var textua2 = state.combine(blurred: textua1, weight: 1.0, noise: noise2, weight: 0.24, color: Color.white, onto: combTex2)
            state.clamp(texture: &textua2, wall: 0.82, tolerance: 0.00, onto: combTex)
            paint(texture: textua2)
        } else {
            queue.append(.location(pos))
        }
    }
    public func paint(texture: MTLTexture) {
        //If it can does immediately if not queues it up
        if (state.getState() == .Preparing) {
            let splatColor = randomColor()
            
            let input = getInput()
            let output = getOutput()
            
            state.setDrawable(to: output)
            let render = state.getRenderEncoder()
            render.setRenderPipelineState(paint)
            render.setFragmentTexture(input, index: 0)
            render.setFragmentTexture(texture, index: 1)
            let intermediate = CIColor.convert(color: splatColor)
            var color:float3 = float3(Float(intermediate.red), Float(intermediate.green), Float(intermediate.blue))
            render.setFragmentBytes(&color, length: MemoryLayout<float3>.stride, index: 0)
            render.drawFullScreen()
            state.finishEncoding(encoder: render)
            
            frame += 1
        } else {
            queue.append(.paint(texture))
        }
    }
    public func simulate() -> MTLTexture? {
        simQueue += 1
        if (state.getState() != .Preparing) {
            
            return nil
        } else {
            for instruction in queue {
                switch instruction {
                case .reset:
                    reset()
                case let .paint(tex):
                    paint(texture: tex)
                case let .location(pos):
                    paintSplatter(pos: pos)
                }
                
            }
            queue = []
            var output:MTLTexture? = nil
            for _ in 0..<simQueue {
                
                
                let input = getInput()
                output = getOutput()
                
                state.setDrawable(to: output!)
                let render = state.getRenderEncoder()
                render.setRenderPipelineState(step)
                render.setFragmentTexture(input, index: 0)
                render.drawFullScreen()
                state.finishEncoding(encoder: render)
                
                frame += 1
            }
            simQueue = 0
            return output
        }
    }
    private func getInput() -> MTLTexture {
        if (frame % 2 == 0) {
            return tex1
        } else {
            return tex2
        }
    }
    
    private func getOutput() -> MTLTexture {
        if (frame % 2 == 1) {
            return tex1
        } else {
            return tex2
        }
    }
    
}
