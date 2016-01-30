//
//  GameFlow.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

enum GameFlowState {
    
    case Initial, NewHand, Play, Chain, Resolve, Pause, Commit, Lost
    
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
    var nextHand : [Card]
    
    var nextHandPreview = [Sprite]()
    
    var pause : NSTimeInterval = 0
    var nextState = GameFlowState.NewHand
    
    var controller : Controller = NoController()
    
    init() {
        self.board = Board()
        self.generator = Generator()
        self.nextHand = []
    }
    
    init(board: Board, generator: Generator) {
        self.board = board
        self.generator = generator
        self.nextHand = [generator.cardForState(generatorState), generator.cardForState(generatorState)]
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        switch state {
        case .Initial:
            updateInitial()
        case .NewHand:
            updateNewHand()
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
        self.nextState = .NewHand
        self.pause = 0.25
        self.state = .Pause
        
        if var cpu = controller as? Cpu {
            cpu.flow = self
        }
        
        nextHandPreview.append(board.factory.sprite(0))
        nextHandPreview.append(board.factory.sprite(0))
    }
    
    private func updateNewHand() {
        self.hand = board.spritesForMainCard(nextHand[0], andExtraCard: nextHand[1])

        let main = self.hand[0]
        let extra = self.hand[1]
        main.motion = MainCardMotion(board: board, extra: extra, controller: controller)
        extra.motion = ExtraCardMotion(board: board, main: main, controller: controller)
        
        let hand = nextHand
        self.nextHand = [generator.cardForState(generatorState), generator.cardForState(generatorState)]
        
        (controller as? Cpu)?.handChanged(hand, nextHand: nextHand)
        
        self.state = .Play
    }
    
    private func updatePlay() {
        for sprite in hand {
            let rotating = (sprite.motion as? CanRotate)?.rotating == true
            
            if !rotating && board.isSpriteAboveSomething(sprite) {
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
        
        if board.grid[BoardLocation(x: 2, y: 2).index()] != nil {
            self.state = .Lost
            NSLog("Perdu")
            return
        }
        
        if board.detached == 0 {
            self.state = .NewHand
        } else {
            self.state = .Chain
        }
    }
    
    private func updatePreviewSprite(sprite: Sprite, withCard card: Card) {
        sprite.animation = SingleFrameAnimation(definition: sprite.factory.definitions[card.suit.rawValue].animations[0])
        sprite.animation.frameIndex = card.rank.rawValue
    }
    
}