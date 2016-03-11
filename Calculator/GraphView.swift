//
//  GraphView.swift
//  Calculator
//
//  Created by Angelo Wong on 3/9/16.
//  Copyright © 2016 Stanford. All rights reserved.
//

import UIKit

protocol OriginDataSource: class {
    func updateOrigin(sender: GraphView) -> CGPoint
}

@IBDesignable
class GraphView: UIView {
    
    var deltaFromCenter: CGPoint?
    
    let axesDrawer = AxesDrawer()
    
    var originDataSource: OriginDataSource?
    
    var axesOrigin: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var useOldDelta: Bool = false
    
    var currentCenter: CGPoint! {
        willSet {
            if let cc = currentCenter {
                print("here")
                if newValue!.x != cc.x || newValue!.y != cc.y {
                    //rotation has occured
                    useOldDelta = true
                } else {
                    useOldDelta = false
                }
            }
        }
    }
    
    @IBInspectable
    var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    


    func graphXY(y:[Double], x: [Double]) -> [Double] {
        //use a delegate to grab y and x data.
        //DrawRect here to graph the entire graph
        return [0.0]
    }
    
    override func drawRect(rect: CGRect) {

        let originPoint = calculateOrigin()
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.drawAxesInRect(rect, origin: originPoint, pointsPerUnit: scale)
        if useOldDelta == false {
            originDeltaFromOldCenter(axesOrigin ?? currentCenter)
        }
    }
    
    func calculateOrigin() -> CGPoint {
        currentCenter = convertPoint(center, fromView: superview)
        let origin = axesOrigin ?? currentCenter
        let oldDelta = deltaFromCenter ?? currentCenter
        return useOldDelta ? oldDelta! + currentCenter : origin!
    }
    
    func originDeltaFromOldCenter(origin: CGPoint){
        let currentCenter = convertPoint(center, fromView: superview)
        let currentOrigin = axesOrigin ?? currentCenter
        deltaFromCenter = currentOrigin - currentCenter
    }
    

}

func - (a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x-b.x, y: a.y-b.y)
}

func + (a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x+b.x, y: a.y+b.y)
}