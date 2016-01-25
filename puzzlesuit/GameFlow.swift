//
//  GameFlow.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

enum GameFlowState {
    
    case Initial, Play, Chain, Resolve, Lost
    
}

enum GameError : ErrorType {
    
    case Lost
    
}

class GameFlow {
    
    let board : Board
    let generator : Generator
    let generatorState = GeneratorState()
    
    var state = GameFlowState.Initial
    
    var hand = [Sprite]()
    
    init() {
        self.board = Board()
        self.generator = Generator()
    }
    
    init(board: Board, generator: Generator) {
        self.board = board
        self.generator = generator
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        switch state {
        case .Initial:
            updateInitial()
        case .Play:
            updatePlay()
        case .Chain:
            updateChain()
        case .Resolve:
            updateResolve()
        case .Lost:
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
            if board.isAboveSomething(sprite) {
                (sprite.motion as? PlayerMotion)?.linkedSprite.motion = FallMotion()
                sprite.motion = NoMotion()
                do {
                    try board.attachSprite(sprite)
                    hand.removeAll()
                    self.state = .Chain
                } catch {
                    self.state = .Lost
                }
            }
        }
    }
    
    private func updateChain() {
        if board.detached == 0 {
            self.state = .Resolve
        }
    }
    
    private func updateResolve() {
        board.resolve()
        
        if board.detached == 0 {
            self.state = .Initial
        } else {
            self.state = .Chain
        }
    }
    
    private func nextCard() -> Card {
        return generator.cardForState(generatorState)
    }
    
}