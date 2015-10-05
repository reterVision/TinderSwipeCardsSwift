//
//  OverlayView.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

enum GGOverlayViewMode {
    case GGOverlayViewModeLeft
    case GGOverlayViewModeRight
}

class OverlayView: UIView{
    private var mode = GGOverlayViewMode.GGOverlayViewModeLeft
    private var imageView: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        imageView = UIImageView(image: UIImage(named: "noButton"))
        self.addSubview(imageView)
    }

    func setMode(newMode: GGOverlayViewMode) {
        if mode != newMode {
            mode = newMode
            if mode == GGOverlayViewMode.GGOverlayViewModeLeft {
                imageView.image = UIImage(named: "noButton")
            } else {
                imageView.image = UIImage(named: "yesButton")
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRectMake(50, 50, 100, 100)
    }
}