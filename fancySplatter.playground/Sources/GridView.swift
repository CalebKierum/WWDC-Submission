//  GridView.swift
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb Kierum. All rights reserved.
//

import Foundation
import CoreGraphics
import MetalKit

struct Line {
    var start:Point
    var end:Point
    var size:CGFloat
}

public class GridView:View {
    
    private var lines:[Line] = []
    private var fields:[Text] = []
    private var contentColor:Color = Color.white
    public var imageView:View? = nil
    private var imageS:Image? = nil
    
    public init(size: CGFloat = 300.0) {
        super.init(frame: Rect(x: 0, y: 0, width: size, height: size))
        calculateGeometry(size: Size(width: size, height: size))
        imageView = View()
        addSubview(imageView!)
        
    }
    public init(old: GridView, size: CGFloat) {
        old.imageView!.removeFromSuperview()
        imageS = old.imageS
        super.init(frame: Rect(x: 0, y: 0, width: size, height: size))
        calculateGeometry(size: Size(width: size, height: size))
        imageView = View()
        addSubview(imageView!)
    }
    
    public func view(image: Image) {
        self.imageS = image
        refresh()
    }
    
    func clearAllChildren() {
        lines.removeAll()
        for field in fields {
            field.removeFromSuperview()
        }
        fields.removeAll()
    }
    func debugView(size: Size) {
        let path = Bezier(rect: Rect(origin: Point(x: 0, y: 0), size: size))
        Color.yellow.set()
        path.fill()
        Color.black.set()
    }
    func calculateGeometry(size: Size) {
        clearAllChildren()
        //debugView(size: size)
        
        //Fills full range of thing
        let padding:CGFloat = 10
        let font = Font(name: "Helvetica", size: 13)
        let tickSize:CGFloat = 9
        let majorThick:CGFloat = 5
        let minorThick:CGFloat = 3
        
        let label:Text = Text(labelWithString: "-1.9")
        label.font = font
        label.sizeToFit()
        let twidth = label.frame.size.width
        let theight = label.frame.size.height
        let origin = Point(x: 2 * padding + tickSize + twidth, y: 2 * padding + tickSize + theight)
        let length = min(size.width - origin.x, size.height - origin.y) - (max(majorThick, twidth) / 2)
        
        if let img = imageS {
            updateImageFrame(img: img, origin: origin, size: size, length: length, majorThick: majorThick)
        }
        
        lines.append(Line(start: origin, end: Point(x: origin.x, y: origin.y + length), size: majorThick))
        lines.append(Line(start: origin, end: Point(x: origin.x + length, y: origin.y), size: majorThick))
        let scalar:[CGFloat] = [0.7, 0.4, 1.0, 0.4, 0.7]
        for i in 0...4 {
            let percentage = (CGFloat(i) / 4.0)
            let x = origin.x + percentage * length
            let y = origin.y + percentage * length
            let width = tickSize * scalar[i]
            let center = ((majorThick + padding + tickSize) / 2)
            let low = center - (width / 2)
            let high = center + (width / 2)
            lines.append(Line(start: Point(x: x, y: origin.y - low), end: Point(x: x, y: origin.y - high), size: minorThick))
            lines.append(Line(start: Point(x: origin.x - low, y: y), end: Point(x: origin.x - high, y: y), size: minorThick))
            
            if (i % 2 == 0) {
                let text = String(format: "%.1f", percentage * 2.0 - 1.0)
                let label = Text(labelWithString: text)
                label.font = font
                label.alignment = Alignment.right
                label.textColor = contentColor
                let label2 = Text(labelWithString: text)
                label2.font = font
                label2.alignment = Alignment.center
                
                label.sizeToFit()
                label2.sizeToFit()
                label2.textColor = contentColor
                label.frame.origin.x = origin.x - (majorThick / 2) - padding - tickSize - twidth
                label.frame.origin.y = y - compat_yScalar * (theight / 2)
                
                label2.frame.origin.x = x - (twidth / 2)
                label2.frame.origin.y = origin.y - (majorThick / 2) - padding - tickSize - theight
                
                if (compat_yScalar == -1) {
                    label2.frame.origin.y = size.height - (theight + padding)
                    label.frame.origin.y = size.height - label.frame.origin.y
                }
                
                
                self.addSubview(label)
                self.addSubview(label2)
                fields.append(label)
                fields.append(label2)
            }
        }
    }
    public func refresh() {
        draw(frame)
    }
    private func transformForOs(rect: Rect, point: Point) -> Point {
        var new = Point()
        new.x = point.x
        new.y = point.y
        if (compat_yScalar == -1) {
            new.y = rect.size.height + compat_yScalar * point.y
        }
        return new
    }
    public override func draw(_ dirtyRect: Rect) {
        calculateGeometry(size: Size(width: dirtyRect.width, height: dirtyRect.height))
        
        for line in lines {
            let path = Bezier()
            path.lineCapStyle = round
            path.lineWidth = line.size
            contentColor.set()
            path.move(to: transformForOs(rect: dirtyRect, point: line.start))
            path.line(to: transformForOs(rect: dirtyRect, point: line.end))
            path.stroke()
        }
    }
    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
