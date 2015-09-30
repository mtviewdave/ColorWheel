//
//  ICColorWheel.swift
//  ingerchat
//
//  Created by Metebelis Labs LLC on 6/6/15.
//
//  Copyright 2015 Metebelis Labs LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


import UIKit

private let colors = [UIColor.redColor(),UIColor.orangeColor(),UIColor.yellowColor(),UIColor.greenColor(),UIColor.cyanColor(),UIColor.blueColor(),UIColor.purpleColor(),UIColor.brownColor(),
    // White, grey and black are specified explicitly, because if we use the
    // iOS convenience functions, then the colors are derived from the White color
    // space and not the RGB color space, which prevents the comparison loop in
    // init() from working properly.
    // (Unless the caller also uses the White color space; sigh)
    UIColor(red: 0, green: 0, blue: 0, alpha: 1),
    UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),
    UIColor(red: 1, green: 1, blue: 1, alpha: 1)]

private let interiorHoleFraction = CGFloat(1.0/6.0)
private let paddingForShadow = CGFloat(0.95)
private let numRadiansFullCircle = CGFloat(2.0*M_PI)

private func deg2rad(degress : CGFloat) -> CGFloat {
    return degress/numRadiansFullCircle
}

class ICColorWheel: UIView {
    let imageView = UIImageView() // Holds the color wheel image
    var didSelectCallback : ((ICColorWheel,UIColor) -> ())?
    
    init(frame: CGRect,selectedColor : UIColor,didSelectCallback : ((ICColorWheel,UIColor) -> ())) {
        super.init(frame:frame)
        
        self.didSelectCallback = didSelectCallback
        imageView.frame = self.bounds

        self.addSubview(imageView)
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 10.0
        
        var wedge : Int = 0
        var selectedWedge : Int = 0
        
        self.userInteractionEnabled = true
        
        // We initialize "selectedWedge" by iterating over the colors looking
        // for a match
        // This works for the color set available, though if we add more arbitrary
        // colors, I'm not convinced it would continue to (due to colors being specified 
        // fractionally)
        for color in colors {
            if selectedColor.isEqual(color) {
                selectedWedge = wedge
                break
            }
            wedge++
        }
        
        imageView.image = ICColorWheel.createColorWheelImage(self.bounds.width, withShadow:false,selectedWedge: selectedWedge)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    // The next two functions draw the wheel image
    // They're class functions so they can be used to draw 
    // an image for a button in addition to the image for this view.
    
    // Add a wedge from startAngle to endAngle, with a hole of
    // "interiorHoleRadius" radius
    // Wedge is either
    //  Solid color (fill == true)
    //  Fat outline (fill == false)
    class func addWedge(startAngle : CGFloat,endAngle : CGFloat,color : CGColor,size:CGFloat,radius:CGFloat,fill : Bool) {
        let context = UIGraphicsGetCurrentContext()
        let interiorHoleRadius = size * interiorHoleFraction
        let centerX = size/2
        let centerY = size/2
        
        // The beginning and end points on the interior circle
        let startPoint = CGPointMake(centerX + interiorHoleRadius * cos(startAngle), centerY + interiorHoleRadius * sin(startAngle));
        let endPoint = CGPointMake(centerX + interiorHoleRadius * cos(endAngle), centerY + interiorHoleRadius * sin(endAngle));
        
        // Used to define the wedge outline style. Not used
        // if we're doing a colored wedge
        CGContextSetLineWidth(context, 10)
        CGContextSetLineJoin(context, CGLineJoin.Round)
        
        
        let path = CGPathCreateMutable()
        
        // Goes from starting point on inner circle
        CGPathMoveToPoint(path, nil,startPoint.x, startPoint.y)
        
        // Up to the corresponding point on the outer circle
        let outerPoint = CGPointMake(centerX + radius * cos(startAngle), centerY + radius * sin(startAngle));
        CGPathAddLineToPoint(path, nil,outerPoint.x, outerPoint.y)
        
        // Draws an arc the specified number of degrees over
        CGPathAddArc(path, nil,centerX, centerY, radius, startAngle, endAngle, (startAngle > endAngle))
        
        // We're now "directly over" endPoint, so draw a straight line to it
        CGPathAddLineToPoint(path, nil,endPoint.x, endPoint.y)
        
        // Draws an arc back to startPoint
        CGPathAddArc(path, nil,centerX, centerY, interiorHoleRadius, endAngle, startAngle, (endAngle > startAngle))
        
        CGPathCloseSubpath(path)
        CGContextAddPath(context, path)
        
        
        if fill {
            CGContextSetFillColorWithColor(context, color)
            CGContextFillPath(context)
        } else {
            CGContextSetStrokeColorWithColor(context, color)
            CGContextStrokePath(context)
        }
    }
    
    // Create the image for the entire color wheel, with (optionally) the
    // selected color outlined in a light blue
    class func createColorWheelImage(size : CGFloat,withShadow:Bool,selectedWedge : Int? = nil) -> UIImage {
        
        // We leave some space for the shadow to show
        
        // Note that for this application, there will always be a shadow. The only question
        // is whether we draw it (withShadow=true), or whether it's added to an image
        // layer by the caller
        let radius = (size * paddingForShadow)/2.0
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size,size), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextBeginPath(context)

        // The number of radians each wedge consists of
        let angleStep  = numRadiansFullCircle / CGFloat(colors.count)
        
        // Draw each colored wedge
        // The number of wedges depends on the number of colors
        for var s=0,angle=CGFloat(0);s<colors.count;s++,angle+=angleStep {
            addWedge(angle, endAngle: angle + angleStep, color: colors[s].CGColor,size:size,radius:radius,fill:true)
        }
        
        // Draw the selection outline if required
        if let selectedWedge = selectedWedge {
            let outlineColor = UIColor(red:32.0/255.0,green:64.0/255.0,blue:128.0/255.0,alpha:1.0).CGColor
            
            CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 5, UIColor.blackColor().CGColor)
            addWedge(angleStep*CGFloat(selectedWedge), endAngle: (angleStep)*(1+CGFloat(selectedWedge)), color: outlineColor,size:size,radius:radius,fill:false)
        }
        
        var colorWheelImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // If the caller asked for a shadow, re-render the image with a shadow
        if withShadow {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(size,size), false, 0)
            
            let context = UIGraphicsGetCurrentContext()
            CGContextSetShadowWithColor(context, CGSizeMake(0,0), 2, UIColor.blackColor().CGColor)
            colorWheelImage.drawInRect(CGRectMake(0, 0, size, size))
            colorWheelImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        return colorWheelImage
    }
    
    // Input processing
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            // Grab the first touch and find its position in the view
            let loc = touch.locationInView(self)
            let center = CGPointMake(self.bounds.width/2, self.bounds.height/2)
            
            // Map the (X,Y) to the angle (0..359)
            var angle = atan2(loc.y-center.y, loc.x-center.x)
            if(angle < 0) {
                angle += numRadiansFullCircle
            }
            let selectedWedge = Int(CGFloat(colors.count)*deg2rad(angle))
            
            // Update the selected color
            imageView.image = ICColorWheel.createColorWheelImage(self.bounds.size.width,withShadow:false, selectedWedge: selectedWedge)
            
            didSelectCallback?(self,colors[selectedWedge])
        } else {
            super.touchesBegan(touches, withEvent: event)
        }
    }
    
}
