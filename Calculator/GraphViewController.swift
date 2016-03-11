//
//  GraphViewController.swift
//  Calculator
//
//  Created by Angelo Wong on 3/9/16.
//  Copyright © 2016 Stanford. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    let doubleTapGesture = UITapGestureRecognizer()
    
    typealias PropertyList = AnyObject
    var program: PropertyList?
    
    @IBOutlet weak var graphView: GraphView!
    
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
            graphView.axesOrigin = gesture.locationInView(graphView)
        default:
            break
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let p = program as? [String]
        print (p)
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

}
