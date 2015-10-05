//
//  DraggableView.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

let ACTION_MARGIN: Float = 120      //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
let SCALE_STRENGTH: Float = 4       //%%% how quickly the card shrinks. Higher = slower shrinking
let SCALE_MAX:Float = 0.93          //%%% upper bar for how much the card shrinks. Higher = shrinks less
let ROTATION_MAX: Float = 1         //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
let ROTATION_STRENGTH: Float = 320  //%%% strength of rotation. Higher = weaker rotation
let ROTATION_ANGLE: Float = 3.14/8  //%%% Higher = stronger rotation angle

protocol DraggableViewDelegate {
    func cardSwipedLeft(card: UIView)
    func cardSwipedRight(card: UIView)
}

class DraggableView: UIView {
    var delegate: DraggableViewDelegate!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var originPoint: CGPoint!
    var overlayView: OverlayView!
    var information: UILabel!
    var xFromCenter: Float!
    var yFromCenter: Float!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()

        information = UILabel(frame: CGRectMake(0, 50, self.frame.size.width, 100))
        information.text = "no info given"
        information.textAlignment = NSTextAlignment.Center
        information.textColor = UIColor.blackColor()

        self.backgroundColor = UIColor.whiteColor()

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "beingDragged:")

        self.addGestureRecognizer(panGestureRecognizer)
        self.addSubview(information)

        overlayView = OverlayView(frame: CGRectMake(self.frame.size.width/2-100, 0, 100, 100))
        overlayView.alpha = 0
        self.addSubview(overlayView)

        xFromCenter = 0
        yFromCenter = 0
    }

    func setupView() {
        self.layer.cornerRadius = 4;
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowOffset = CGSizeMake(1, 1);
    }

    func beingDragged(gestureRecognizer: UIPanGestureRecognizer) {
        xFromCenter = Float(gestureRecognizer.translationInView(self).x)
        yFromCenter = Float(gestureRecognizer.translationInView(self).y)
        
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.Began:
            self.originPoint = self.center
        case UIGestureRecognizerState.Changed:
            let rotationStrength: Float = min(xFromCenter/ROTATION_STRENGTH, ROTATION_MAX)
            let rotationAngle = ROTATION_ANGLE * rotationStrength
            let scale = max(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)

            self.center = CGPointMake(self.originPoint.x + CGFloat(xFromCenter), self.originPoint.y + CGFloat(yFromCenter))

            let transform = CGAffineTransformMakeRotation(CGFloat(rotationAngle))
            let scaleTransform = CGAffineTransformScale(transform, CGFloat(scale), CGFloat(scale))
            self.transform = scaleTransform
            self.updateOverlay(CGFloat(xFromCenter))
        case UIGestureRecognizerState.Ended:
            self.afterSwipeAction()
        case UIGestureRecognizerState.Possible:
            fallthrough
        case UIGestureRecognizerState.Cancelled:
            fallthrough
        case UIGestureRecognizerState.Failed:
            fallthrough
        default:
            break
        }
    }

    func updateOverlay(distance: CGFloat) {
        if distance > 0 {
            overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeRight)
        } else {
            overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeLeft)
        }
        overlayView.alpha = CGFloat(min(fabsf(Float(distance))/100, 0.4))
    }

    func afterSwipeAction() {
        let floatXFromCenter = Float(xFromCenter)
        if floatXFromCenter > ACTION_MARGIN {
            completeSwipeRight()
        } else if floatXFromCenter < -ACTION_MARGIN {
            completeSwipeLeft()
        } else {
            UIView.animateWithDuration(0.3, animations: {() in
                self.center = self.originPoint
                self.transform = CGAffineTransformMakeRotation(0)
                self.overlayView.alpha = 0
            })
        }
    }

    func completeSwipeRight() {
        completeSwipe(finishX:600, rotateRadians:1, callback:delegate.cardSwipedRight)
    }

    func completeSwipeLeft() {
        completeSwipe(finishX:-600, rotateRadians:-1, callback:delegate.cardSwipedLeft)
    }

    func completeSwipe(finishX finishX: CGFloat, rotateRadians: CGFloat, callback: UIView -> ()) {
        let finishPoint = CGPointMake(finishX, self.center.y)
        UIView.animateWithDuration(0.3,
            animations: {
                self.center = finishPoint
                self.transform = CGAffineTransformMakeRotation(rotateRadians)
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        callback(self)
    }
}