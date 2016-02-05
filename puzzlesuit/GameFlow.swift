//
//  GameFlow.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

enum GameFlowState {
    
    case Initial, NewHand, Play, Chain, Resolve, Pause, Commit, ChipFall, Lost
    
}

enum GameError : ErrorType {
    
    case Lost
    
}

class GameFlow {
    
    let factory : SpriteFactory
    
    let side : Side
    let board : Board
    let generator : Generator
    let generatorState = GeneratorState()
    
    var state = GameFlowState.Initial
    
    var hand = [Sprite]()
    var nextHand : [Card]
    
    var preview = [Sprite]()
    
    var pause : NSTimeInterval = 0
    var nextState = GameFlowState.NewHand
    
    var controller : Controller = NoController()
    
    var chips = 0
    var chainCount = 0
    
    var receivedChips = 0 {
        didSet {
            updateReceivedChipsPreview()
        }
    }
    var chipPreview = [Sprite]()
    
    init() {
        self.side = .Left
        self.board = Board()
        self.generator = Generator()
        self.nextHand = []
        self.factory = SpriteFactory()
    }
    
    init(side: Side, board: Board, generator: Generator, factory: SpriteFactory) {
        self.side = side
        self.board = board
        self.generator = generator
        self.nextHand = [generator.cardForState(generatorState), generator.cardForState(generatorState)]
        self.factory = factory
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
        case .ChipFall:
            updateChipFall()
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
        
        for index in 0..<2 {
            let sprite = factory.sprite(0)
            sprite.size = board.cardSize
            if side == .Left {
                sprite.left = board.right + board.cardSize.x
            } else {
                sprite.right = board.left - board.cardSize.x
            }
            sprite.top = board.top + sprite.height - GLfloat(index) * sprite.height
            preview.append(sprite)
        }
        
        EventBus.instance.setListener({ (value) in
            self.receivedChips += value as! Int
            }, forEvent: side.oppositeSide().event(), parent: self)
    }
    
    private func updateNewHand() {
        self.hand = board.spritesForMainCard(nextHand[0], andExtraCard: nextHand[1])
        self.chainCount = 0
        self.chips = 0

        // Nouvelle main
        let main = self.hand[0]
        let extra = self.hand[1]
        main.motion = MainCardMotion(board: board, extra: extra, controller: controller)
        extra.motion = ExtraCardMotion(board: board, main: main, controller: controller)
        
        let hand = nextHand
        self.nextHand = [generator.cardForState(generatorState), generator.cardForState(generatorState)]
        
        // Aperçu de la main suivante
        for index in 0..<preview.count {
            updatePreviewSprite(preview[index], withCard: nextHand[index])
        }
        
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
        let hands = board.resolve()
        
        for hand in hands {
            self.chips += hand.chips()
        }
        
        if !hands.isEmpty {
            chainCount++
        }
        
        if board.marked.count > 0 {
            self.pause = 0.3
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
            if chainCount > 1 {
                NSLog("\(chainCount)x combo")
            }
            if chips > 0 {
                sendChipsToOppositeSide(chips * chainCount)
            }
            if receivedChips > 0 {
                board.spritesForChips(receivedChips)
                self.receivedChips = 0
                self.state = .ChipFall
            } else {
                self.state = .NewHand
            }
        } else {
            self.state = .Chain
        }
    }
    
    private func updateChipFall() {
        if board.detached == 0 {
            self.state = .NewHand
        }
    }
    
    private func updatePreviewSprite(sprite: Sprite, withCard card: Card) {
        sprite.animation = SingleFrameAnimation(definition: sprite.factory.definitions[card.suit.rawValue].animations[0])
        sprite.animation.frameIndex = card.rank.rawValue
        
        sprite.factory.updateLocationOfSprite(sprite)
    }
    
    private func updateReceivedChipsPreview() {
        for sprite in chipPreview {
            sprite.destroy()
        }
        chipPreview.removeAll()
        
        let bottomMargin : GLfloat = 4
        let rightMargin : GLfloat = 1
        
        let chipStack = Board.columns
        let redChip = chipStack * Board.columns
        
        var total = receivedChips
        for var index = 0; total > 0; index++ {
            let definition : Int
            
            if total >= redChip {
                total -= redChip
                definition = 7
            } else if total >= chipStack {
                total -= chipStack
                definition = 6
            } else {
                total--
                definition = 5
            }
            
            let preview = factory.sprite(definition)
            preview.width /= 2
            preview.height /= 2
            preview.left = board.left + (preview.width + rightMargin) * GLfloat(index)
            preview.bottom = board.top - bottomMargin
            factory.updateLocationOfSprite(preview)
            self.chipPreview.append(preview)
        }
    }
    
    private func sendChipsToOppositeSide(chips: Int) {
        EventBus.instance.fireEvent(side.event(), withValue: chips)
    }
    
}