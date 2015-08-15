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
  
  override func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    super.touchesBegan(touches, withEvent: event)
    if touches.count != 1 {
      state = .Failed
    }
    state = .Began
  }
  
  override func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    super.touchesEnded(touches, withEvent: event)
    state = .Ended
  }
   
}
