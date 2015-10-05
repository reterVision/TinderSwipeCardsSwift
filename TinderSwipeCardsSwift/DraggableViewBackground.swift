//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

class DraggableViewBackground: UIView {
    private let MAX_BUFFER_SIZE = 2
    private let CARD_HEIGHT: CGFloat = 386
    private let CARD_WIDTH: CGFloat = 290

    private var allCards: [DraggableView]!
    private var cardsLoadedIndex: Int!
    private var loadedCards: [DraggableView]!

    private var menuButton: UIButton!
    private var messageButton: UIButton!
    private var checkButton: UIButton!
    private var xButton: UIButton!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        super.layoutSubviews()
        self.setupView()

        allCards = []
        loadedCards = []
        cardsLoadedIndex = 0
        self.loadCards(["first", "second", "third", "fourth", "last"])
    }

    private func setupView() {
        self.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)

        xButton = UIButton(frame: CGRectMake((self.frame.size.width - CARD_WIDTH)/2 + 35, self.frame.size.height/2 + CARD_HEIGHT/2 + 10, 59, 59))
        xButton.setImage(UIImage(named: "xButton"), forState: UIControlState.Normal)
        xButton.addTarget(self, action: "fakeSwipeLeft", forControlEvents: UIControlEvents.TouchUpInside)

        checkButton = UIButton(frame: CGRectMake(self.frame.size.width/2 + CARD_WIDTH/2 - 85, self.frame.size.height/2 + CARD_HEIGHT/2 + 10, 59, 59))
        checkButton.setImage(UIImage(named: "checkButton"), forState: UIControlState.Normal)
        checkButton.addTarget(self, action: "fakeSwipeRight", forControlEvents: UIControlEvents.TouchUpInside)

        self.addSubview(xButton)
        self.addSubview(checkButton)
    }

    private func loadCards(labels: [String]) {
        if labels.count > 0 {
            let numLoadedCardsCap = min(labels.count, MAX_BUFFER_SIZE)
            for var i = 0; i < labels.count; i++ {
                let newCard = createDraggableViewWithLabel(labels[i])
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                }
            }

            for var i = 0; i < loadedCards.count; i++ {
                if i > 0 {
                    self.insertSubview(loadedCards[i], belowSubview: loadedCards[i - 1])
                } else {
                    self.addSubview(loadedCards[i])
                }
                cardsLoadedIndex = cardsLoadedIndex + 1
            }
        }
    }

    private func createDraggableViewWithLabel(label: String) -> DraggableView {
        let frame = CGRectMake((self.frame.size.width - CARD_WIDTH)/2,
                               (self.frame.size.height - CARD_HEIGHT)/2,
                               CARD_WIDTH, CARD_HEIGHT)
        let draggableView = DraggableView(frame: frame, label: label, delegate: self)
        return draggableView
    }

    func fakeSwipeRight() {
        if loadedCards.count > 0 {
            let dragView: DraggableView = loadedCards[0]
            dragView.completeSwipeRight()
        }
    }

    func fakeSwipeLeft() {
        if loadedCards.count > 0 {
            let dragView: DraggableView = loadedCards[0]
            dragView.completeSwipeLeft()
        }
    }
}

extension DraggableViewBackground : DraggableViewDelegate {
    func cardSwipedLeft(card: UIView) {
        loadAnotherCard()
    }

    func cardSwipedRight(card: UIView) {
        loadAnotherCard()
    }

    private func loadAnotherCard() {
        loadedCards.removeAtIndex(0)

        if cardsLoadedIndex < allCards.count {
            let nextCard = allCards[cardsLoadedIndex]
            loadedCards.append(nextCard)
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(nextCard, belowSubview: loadedCards[loadedCards.count - 2])
        }
    }
}
