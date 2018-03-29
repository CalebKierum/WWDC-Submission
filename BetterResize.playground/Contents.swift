//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let vc = UIViewController()
class View:UIView {
    public override func draw(_ dirtyRect: CGRect) {
        print("Draw")
        let path = UIBezierPath(rect: dirtyRect)
        UIColor.black.set()
        path.fill()
        print(dirtyRect.width)
        UIColor.black.set()
        
        UIColor.red.set()
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: 0, y: 0))
        path2.addLine(to: CGPoint(x: dirtyRect.width * 0.5, y: dirtyRect.height * 0.5))
        path2.stroke()
    }
}

let frame = CGRect(x: 0, y: 0, width: 300, height: 300)
let frame2 = CGRect(x: 0, y: 0, width: 400, height: 600)
let view = View(frame: frame)

view.frame = frame
//view.frame = frame2

vc.view.addSubview(view)
PlaygroundPage.current.liveView = vc
PlaygroundPage.current.needsIndefiniteExecution = true

let date = Date().addingTimeInterval(2)
let timer = Timer(fire: date, interval: 0, repeats: false, block: { _ in
    print("Async")
    view.frame = frame2
    view.setNeedsDisplay()
})
RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
