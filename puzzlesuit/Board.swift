//
//  GameGrid.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 24/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

struct BoardLocation {
    
    let x : Int
    let y : Int
    
    func index() -> Int {
        return y * Board.columns + x
    }
    
}

func + (left: BoardLocation, right: BoardLocation) -> BoardLocation {
    return BoardLocation(x: left.x + right.x, y: left.y + right.y)
}

func == (left: BoardLocation, right: BoardLocation) -> Bool {
    return left.x == right.x && left.y == right.y
}

func != (left: BoardLocation, right: BoardLocation) -> Bool {
    return left.x != right.x || left.y != right.y
}

func += (inout left: BoardLocation, right: BoardLocation) {
    left = left + right
}

class Board : Square {
    
    static let columns = 6
    static let rows = 12
    static let hiddenRows = 2
    
    let factory : SpriteFactory
    
    var grid : [Sprite?]
    let cardSize : Spot
    
    var detached = 0
    
    var dirty = [BoardLocation]()
    var marked = [BoardLocation]()
    
    override init() {
        self.factory = SpriteFactory()
        self.grid = []
        self.cardSize = Spot()
        
        super.init()
    }
    
    init(factory: SpriteFactory, square: Square) {
        self.factory = factory
        self.grid = [Sprite?](count: Board.columns * (Board.rows + Board.hiddenRows), repeatedValue: nil)
        self.cardSize = Spot(x: square.width / GLfloat(Board.columns), y: square.height / GLfloat(Board.rows))
        
        super.init(square: square)
        
        #if SHOW_BACKGROUND
            let sprite = factory.sprite(0)
            sprite.width = square.width
            sprite.height = square.height
            sprite.center = square
        #endif
    }
    
    func spritesForMainCard(mainCard: Card, andExtraCard extraCard: Card) -> [Sprite] {
        let main = spriteForCard(mainCard)
        let extra = spriteForCard(extraCard)
        
        extra.y -= cardSize.y
        
        main.motion = MainCardMotion(board: self, extra: extra)
        extra.motion = ExtraCardMotion(board: self, main: main)
        
        let sprites = [main, extra]
        detached += sprites.count
        
        return sprites
    }
    
    func isSpriteAboveSomething(sprite: Sprite) -> Bool {
        let location = locationForX(sprite.x, y: sprite.bottom + 1)
        return location.y >= (Board.rows + Board.hiddenRows) || grid[location.index()] != nil
    }
    
    func attachSprite(sprite: Sprite, tail: [Sprite] = []) {
        detached--
        
        let sprites : [Sprite]
        
        if tail.isEmpty {
            sprites = [sprite]
        } else {
            sprites = tail
        }
        
        var top = locationForPoint(sprite)
        while grid[top.index()] != nil {
            top += Direction.Up.location()
        }
        dirty.append(top)
        
        var location = top
        for sprite in sprites {
            // Correction de la position.
            sprite.x = self.left + cardSize.x * GLfloat(location.x) + cardSize.x / 2
            sprite.y = self.top + cardSize.y * GLfloat(location.y - Board.hiddenRows) + cardSize.y / 2
            sprite.factory.updateLocationOfSprite(sprite)
            
            // Placement dans la grille.
            grid[location.index()] = sprite
            location += Direction.Up.location()
        }
    }
    
    func resolve() {
        for location in dirty {
            if let card = cardAtLocation(location) {
                // Vérification des brelans / carrés / etc.
                let identifier = Identifier(board: self)
                let sameKinds = identifier.sameKindsAsCard(card, location: location, ignore: marked)
                
                if sameKinds.count >= 3 {
                    if identifier.isFlush(sameKinds) {
                        NSLog("\(sameKinds.count) of a kind flush")
                    } else {
                        NSLog("\(sameKinds.count) of a kind")
                    }
                    marked.appendContentsOf(sameKinds)
                }
                
                #if TWO_PAIRS
                    // Vérification des doubles pairs.
                    if sameKinds.count == 2 {
                        let pairs = identifier.pairsAroundLocations(sameKinds, ignore: marked)
                        
                        if pairs.count > 0 {
                            NSLog("\(pairs.count / 2 + 1) pairs")
                            marked.appendContentsOf(sameKinds)
                            marked.appendContentsOf(pairs)
                        }
                    }
                #endif
                
                // Vérification des suites.
                let straight = identifier.straightIncludingCard(card, location: location, ignore: marked)
                if straight.count > 0 {
                    if identifier.isFlush(straight) {
                        NSLog("\(straight.count) straight flush")
                    } else {
                        NSLog("\(straight.count) straight")
                    }
                    marked.appendContentsOf(straight)
                }
                
                // Vérification des couleurs.
                let sameSuit = identifier.sameSuitAsCard(card, location: location, ignore: marked)
                if sameSuit.count >= 5 {
                    NSLog("\(sameSuit.count) length flush")
                    marked.appendContentsOf(sameSuit)
                }
            }
        }
        removalWarningForCardsAtLocations(marked)
        dirty.removeAll()
    }
    
