//
//  GraphView.swift
//  Calculator
//
//  Created by Angelo Wong on 3/9/16.
//  Copyright © 2016 Stanford. All rights reserved.
//

import UIKit

protocol GraphDataGenerator: class {
//    func generateX(sender: UIView, scale: CGFloat, scaleFactor: CGFloat) -> [CGFloat]
//    func generateYFrom(xArray: [CGFloat])
    func generatePointsToGraph(sender: GraphView, scale: CGFloat, scaleFactor: CGFloat, dataIsOld: Bool) -> (x: [CGFloat], y: [CGFloat?])?
}

@IBDesignable
class GraphView: UIView {
    
    var deltaFromCenter: CGPoint?
    
    let axesDrawer = AxesDrawer()
    
    var graphDataGenerator: GraphDataGenerator?
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private struct History {
        static let ScaleKey = "GraphViewController.Scale"
        //cannot cast CGPoint to an AnyObject?, so I'll make this mess here.
        static let OriginKeyX = "GraphViewController.OriginX"
        static let OriginKeyY = "GraphViewController.OriginY"
    }
    
    @IBInspectable
    var axesOrigin: CGPoint {
        get {
            let x = defaults.objectForKey(History.OriginKeyX) as! CGFloat?
            let y = defaults.objectForKey(History.OriginKeyY) as! CGFloat?
            if x != nil && y != nil {
                return CGPoint(x: x!, y: y!)
            } else {
                return currentCenter
            }
        }
        set {
            defaults.setObject(newValue.x as AnyObject, forKey: History.OriginKeyX)
            defaults.setObject(newValue.y as AnyObject, forKey: History.OriginKeyY)
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var lineWidth: CGFloat = 1.5 {
        didSet {
            setNeedsDisplay() //redraw when width changes
        }
    }
    
    @IBInspectable
    var color: UIColor = UIColor.greenColor()
    
    var useOldDelta: Bool = false
    
    var currentCenter: CGPoint! {
        willSet {
            if let cc = currentCenter {
                if newValue!.x != cc.x || newValue!.y != cc.y {
                    //rotation has occured
                    useOldDelta = true
                } else {
                    useOldDelta = false
                }
            }
        }
    }
    
    var dataIsOld = false
    
    @IBInspectable
    var scale: CGFloat {
        get {
            return defaults.objectForKey(History.ScaleKey) as? CGFloat ?? CGFloat(1.0)
        }
        set {
            defaults.setObject(newValue as AnyObject?, forKey: History.ScaleKey)
            setNeedsDisplay()
            dataIsOld = false
        }
    }
    
    func graphXY(y:[Double], x: [Double]) -> [Double] {
        //use a delegate to grab y and x data.
        //DrawRect here to graph the entire graph
        return [0.0]
    }
    
    override func drawRect(rect: CGRect) {
        generateAndDrawAxes(rect)
        var currentPoint: CGPoint
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        color.set()
        if let xyPoints = graphDataGenerator?.generatePointsToGraph(self, scale: scale, scaleFactor: contentScaleFactor, dataIsOld: dataIsOld) {
            for i in 0..<xyPoints.x.count {
                if xyPoints.y[i] != nil {
                    let x = align(xyPoints.x[i], contentScaleFactor: contentScaleFactor)
                    let y = align(xyPoints.y[i]!, contentScaleFactor: contentScaleFactor)
                    currentPoint = CGPoint(x: x, y: y)
                    if path.empty {
                        path.moveToPoint(currentPoint)
                    } else {
                        path.addLineToPoint(currentPoint)
                        path.moveToPoint(currentPoint)
                    }
                } else {
                    //discontinuity
                    path.stroke()
                    path.removeAllPoints()
                }
            }
            path.stroke()
        }
    }
    
    private func align(coordinate: CGFloat, contentScaleFactor: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
    
    //draw x and y axes given current rect with correct bounds, and also adjust for
    //rotation.
    func generateAndDrawAxes(rect: CGRect) {
        currentCenter = convertPoint(center, fromView: superview)
        let originPoint = calculateOrigin()
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.drawAxesInRect(rect, origin: originPoint, pointsPerUnit: scale)
        if useOldDelta == false {
            originDeltaFromCenter(axesOrigin)
        }
    }
    
    func calculateOrigin() -> CGPoint {
        let oldDelta = deltaFromCenter ?? CGPointZero
        return useOldDelta ? oldDelta + currentCenter : axesOrigin
    }
    
    func originDeltaFromCenter(origin: CGPoint){
        let currentOrigin = axesOrigin
        deltaFromCenter = currentOrigin - currentCenter
    }
    

}

func - (a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x - b.x, y: a.y - b.y)
}

func + (a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x + b.x, y: a.y + b.y)
}