//
//  CircularSlider.swift
//  Circular Slider
//
//  Created by Rob Norback on 1/9/16.
//  Copyright © 2016 Rob Norback. All rights reserved.
//

import UIKit

// MARK: Math Helpers

func DegreesToRadians(value:Double) -> Double {
    return value * M_PI / 180.0
}

func RadiansToDegrees(value:Double) -> Double {
    return value * 180 / M_PI
}

func Square(value:CGFloat) -> CGFloat {
    return value * value
}

class CircularSlider: UIControl {

    var lineWidth:CGFloat = 3 {
        didSet {
            // Redraw
            setNeedsDisplay()
        }
    }
    var angleInDegrees:Int = 0 {
        didSet {
            // Redraw
            setNeedsDisplay()
        }
    }
    var handleRadius:CGFloat = 20 {
        didSet {
            let sideLength = (sliderRadius + edgeInset + handleRadius) * 2
            self.frame = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)
            self.center = sliderCenter
            // Redraw
            setNeedsDisplay()
        }
    }
    
    private let edgeInset:CGFloat = 5
    private var sliderRadius:CGFloat = 0
    private var sliderCenter:CGPoint = CGPoint(x: 0, y: 0)
    private var handleCenter:CGPoint = CGPoint(x: 0, y: 0)
    
    init(radius: CGFloat, center:CGPoint) {
        let sideLength = (radius + edgeInset + handleRadius) * 2
        super.init(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))
        self.center = center
        sliderCenter = center
        sliderRadius = radius
        backgroundColor = UIColor.clearColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sliderRadius = self.frame.width/2 - edgeInset - handleRadius
        backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Allowing touches to pass through
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        
//        for subview in subviews as [UIView] {
//            if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
//                return true
//            }
//        }
        
        // Allow any touch points that are not inside the slider handle to pass through to the next view
        if Square(point.x - handleCenter.x) + Square(point.y - handleCenter.y) < Square(handleRadius) {
            return true
        }

        return false
    }
    
    
    //MARK: Touch Tracking
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        let location = touch.locationInView(self)
        
        // Make sure touch is within the handle
        if Square(location.x - handleCenter.x) + Square(location.y - handleCenter.y) < Square(handleRadius) {
            return true
        }
        
        return false
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        
        let lastPoint = touch.locationInView(self)
        self.moveHandle(lastPoint)
        self.sendActionsForControlEvents(.ValueChanged)
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)
    }
    
    //MARK: Drawing the control
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let context = UIGraphicsGetCurrentContext()!
        
        // Draw the slider
        CGContextAddArc(context, frame.width/2, frame.height/2, sliderRadius, 0, CGFloat(M_PI*2), 0)
        UIColor.blackColor().set()
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetLineCap(context, CGLineCap.Butt)
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
        
        drawTheHandle(context)
    }
    
    
    func drawTheHandle(ctx:CGContextRef){
        CGContextSaveGState(ctx)
        
        // Set the handle shadow
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, UIColor.blackColor().CGColor)
        
        // Get the handle position
        handleCenter = pointFromAngleInDegrees(angleInDegrees)

        // Draw the handle
        UIColor.whiteColor().set()
        CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x - handleRadius, handleCenter.y - handleRadius, handleRadius*2, handleRadius*2))
        
        CGContextRestoreGState(ctx)
    }
    
    // Move the handle
    func moveHandle(lastPoint:CGPoint) {
        
        // Circle center
        let centerPoint = CGPointMake(frame.width/2, frame.height/2)
        let currentAngle:Double = angleFromNorth(centerPoint, p2:lastPoint)
        
        //Store the new angle
        angleInDegrees = Int(round(currentAngle))

        // Redraw
        setNeedsDisplay()
    }
    
    
    // Given the angle get the position on the circumference
    func pointFromAngleInDegrees(angleInDegrees:Int) -> CGPoint {
        
        // Circle center
        let centerPoint = CGPointMake(frame.width/2, frame.height/2)
        
        // Offset the angle by -90 degrees
        let angleInRadians = DegreesToRadians(Double(angleInDegrees-90))
        
        // -1 to 1
        let xValue = CGFloat(cos(angleInRadians))
        let yValue = CGFloat(sin(angleInRadians))
        
        let x = round(sliderRadius * xValue + centerPoint.x)
        let y = round(sliderRadius * yValue + centerPoint.y)
        
        return CGPoint(x: x, y: y)
    }

    // Find the angle from north given two points
    func angleFromNorth(p1:CGPoint, p2:CGPoint) -> Double {
        let vector = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        let magnetude:CGFloat = Square(Square(vector.x) + Square(vector.y))
        let unitVector = CGPoint(x: vector.x/magnetude,y: vector.y/magnetude)
        let angleInRadians = Double(atan2(unitVector.y, unitVector.x))
        let angleInDegrees = RadiansToDegrees(angleInRadians) + 90 //shift by 90
        return (angleInDegrees > 0 ? angleInDegrees : angleInDegrees + 360)
    }
}