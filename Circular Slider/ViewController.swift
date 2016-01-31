//
//  ViewController.swift
//  Circular Slider
//
//  Created by Rob Norback on 1/9/16.
//  Copyright © 2016 Rob Norback. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var smallCS:CircularSlider = CircularSlider()
    var bigCS:CircularSlider = CircularSlider()
    var prevBigAngleInDegrees:Int = 0
    var prevSmallAngleInDegrees:Int = 0
    var meditationTime:Int = 3600
    var preparationTime:Int {
        return Int(floatPrepTime)
    }
    var floatPrepTime:Double = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewCenter = CGPointMake(view.frame.midX, view.frame.midY)
        bigCS = CircularSlider(radius: 137.5, center: viewCenter)
        bigCS.angleInDegrees = meditationTime % 360
        bigCS.lineWidth = 2
        bigCS.handleRadius = 20
        prevBigAngleInDegrees = bigCS.angleInDegrees
        bigCS.addTarget(self, action: Selector("bigCircleSliderChanged:"), forControlEvents: .ValueChanged)
        
        smallCS = CircularSlider(radius: 95.5, center: viewCenter)
        smallCS.angleInDegrees = (preparationTime % 60) * 6
        smallCS.lineWidth = 2
        smallCS.handleRadius = 20
        prevSmallAngleInDegrees = smallCS.angleInDegrees
        smallCS.addTarget(self, action: Selector("smallCircleSliderChanged:"), forControlEvents: .ValueChanged)
        
        let button = UIButton(frame: CGRect(x: 40, y: 40, width: 100, height: 40))
        button.backgroundColor = UIColor.blueColor()
        button.setTitle("Hide It", forState: .Normal)
        button.addTarget(self, action: Selector("buttonPressed"), forControlEvents: .TouchUpInside)
        view.addSubview(button)
        
        view.addSubview(bigCS)
        view.addSubview(smallCS)
    }
    
    func buttonPressed() {
        smallCS.hidden = !smallCS.hidden
    }
    
    func bigCircleSliderChanged(cs:CircularSlider) {
        var delta = cs.angleInDegrees - prevBigAngleInDegrees
        // Take care of the 360 to 0 gap
        if delta > 180 { delta -= 360 }
        else if delta < -180 { delta += 360 }
        // Increment timeInSeconds
        meditationTime += delta * 10
        prevBigAngleInDegrees = cs.angleInDegrees
        print(meditationTime)
    }
    
    func smallCircleSliderChanged(cs:CircularSlider) {
        var delta:Double = Double(cs.angleInDegrees - prevSmallAngleInDegrees)
        // Take care of the 360 to 0 gap
        if delta > 180 { delta -= 360 }
        else if delta < -180 { delta += 360 }
        // Increment timeInSeconds
        floatPrepTime += delta / 6
        prevSmallAngleInDegrees = cs.angleInDegrees
        print(preparationTime)
    }
}

