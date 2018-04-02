//  GridView.swift
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb Kierum. All rights reserved.
//

import Foundation
import CoreGraphics
import MetalKit

/*
    A grid view holds an image and can optionally display a coordinate system around it from [-1-1] on both axises
*/

//Defines a line that will be drawn with a bezier path
struct Line {
    var start:Point
    var end:Point
    var size:CGFloat
}

//The grid view
public class GridView:View {
    
    //Tick marks of the grid
    private var lines:[Line] = []
    
    //Labels of the field
    private var fields:[Text] = []
    
    //The color for everything drawn in the grid
    private var contentColor:Color = Color.white
    
    //The viewer for the image (will be drawn to the full size of the view)
    public var imageView:View? = nil
    
    //The image to be drawn to that view
    private var imageS:Image? = nil
    
    //Whether or not the grid is on or off called with gridOn and gridOff
    public var grid:Bool = true
    
    //Points to its holder
    public var holder:GridHolder?
    
    //Initialize it to a size although it will likely be ignored by the holder
    public init(size: CGFloat = 300.0) {
        //Call the super initializer to be safe
        super.init(frame: Rect(x: 0, y: 0, width: size, height: size))
        
        //Calculate the geometry inside
        calculateGeometry(size: Size(width: size, height: size))
        
        //Get the image view and add it as a subview
        imageView = View()
        addSubview(imageView!)
        
        //Helps note that we clear every time
        clearsContextBeforeDrawing = true
    }

    //View a new image. Refresh is required
    public func view(image: Image) {
        self.imageS = image
        refresh()
    }
    
    //Removes all lines and labels from the simulation usually before redrawing
    func clearAllChildren(size: Size) {
        lines.removeAll()
        for field in fields {
            field.removeFromSuperview()
        }
        fields.removeAll()
        let path = Bezier(rect: Rect(origin: Point(x: 0, y: 0), size: size))
        Color.black.set()
        path.fill()
    }
    
    //Draws a yellow box of size
    func debugView(size: Size) {
        let path = Bezier(rect: Rect(origin: Point(x: 0, y: 0), size: size))
        Color.yellow.set()
        path.fill()
        Color.black.set()
    }
    
    //Calculate the grid geometry for the given screen size
    func calculateGeometry(size: Size) {
        
        //NOTE: compat_yScalar is used to compensate for the differences between UIKit and Cocoas coordinate systems
        
        //Clear everything that was there before
        clearAllChildren(size: size)
        
        //Padding is between elements makes it look nice
        let padding:CGFloat = 10
        //The font of the labels
        let font = Font(name: "Helvetica", size: 13)
        //How wide the ticks are
        let tickSize:CGFloat = 9
        //How thick the main grid is
        let majorThick:CGFloat = 5
        //How thick the smaller ticks are
        let minorThick:CGFloat = 3
        
        //We use this label to get the dimensions of the labels in our font
        let label:Text = Text(labelWithString: "-1.9")
        label.font = font
        label.sizeToFit()
        //Grab the label width for later use
        let twidth = label.frame.size.width
        let theight = label.frame.size.height
        
        //Calculate the origin (-1, -1) of the grid
        let origin = Point(x: 2 * padding + tickSize + twidth, y: 2 * padding + tickSize + theight)
        //Calculate how long it can be
        let length = min(size.width - origin.x, size.height - origin.y) - (max(majorThick, twidth) / 2)
        
        //If we have an image update its frame to fit it in
        if let img = imageS {
            updateImageFrame(img: img, origin: origin, size: size, length: length, majorThick: majorThick)
        }
        
        //If grid is on draw it
        if (grid) {
            //Ad the major axis
            lines.append(Line(start: origin, end: Point(x: origin.x, y: origin.y + length), size: majorThick))
            lines.append(Line(start: origin, end: Point(x: origin.x + length, y: origin.y), size: majorThick))
        
            //Scalars define the length of lines
            let scalar:[CGFloat] = [0.7, 0.4, 1.0, 0.4, 0.7]
            
            //For each of the ticks
            for i in 0...4 {
                //Get its percentage number to calculate its position
                let percentage = (CGFloat(i) / 4.0)
                let x = origin.x + percentage * length
                let y = origin.y + percentage * length
                
                //Get the width of the tick
                let width = tickSize * scalar[i]
                //Calculate its center
                let center = ((majorThick + padding + tickSize) / 2)
                //Based on that get where it starts and ends
                let low = center - (width / 2)
                let high = center + (width / 2)
                //Add the horizontal and vertical tick
                lines.append(Line(start: Point(x: x, y: origin.y - low), end: Point(x: x, y: origin.y - high), size: minorThick))
                lines.append(Line(start: Point(x: origin.x - low, y: y), end: Point(x: origin.x - high, y: y), size: minorThick))
                
                //Add text
                if (i % 2 == 0) {
                    //Creat the labels and make them the right font
                    let text = String(format: "%.1f", percentage * 2.0 - 1.0)
                    let label = Text(labelWithString: text)
                    label.font = font
                    label.alignment = Alignment.right
                    label.textColor = contentColor
                    let label2 = Text(labelWithString: text)
                    label2.font = font
                    label2.alignment = Alignment.center
                    
                    //Size to fit so that they have a frame
                    label.sizeToFit()
                    label2.sizeToFit()
                    
                    //Set the text color
                    label2.textColor = contentColor
                    
                    //Put it at its exact position
                    label.frame.origin.x = origin.x - (majorThick / 2) - padding - tickSize - twidth
                    label.frame.origin.y = y - compat_yScalar * (theight / 2)
                    
                    label2.frame.origin.x = x - (twidth / 2)
                    label2.frame.origin.y = origin.y - (majorThick / 2) - padding - tickSize - theight
                    
                    //OSX and iOS have different coordinate systems to adjust
                    if (compat_yScalar == -1) {
                        label2.frame.origin.y = size.height - (theight + padding)
                        label.frame.origin.y = size.height - label.frame.origin.y
                    }
                    
                    
                    //Add to the frame
                    self.addSubview(label)
                    self.addSubview(label2)
                    fields.append(label)
                    fields.append(label2)
                }
            }
        }
    }
    
    //Turns the grid off
    public func gridOff() {
        grid = false
        refresh()
    }
    
    //Turns the grid on
    public func gridOn() {
        grid = true
        refresh()
    }
    
    //Refreshes the grid
    public func refresh() {
        setNeedsDisplay()
    }
    
    //Function that compensates for Cocoa and UIKit coordinate system differences
    private func transformForOs(rect: Rect, point: Point) -> Point {
        var new = Point()
        new.x = point.x
        new.y = point.y
        if (compat_yScalar == -1) {
            new.y = rect.size.height + compat_yScalar * point.y
        }
        return new
    }
    
    //Called whenever it is time to redraw this frames contents
    public override func draw(_ dirtyRect: Rect) {
        //Let it know we will clear it
        clearsContextBeforeDrawing = true
        
        //Calculate all of the geometry in the grid
        calculateGeometry(size: Size(width: dirtyRect.width, height: dirtyRect.height))
        
        //Draw each line
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
    
    //We dont actually need this but we have to have it here to play nicely
    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
