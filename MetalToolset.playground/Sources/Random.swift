
import Foundation
import SpriteKit

public class Random {
    public static func floatLinear(start: CGFloat = 0, end: CGFloat = 1) -> CGFloat {
        return putInRange(CGFloat(Float(arc4random()) / Float(UINT32_MAX)), start: start, end: end)
    }
    
    public static func floatBiasLow(factor: CGFloat, start: CGFloat = 0, end: CGFloat = 1) -> CGFloat {
        return putInRange(pow(floatLinear(), factor), start: start, end: end)
    }
    
    public static func floatBiasHigh(factor: CGFloat, start: CGFloat = 0, end: CGFloat = 1) -> CGFloat {
        return putInRange(pow(floatLinear(), 1.0 / factor), start: start, end: end)
    }
    
    public static func int(start: Int, end: Int) -> Int {
        return Int(arc4random_uniform(UInt32(end - start))) + start
    }
    
    static public func putInRange(_ num: CGFloat, start: CGFloat, end: CGFloat) -> CGFloat {
        return num * (end - start) + start
    }
    
    static public func randomRadian() -> CGFloat {
        return floatLinear(start: 0, end: 2.0 * 3.141592)
    }
}

