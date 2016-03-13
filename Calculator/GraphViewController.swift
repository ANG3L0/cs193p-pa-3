//
//  GraphViewController.swift
//  Calculator
//
//  Created by Angelo Wong on 3/9/16.
//  Copyright © 2016 Stanford. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphDataGenerator {
    
    let doubleTapGesture = UITapGestureRecognizer()
    
    private var xData: [CGFloat] = []
    private var yData: [CGFloat?] = []
    

    typealias PropertyList = AnyObject
    var program: PropertyList?
    private var graphingCalculatorBrain = CalculatorBrain()
    
    private var tp = translationProperties(minX: CGFloat(0.0), minY: CGFloat(0.0), maxX: CGFloat(0.0), maxY: CGFloat(0.0), startIdx: 0, endIdx: 0, viewSize: 0)
    
    struct translationProperties {
        var minX: CGFloat
        var minY: CGFloat
        var maxX: CGFloat
        var maxY: CGFloat
        var startIdx: Int
        var endIdx: Int
        var viewSize: Int
    }
    
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.graphDataGenerator = self
        }
    }
    
    @IBAction func changeAxesScale(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Changed:
            graphView?.scale *= gesture.scale
            gesture.scale = 1
        default: break
        }
    }
    @IBAction func panOrigin(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed:
            let translation = gesture.translationInView(graphView)
            let center = currentCenter(graphView)
            graphView.axesOrigin = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            gesture.setTranslation(CGPointZero, inView: graphView)
            graphView.dataIsOld = true
        default:
            break
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        let p = program as? [String]
//        print (p)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.addTarget(self, action: "updateOrigin:")
        view.addGestureRecognizer(doubleTapGesture)
        
    }
    
    func updateOrigin(gesture: UITapGestureRecognizer) {
        switch doubleTapGesture.state {
            case .Ended:
                graphView.axesOrigin = doubleTapGesture.locationInView(graphView)
            default: break
        }
    }
    
    //plan here is to generate X that is 5 times the width of the current view
    //example: if current view is showing x = -50 and x = -10 (distance of 40)
    //we'd like to generate X for -130 to 70.  That is,
    //distance = maxX - minX
    //generate from minX - distance*2 to maxX + distance*2
    private func generateX (sender: GraphView, scale pointsPerUnit: CGFloat) -> [CGFloat] {
        let origin = currentCenter(graphView)
        let (minX, maxX, _, _) = generateGraphViewWindowBounds(sender, origin: origin, pointsPerUnit: pointsPerUnit)
        let viewDistanceInUnits = maxX - minX
        let startX = minX - viewDistanceInUnits*CGFloat(2.0)
        let numXPoints = Int(ceil(sender.bounds.maxX - sender.bounds.minX) * CGFloat(5.0))
        let dx = CGFloat(1.0) / pointsPerUnit

        var xArray = Array<CGFloat>(count: numXPoints, repeatedValue: 0.0)
        var currentX = startX
        xArray[0] = currentX
        for i in 1..<numXPoints {
            currentX += dx
            xArray[i] = currentX
        }
        return xArray
    }
    
    private func generateYFrom(xArray: [CGFloat]) -> [CGFloat?] {
        graphingCalculatorBrain.program = program!
        var yArray = Array<CGFloat?>(count: xArray.count, repeatedValue: 0.0)
        var i = 0
        for x in xArray {
            graphingCalculatorBrain.variableValues["M"] = Double(x)
            if let y = graphingCalculatorBrain.evaluate() {
                yArray[i] = CGFloat(y)
            } else {
                yArray[i] = nil
            }
            i++
        }
        return yArray
    }
    

    private func translateXYToPoints(sender: GraphView, pointsPerUnit: CGFloat, x: [CGFloat], y: [CGFloat?]) -> ([CGFloat], [CGFloat?]){
        let origin = currentCenter(sender)
        xData = x
        yData = y
        (tp.minX, tp.maxX, _, tp.maxY) = generateGraphViewWindowBounds(sender, origin: origin, pointsPerUnit: pointsPerUnit)
        //Check bounds: if pass, then do translation, if fail, generate new X and Y
        tp.startIdx = Int((tp.minX - xData[0]) * pointsPerUnit)
        tp.viewSize = Int(sender.bounds.maxX - sender.bounds.minX)
        tp.endIdx = tp.startIdx + tp.viewSize - 1
        var xInPoints: [CGFloat]
        var yInPoints: [CGFloat?]
        print(origin)
        print("minX: \(tp.minX) maxX: \(tp.maxX); start: \(xData[0]) end: \(xData.last)")
        if tp.minX >= xData[0] && tp.maxX <= xData.last {
            (xInPoints, yInPoints) = doTranslation(yData, maxY: tp.maxY, startIdx: tp.startIdx, endIdx: tp.endIdx, pointsPerUnit: pointsPerUnit)
        } else {
            xData = generateX(sender, scale: pointsPerUnit)
            yData = generateYFrom(xData)
            (tp.minX, _, tp.maxX, tp.maxY) = generateGraphViewWindowBounds(sender, origin: origin, pointsPerUnit: pointsPerUnit)
            tp.startIdx = Int((tp.minX - xData[0]) * pointsPerUnit)
            tp.viewSize = Int(sender.bounds.maxX - sender.bounds.minX) //probably unnecessary
            tp.endIdx = tp.startIdx + tp.viewSize - 1
            (xInPoints, yInPoints) = doTranslation(yData, maxY: tp.maxY, startIdx: tp.startIdx, endIdx: tp.endIdx, pointsPerUnit: pointsPerUnit)
        }
        return (xInPoints, yInPoints)
    }
    
    func generatePointsToGraph(sender: GraphView, scale pointsPerUnit: CGFloat, scaleFactor: CGFloat, dataIsOld: Bool) -> (x: [CGFloat], y: [CGFloat?])? {
        if program != nil {
            if !dataIsOld {
                xData = generateX(sender, scale: pointsPerUnit)
                yData = generateYFrom(xData)
            }
            return translateXYToPoints(sender, pointsPerUnit: pointsPerUnit, x: xData, y: yData)
        }
        return nil
    }
    
    private func doTranslation(y: [CGFloat?], maxY: CGFloat, startIdx: Int, endIdx: Int, pointsPerUnit: CGFloat) -> (xInPoints: [CGFloat], yInPoints: [CGFloat?]) {
        let viewSize = endIdx - startIdx + 1
        var xInPoints = Array<CGFloat>(count: viewSize, repeatedValue: CGFloat(0.0))
        var yInPoints = Array<CGFloat?>(count: viewSize, repeatedValue: nil)
        var currentIdx = startIdx
        for i in 0..<viewSize {
            xInPoints[i] = CGFloat(i)
            let yResult = y[currentIdx]
            if yResult != nil && (yResult!.isNormal || yResult!.isZero) {
                yInPoints[i] = (maxY - yResult!) * pointsPerUnit
            } else {
                yInPoints[i] = nil
            }
            currentIdx++
        }
        return (xInPoints, yInPoints)
    }
    
    private func currentCenter(sender: GraphView) -> CGPoint {
        return  sender.calculateOrigin() ?? sender.convertPoint(sender.center, fromView: sender)
    }
    
    private func generateGraphViewWindowBounds(sender: GraphView, origin: CGPoint, pointsPerUnit: CGFloat) -> (minX: CGFloat, maxX: CGFloat, minY:CGFloat, maxY:CGFloat) {
        let graphViewBounds = sender.bounds
        let minX = (graphViewBounds.minX - origin.x) / pointsPerUnit
        let maxX = (graphViewBounds.maxX - origin.x) / pointsPerUnit
        let minY = (origin.y - graphViewBounds.maxY) / pointsPerUnit
        let maxY = (origin.y - graphViewBounds.minY) / pointsPerUnit
        return (minX, maxX, minY, maxY)
    }
    

}
