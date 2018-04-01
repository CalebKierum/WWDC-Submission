
import Metal
import Accelerate

extension MTLRenderCommandEncoder {
    public func drawTriangles(buffer: VertexBufferCreator) {
        if (buffer.getVertexCount() > 2) {
            setVertexBuffer(buffer.getBufferObject(), offset: 0, index: 0)
            drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: buffer.getVertexCount())
        }
    }
    public func drawFullScreen() {
        drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }

}
class bufferHolder {
    static var buffers:[Int : UnsafeMutableRawPointer] = [Int : UnsafeMutableRawPointer]()
    static func get(size: Int) -> UnsafeMutableRawPointer {
        if let curr = buffers[size] {
            return curr
        } else {
            let create = size * size * 4
            let data = UnsafeMutableRawPointer.allocate(bytes: create, alignedTo: 1)
            buffers[size] = data
            return data
        }
    }
}
public extension MTLTexture {
    func displayInPlayground() -> Image? {
        let texture = self
        let width = texture.width
        let height = texture.height
        let bytesPerRow = width * 4
        
        let data = bufferHolder.get(size: width)
        
        let region = MTLRegionMake2D(0, 0, width, height)
        texture.getBytes(data, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        
        
        
        
        if (pixelFormat == .bgra8Unorm) {
            let map:[UInt8] = [2, 1, 0, 3]
            var buffer = vImage_Buffer(data: data, height: UInt(height), width: UInt(width), rowBytes: bytesPerRow)
            vImagePermuteChannels_ARGB8888(&buffer, &buffer, map, 0)
        }
        
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear) else { return nil }
        guard let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return nil }
        guard let cgImage = context.makeImage() else { return nil }
        
        return Image(cgImage: cgImage, size: Size(width: width, height: height))
    }
}
