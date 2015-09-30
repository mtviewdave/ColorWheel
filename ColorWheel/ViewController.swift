//
//  ViewController.swift
//  ColorWheel
//
//  Created by Metebelis Labs LLC on 6/21/15.
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

// Demonstrates ICColorWheel

class ViewController: UIViewController {
    
    @IBOutlet var colorWheelButton : UIButton!  // Button to display the color wheel
    @IBOutlet var colorIndicator : UIView!      // Shows the currently selected color
    
    let colorWheelSize = CGFloat(250)
    var colorWheel : ICColorWheel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add some shadow to distinguish the (potentially white) view 
        // from the (white) background
        colorIndicator.layer.shadowColor = UIColor.blackColor().CGColor
        colorIndicator.layer.shadowOpacity = 0.75
        colorIndicator.layer.shadowRadius = 3
        colorIndicator.layer.shadowOffset = CGSizeMake(2,2)
        
        colorIndicator.layer.cornerRadius = 2
        
        // Default color is black
        colorIndicator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        // Create a color wheel image for the button
        let colorWheelButtonImage = ICColorWheel.createColorWheelImage(colorWheelButton.frame.size.width, withShadow: true)
        colorWheelButton.setBackgroundImage(colorWheelButtonImage, forState: .Normal)
        colorWheelButton.setBackgroundImage(colorWheelButtonImage, forState: .Disabled)

        // We have a "B" for the title in the nib so we can see the button IB
        // Delete it here
        
        colorWheelButton.setTitle("", forState: .Normal)
    }

    @IBAction func colorWheelButtonTapped() {
        self.colorWheelButton.enabled = false
        
        let viewWidth = self.view.bounds.width
        let viewHeight = self.view.bounds.height
        
        let frame = CGRectMake((viewWidth - colorWheelSize)/2, (viewHeight-colorWheelSize)/2, colorWheelSize, colorWheelSize)
        
        let colorWheel = ICColorWheel(frame: frame, selectedColor: colorIndicator.backgroundColor!) { (sender, chosenColor) -> () in
            self.colorIndicator.backgroundColor = chosenColor
            self.dismissColorWheel()
        }
        self.colorWheel = colorWheel
        self.view.addSubview(colorWheel)
        
        
        // We reveal the color wheel by "spinning" it up from the button to the 
        // center of the view
        let buttonY = colorWheelButton.convertRect(colorWheelButton.bounds, toView: self.view).origin.y
        
        
        var xform = CGAffineTransformIdentity
        xform = CGAffineTransformTranslate(xform, 0, buttonY - colorWheel.frame.origin.y - (colorWheel.frame.size.height - colorWheelButton.frame.size.height)/2)
        
        // Grow it from 1/10th size, and spin it 180 degrees
        xform = CGAffineTransformScale(xform, 0.1, 0.1)
        xform = CGAffineTransformRotate(xform, CGFloat(M_PI))
        
        colorWheel.transform = xform
        
        // Also fade it in
        colorWheel.alpha = 0
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            colorWheel.transform = CGAffineTransformIdentity
            colorWheel.alpha = 1
        }, completion:nil)
    }
    
    
    // When we get a touch, dismiss the color wheel
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if colorWheel != nil {
            dismissColorWheel()
        } else {
            super.touchesBegan(touches, withEvent: event)
        }
    }
    
    // Fade the color wheel away and remove it
    func dismissColorWheel() {
        if let colorWheel = self.colorWheel {
            UIView.animateWithDuration(0.2, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                colorWheel.alpha = 0
                }, completion: { (done) -> Void in
                    colorWheel.removeFromSuperview()
                    self.colorWheel = nil
                    self.colorWheelButton.enabled = true
            })
        }
    }
}

