//
//  GameGrid.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 24/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

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
            sprite.animation = SingleFrameAnimation(definition: sprite.animation.definition)
            sprite.size = square.size
            sprite.center = square
        #endif
    }
    
    func spritesForMainCard(mainCard: Card, andExtraCard extraCard: Card) -> [Sprite] {
        let main = spriteForCard(mainCard)
        let extra = spriteForCard(extraCard)
        
        extra.y -= cardSize.y
        
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
        
        var location = locationForPoint(sprite)
        while grid[location.index()] != nil {
            location += Direction.Up.location()
            
            if location.y < 0 {
                sprites.forEach({ $0.destroy() })
                return
            }
        }
        
        for sprite in sprites {
            if location.y >= 0 {
                dirty.append(location)
                
                // Correction de la position du sprite.
                sprite.x = self.left + cardSize.x * GLfloat(location.x) + cardSize.x / 2
                sprite.y = self.top + cardSize.y * GLfloat(location.y - Board.hiddenRows) + cardSize.y / 2
                sprite.factory.updateLocationOfSprite(sprite)
                
                // Placement dans la grille.
                grid[location.index()] = sprite
            } else {
                sprite.destroy()
            }
            location += Direction.Up.location()
        }
    }
    
    func resolve() -> [Hand] {
        var result = [Hand]()
        
        for location in dirty {
            if let card = cardAtLocation(location) {
                let identifier = Identifier(board: self)
                
                // Vérification des suites.
                let straight = identifier.straightIncludingCard(card, location: location, ignore: marked)
                if straight.count >= 5 {
                    result.append(.Straight(count: straight.count, flush: identifier.isFlush(straight)))
                    NSLog(result.last!.description())
                    marked.appendContentsOf(straight)
                }
                
                // Vérification des brelans / carrés / etc.
                let sameKinds = identifier.sameKindsAsCard(card, location: location, ignore: marked)
                
                if sameKinds.count >= 3 {
                    result.append(.SameKind(rank: cardAtLocation(sameKinds[0])!.rank, count: sameKinds.count, flush: identifier.isFlush(sameKinds)))
                    NSLog(result.last!.description())
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
                
                // Vérification des couleurs.
                let sameSuit = identifier.sameSuitAsCard(card, location: location, ignore: marked)
                if sameSuit.count >= 5 {
                    result.append(.Flush(suit: cardAtLocation(sameSuit[0])!.suit, count: sameSuit.count))
                    NSLog(result.last!.description())
                    marked.appendContentsOf(sameSuit)
                }
            }
        }
        removalWarningForCardsAtLocations(marked)
        dirty.removeAll()
        
        return result
    }
    
    func commit() {
        removeCardsAtLocations(marked)
        marked.removeAll()
    }
    
    /// Vérifie que le point est dans la grille et que l'emplacement correspondant est vide.
    func canMoveToPoint(point: Spot) -> Bool {
        let location = locationForPoint(point)
        if location.x < 0 || location.x >= Board.columns || location.y < 0 || location.y >= Board.rows + Board.hiddenRows {
            return false
        }
        return grid[location.index()] == nil
    }
    
    /// Renvoi l'emplacement de la carte la plus haute de la colonne donnée.
    func topOfColumn(column: Int) -> BoardLocation? {
        var location = BoardLocation(x: column, y: 0)
        
        while grid[location.index()] == nil {
            location += Direction.Down.location()
            
            if location.y >= Board.rows + Board.hiddenRows {
                return nil
            }
        }
        
        return location
    }
    
    func locationForPoint(point: Spot) -> BoardLocation {
        return locationForX(point.x, y: point.y)
    }
    
    private func locationForX(x: GLfloat, y: GLfloat) -> BoardLocation {
        return BoardLocation(x: Int((x - left + cardSize.x) / cardSize.x) - 1, y: Int((y - top + cardSize.y) / cardSize.y) + Board.hiddenRows - 1)
    }
    
    private func spriteForCard(card: Card) -> Sprite {
        let sprite = factory.sprite(card.suit.rawValue)
        sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[0])
        sprite.animation.frameIndex = card.rank.rawValue
        
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