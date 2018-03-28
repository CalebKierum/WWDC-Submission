
import Metal
import Accelerate

extension MTLRenderCommandEncoder {
    public func drawTriangles(buffer: VertexBufferCreator) {
        setVertexBuffer(buffer.getBufferObject(), offset: 0, index: 0)
        drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: buffer.getVertexCount())
    }

}

public extension MTLTexture {
    func displayInPlayground() -> Image? {
        let texture = self
        let width = texture.width
        let height = texture.height
        let bytesPerRow = width * 4
        
        let data = UnsafeMutableRawPointer.allocate(bytes: bytesPerRow * height, alignedTo: 4)
        defer {
            data.deallocate(bytes: bytesPerRow * height, alignedTo: 4)
        }
        
        let region = MTLRegionMake2D(0, 0, width, height)
        texture.getBytes(data, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        var buffer = vImage_Buffer(data: data, height: UInt(height), width: UInt(width), rowBytes: bytesPerRow)
        
        let map: [UInt8] = [0, 1, 2, 3]
        vImagePermuteChannels_ARGB8888(&buffer, &buffer, map, 0)
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear) else { return nil }
        guard let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return nil }
        guard let cgImage = context.makeImage() else { return nil }
        
        return Image(cgImage: cgImage, size: Size(width: width, height: height))
    }
}
