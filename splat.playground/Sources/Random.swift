
import Foundation
import SpriteKit

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

public class Random {
    private static var pot:[CGFloat] = []
    private static var index:Int = 0
    public static func initialize() {
        index = 0
        let res = 200
        for i in 0..<res {
            let value = CGFloat(i) / CGFloat(res)
            pot.append(value)
        }
        pot.shuffle()
    }
    public static func stir() {
        pot.shuffle()
        index = 0
    }
    public static func floatLinear(start: CGFloat = 0, end: CGFloat = 1) -> CGFloat {
        index += 1
        if (index > pot.count - 2) {
            stir()
        }
        return putInRange(pot[index], start: start, end: end)
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