    func mark() -> Int {
        return 0
    }
    
    func commit() {
        removeCardsAtLocations(marked)
        marked.removeAll()
    }
    
    func areSprites(sprites: [Sprite], ableToMoveToDirection direction: Direction) -> Bool {
        var result = true
        
        for sprite in sprites {
            result = result && isSprite(sprite, ableToMoveToDirection: direction)
        }
        
        return result
    }
    
    private func isSprite(sprite: Sprite, ableToMoveToDirection direction: Direction) -> Bool {
        let location = locationForPoint(sprite) + direction.location()
        return location.x >= 0 && location.x < Board.columns && location.y >= 0 && location.y < Board.rows + Board.hiddenRows && grid[location.index()] == nil
    }
    
    /// Vérifie que le point est dans la grille et que l'emplacement correspondant est vide.
    func canMoveToPoint(point: Spot) -> Bool {
        if point.x < left || point.x > right || point.y < top || point.y > bottom {
            return false
        }
        return grid[locationForPoint(point).index()] == nil
    }
    
    private func locationForPoint(point: Spot) -> BoardLocation {
        return locationForX(point.x, y: point.y)
    }
    
    private func locationForX(x: GLfloat, y: GLfloat) -> BoardLocation {
        return BoardLocation(x: Int((x - left) / cardSize.x), y: Int((y - top) / cardSize.y) + Board.hiddenRows)
    }
    
    private func spriteForCard(card: Card) -> Sprite {
        let sprite = factory.sprite(card.suit.rawValue)
        sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[0])
        sprite.animation.frameIndex = card.value
        
        sprite.x = self.left + 2 * cardSize.x  + cardSize.x / 2
        sprite.y = self.top - cardSize.y / 2
        sprite.width = cardSize.x
        sprite.height = cardSize.y
        
        return sprite
    }
    
    func cardAtLocation(location: BoardLocation) -> Card? {
        if location.x >= 0 && location.x < Board.columns && location.y >= 0 && location.y < Board.rows + Board.hiddenRows, let sprite = grid[location.index()] {
            return Card(sprite: sprite)
        } else {
            return nil
        }
    }
    
    private func removalWarningForCardsAtLocations(locations: [BoardLocation]) {
        for location in locations {
            if let sprite = grid[location.index()] {
                sprite.animation = BlinkingAnimation(animation: sprite.animation, blinkRate: 0.005, duration: 0.25, onEnd: { animation in
                    sprite.animation = animation
                })
            }
        }
    }
    
    private func removeCardsAtLocations(locations: [BoardLocation]) {
        let sorted = locations.sort { (left, right) -> Bool in
            if left.y == right.y {
                return left.x < right.x
            } else {
                return left.y < right.y
            }
        }
        for location in sorted {
            removeCardAtLocation(location)
        }
    }
    
    private func removeCardAtLocation(location: BoardLocation) {
        let index = location.index()
        if let sprite = grid[index] {
            sprite.destroy()
            grid[index] = nil
        
            var tail = [Sprite]()
            
            var nextLocation = location + Direction.Up.location()
            
            while nextLocation.y >= 0, let sprite = grid[nextLocation.index()] {
                tail.append(sprite)
                grid[nextLocation.index()] = nil
                nextLocation += Direction.Up.location()
            }
            
            if tail.count >= 1 {
                detached++
                tail[0].motion = FallMotion(board: self, tail: tail)
            }
        }
    }
    
}