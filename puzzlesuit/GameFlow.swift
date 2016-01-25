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
    
    // TODO: Compter les détachements ici ?
    
    init() {
        self.board = Board()
        self.generator = Generator()
    }
    
    init(board: Board, generator: Generator) {
        self.board = board
        self.generator = generator
        
        EventBus.instance.setListener({ (value) -> Void in
            self.state = .Lost
        }, forEvent: .BoardOverflow, parent: self)
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
            if board.isSpriteAboveSomething(sprite) {
                (sprite.motion as? PlayerMotion)?.linkedSprite.motion = FallMotion(board: board)
                sprite.motion = NoMotion()
                board.attachSprite(sprite)
                hand.removeAll()
                
                if state == .Lost {
                    return
                }
                
                self.state = .Chain
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
        
        if state == .Lost {
            return
        }
        
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