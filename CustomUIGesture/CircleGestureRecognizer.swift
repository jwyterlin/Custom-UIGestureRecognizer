//
//  CircleGestureRecognizer.swift
//  CustomUIGesture
//
//  Created by Jhonathan Wyterlin on 15/08/15.
//  Copyright (c) 2015 raywenderlich. All rights reserved.
//

import UIKit

import UIKit.UIGestureRecognizerSubclass

class CircleGestureRecognizer: UIGestureRecognizer {
  
  var path = CGPathCreateMutable() // running CGPath - helps with drawing
  var fitResult = CircleResult() // information about how circle-like is the path
  var tolerance: CGFloat = 0.2 // circle wiggle room
  var isCircle = false
  
  private var touchedPoints = [CGPoint]() // point history
  
  override func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    super.touchesBegan(touches, withEvent: event)
    if touches.count != 1 {
      state = .Failed
    }
    state = .Began
    
    let window = view?.window
    if let touches = touches as? Set<UITouch>, loc = touches.first?.locationInView(window) {
      CGPathMoveToPoint(path, nil, loc.x, loc.y) // start the path
    }
    
  }
  
  override func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    super.touchesEnded(touches, withEvent: event)
    
    // now that the user has stopped touching, figure out if the path was a circle
    fitResult = fitCircle(touchedPoints)
    
    // make sure there are no points in the middle of the circle
    let hasInside = anyPointsInTheMiddle()
    
    let percentOverlap = calculateBoundingOverlap()
    isCircle = fitResult.error <= tolerance && !hasInside && percentOverlap > (1-tolerance)
    
    state = isCircle ? .Ended : .Failed
    
  }
  
  override func touchesMoved(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    super.touchesMoved(touches, withEvent: event)
    
    // Apple recommends you first check that the gesture hasn’t already failed; 
    // if it has, don’t continue to process the other touches. 
    // Touch events are buffered and processed serially in the event queue. 
    // If a the user moves the touch fast enough, 
    // there could be touches pending and processed after the gesture has already failed.
    if state == .Failed {
      return
    }
    
    // To make the math easy, convert the tracked points to window coordinates. 
    // This makes it easier to track touches that don’t line up within any particular view, 
    // so the user can make a circle outside the bounds of the image, 
    // and have it still count towards selecting that image.
    let window = view?.window
    if let touches = touches as? Set<UITouch>, loc = touches.first?.locationInView(window) {
      
      // Add the points to the array.
      touchedPoints.append(loc)
      
      CGPathAddLineToPoint(path, nil, loc.x, loc.y)
      
      // Update the state to .Changed. This has the side effect of calling the target action as well.
      state = .Changed
      
    }
  }
  
  override func reset() {
    super.reset()
    touchedPoints.removeAll(keepCapacity: true)
    path = CGPathCreateMutable()
    isCircle = false
    state = .Possible
  }
  
  private func anyPointsInTheMiddle() -> Bool {

    // Calculates a smaller exclusion zone. 
    // The tolerance variable will provide enough space for a reasonable, but messy circle, 
    // but still have enough room to exclude any obviously non-circle shapes with points in the middle.
    let fitInnerRadius = fitResult.radius / sqrt(2) * tolerance

    // To simplify the amount of code required, this constructs a smaller square centered on the circle.
    let innerBox = CGRect(
      x: fitResult.center.x - fitInnerRadius,
      y: fitResult.center.y - fitInnerRadius,
      width: 2 * fitInnerRadius,
      height: 2 * fitInnerRadius)
    
    // This loops over the points and checks if the point is contained within innerBox.
    var hasInside = false
    
    for point in touchedPoints {
      
      if innerBox.contains(point) {
      
        hasInside = true
        break
        
      }
      
    }
    
    return hasInside
    
  }
  
  private func calculateBoundingOverlap() -> CGFloat {
    
    // Find the bounding box of the circle fit and the user’s path. 
    // This uses CGPathGetBoundingBox to handle the tricky math, 
    // since the touch points were also captured as part of the CGMutablePath path variable.
    let fitBoundingBox = CGRect(
      x: fitResult.center.x - fitResult.radius,
      y: fitResult.center.y - fitResult.radius,
      width: 2 * fitResult.radius,
      height: 2 * fitResult.radius)
    let pathBoundingBox = CGPathGetBoundingBox(path)
    
    // Calculate the rectangle where the two paths overlap using the rectByIntersecting method on CGRect
    let overlapRect = fitBoundingBox.rectByIntersecting(pathBoundingBox)
    
    // Figure out what percentage the two bounding boxes overlap as a percentage of area. 
    // This percentage will be in the 80%-100% for a good circle gesture. 
    // In the case of the short arc shape, it will be very, very tiny!
    let overlapRectArea = overlapRect.width * overlapRect.height
    let circleBoxArea = fitBoundingBox.height * fitBoundingBox.width
    
    let percentOverlap = overlapRectArea / circleBoxArea
    return percentOverlap
  }
   
}
