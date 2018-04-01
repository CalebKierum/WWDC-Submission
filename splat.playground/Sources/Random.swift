
import Foundation
import SpriteKit

extension Array {
    mutating func shuffle() {
        for _ in 0..<((count>0) ? (count-1) : 0) {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}

public class Random {
    private static var pot:[CGFloat] = []
    private static var poker:Int = 0
    public static func initialize() {
        poker = 0
        let res = 200
        for i in 0...res {
            let value = CGFloat(i) / CGFloat(res)
            pot.append(value)
        }
        pot.shuffle()
        stir()
    }
    public static func stir() {
        //pot.shuffle()
        for _ in 0..<30 {
            swap(index1: int(start: 0, end: 199), index2: int(start: 0, end: 199))
        }
        poker = int(start: 0, end: 200)
    }
    private static func swap(index1: Int, index2: Int) {
        let num1 = pot[index1]
        pot[index1] = pot[index2]
        pot[index2] = num1
    }
    public static func floatLinear(start: CGFloat = 0, end: CGFloat = 1) -> CGFloat {
        poker += 1
        if (poker > pot.count - 2) {
            stir()
        }
        return putInRange(pot[poker], start: start, end: end)
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

