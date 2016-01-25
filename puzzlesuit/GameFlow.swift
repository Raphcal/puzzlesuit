//
//  GameFlow.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

enum GameFlowState {
    
    case Initial, Play, Attach, Resolve, Chain
    
}

class GameFlow {
    
    let board : Board
    let generator : Generator
    let generatorState = GeneratorState()
    
    var state = GameFlowState.Initial
    
    var hand = [Sprite]()
    
    init(board: Board, generator: Generator) {
        self.board = board
        self.generator = generator
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        switch state {
        case .Initial:
            updateInitial()
        case .Play:
            break
        default:
            break
        }
    }
    
    private func updateInitial() {
        let cards = board.spritesForMainCard(nextCard(), andExtraCard: nextCard())
        
        hand.appendContentsOf(cards)
        
        self.state = .Play
    }
    
    private func updatePlay() {
        for sprite in hand {
            if board.spriteBelowSprite(sprite) != nil {
                (sprite.motion as? PlayerMotion)?.linkedSprite.motion = FallMotion()
                sprite.motion = NoMotion()
                board.attachSprite(sprite)
            }
        }
    }
    
    private func nextCard() -> Card {
        return generator.cardForState(generatorState)
    }
    
}