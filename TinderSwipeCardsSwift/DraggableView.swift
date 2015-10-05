//
//  DraggableView.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

/// Distance from center where the action applies.
/// Higher = swipe further in order for the action to be called.
let ACTION_MARGIN: CGFloat = 120
/// How quickly the card shrinks. Higher = slower shrinking.
let SCALE_STRENGTH: CGFloat = 4
/// Upper bar for how much the card shrinks. Higher = shrinks less.
let SCALE_MAX:CGFloat = 0.93
/// Maximum rotation allowed in radians. Higher = card can rotate further.
let ROTATION_MAX: CGFloat = 1
/// Strength of rotation. Higher = weaker rotation.
let ROTATION_STRENGTH: CGFloat = 320
/// Higher = stronger rotation angle
let ROTATION_ANGLE: CGFloat = 3.14/8
let MAX_OVERLAY_ALPHA: CGFloat = 0.4

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
    var xFromDragOrigin: CGFloat!

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

        xFromDragOrigin = 0
    }

    func setupView() {
        self.layer.cornerRadius = 4;
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowOffset = CGSizeMake(1, 1);
    }

    func beingDragged(gestureRecognizer: UIPanGestureRecognizer) {
        xFromDragOrigin = gestureRecognizer.translationInView(self).x
        let yFromDragOrigin = gestureRecognizer.translationInView(self).y
        
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.Began:
            self.originPoint = self.center
        case UIGestureRecognizerState.Changed:
            let rotationStrength = min(xFromDragOrigin/ROTATION_STRENGTH, ROTATION_MAX)
            let rotationAngle = ROTATION_ANGLE * rotationStrength
            let scale = max(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)

            self.center = CGPointMake(self.originPoint.x + xFromDragOrigin, self.originPoint.y + yFromDragOrigin)

            let transform = CGAffineTransformMakeRotation(rotationAngle)
            let scaleTransform = CGAffineTransformScale(transform, scale, scale)
            self.transform = scaleTransform
            self.updateOverlay(xFromDragOrigin)
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
        overlayView.alpha = min(fabs(distance)/100, MAX_OVERLAY_ALPHA)
    }

    func afterSwipeAction() {
        if xFromDragOrigin > ACTION_MARGIN {
            completeSwipeRight()
        } else if xFromDragOrigin < -ACTION_MARGIN {
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
        overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeRight)
        completeSwipe(finishX:600, rotateRadians:ROTATION_MAX, callback:delegate.cardSwipedRight)
    }

    func completeSwipeLeft() {
        overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeLeft)
        completeSwipe(finishX:-600, rotateRadians:-ROTATION_MAX, callback:delegate.cardSwipedLeft)
    }

    func completeSwipe(finishX finishX: CGFloat,
                       rotateRadians: CGFloat,
                       callback: UIView -> ()) {
        let finishPoint = CGPointMake(finishX, self.center.y)
        UIView.animateWithDuration(0.3,
            animations: {
                self.center = finishPoint
                self.transform = CGAffineTransformMakeRotation(rotateRadians)
                self.overlayView.alpha = MAX_OVERLAY_ALPHA
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        callback(self)
    }
}