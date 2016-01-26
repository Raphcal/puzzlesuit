//
//  GameFlow.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

enum GameFlowState {
    
    case Initial, Play, Chain, Resolve, Pause, Commit, Lost
    
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
    
    var pause : NSTimeInterval = 0
    var nextState = GameFlowState.Initial
    
    // TODO: Compter les détachements ici ?
    
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
        case .Pause:
            updatePause(timeSinceLastUpdate)
        case .Commit:
            updateCommit()
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
                (sprite.motion as? Linked)?.linkedSprite.motion = FallMotion(board: board)
                sprite.motion = NoMotion()
                board.attachSprite(sprite)
                hand.removeAll()
                
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
        
        if board.marked.count > 0 {
            pause = 0.3
            self.nextState = .Commit
            self.state = .Pause
        } else {
            self.state = .Commit
        }
    }
    
    private func updatePause(timeSinceLastUpdate: NSTimeInterval) {
        self.pause -= timeSinceLastUpdate
        
        if pause < 0 {
            self.state = nextState
        }
    }
    
    private func updateCommit() {
        board.commit()
        
        if board.spriteAtX(2, y: 2) != nil {
            self.state = .Lost
            NSLog("Perdu")
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