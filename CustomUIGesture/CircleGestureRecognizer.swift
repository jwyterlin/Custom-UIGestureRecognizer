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
  }
  
  override func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    super.touchesEnded(touches, withEvent: event)
    
    // now that the user has stopped touching, figure out if the path was a circle
    fitResult = fitCircle(touchedPoints)
    
    isCircle = fitResult.error <= tolerance
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
      // Update the state to .Changed. This has the side effect of calling the target action as well.
      state = .Changed
      
    }
  }
   
}
