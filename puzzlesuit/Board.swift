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
        self.grid = [Sprite?](repeating: nil, count: Board.columns * (Board.rows + Board.hiddenRows))
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
        let sprites = [spriteForCard(card: mainCard, tailIndex: 0), spriteForCard(card: extraCard, tailIndex: 1)]
        detached += sprites.count
        
        return sprites
    }
    
    func spritesForChips(chips: Int) {
        if chips < Board.columns {
            var columns = (0..<Board.columns).compactMap({ $0 })
            for _ in 0..<chips {
                let column = columns.remove(at: Random.next(range: columns.count))
                let sprite = spriteForChipInColumn(column: column, tailIndex: 0)
                sprite.motion = FallMotion(board: self, tail: [], initialSpeed: 128)
            }
            detached += chips
        } else {
            let count = chips / Board.columns
            
            for column in 0..<Board.columns {
                var tail = [Sprite]()
                for index in 0..<count {
                    tail.append(spriteForChipInColumn(column: column, tailIndex: index))
                }
                tail[0].motion = FallMotion(board: self, tail: tail, initialSpeed: 128)
            }
            
            detached += Board.columns
        }
    }
    
    func isSpriteOnSomething(sprite: Sprite) -> Bool {
        let location = locationForX(x: sprite.x, y: sprite.y)
        return location.y >= (Board.rows + Board.hiddenRows) || grid[location.index()] != nil
    }
    
    func isSpriteAboveSomething(sprite: Sprite) -> Bool {
        let location = locationForX(x: sprite.x, y: sprite.bottom + 1)
        return location.y >= (Board.rows + Board.hiddenRows) || grid[location.index()] != nil
    }
    
    func attachSprite(sprite: Sprite, tail: [Sprite] = []) {
        detached -= 1
        
        let sprites : [Sprite]
        
        if tail.isEmpty {
            sprites = [sprite]
        } else {
            sprites = tail
        }
        
        var location = locationForPoint(point: sprite)
        while location.y >= Board.rows + Board.hiddenRows {
            location += Direction.Up.location()
        }
        
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
                sprite.factory.updateLocationOfSprite(sprite: sprite)
                
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
        
        let identifier = Identifier(board: self)
        
        for location in dirty {
            if let card = cardAtLocation(location: location) {
                let hands = identifier.handsForCard(card: card, atLocation: location, locations: &marked)
                
                for hand in hands {
                    result.append(hand.hand)
                    // TODO: Afficher le nom de la main en sprite
                }
            }
        }
        marked.append(contentsOf: chipLocationsAroundMarkedLocations())
        removalWarningForCardsAtLocations(locations: marked)
        dirty.removeAll()
        
        return result
    }
    
    func commit() {
        removeCardsAtLocations(locations: marked)
        marked.removeAll()
    }
    
    /// Vérifie que le point est dans la grille et que l'emplacement correspondant est vide.
    func canMoveToPoint(point: Spot) -> Bool {
        let location = locationForPoint(point: point)
        if location.x < 0 || location.x >= Board.columns || location.y < 0 || location.y >= Board.rows + Board.hiddenRows {
            return false
        }
        return grid[location.index()] == nil
    }
    
    /// Renvoi l'emplacement vide le plus bas de la colonne donnée.
    func topOfColumn(column: Int) -> BoardLocation? {
        var location = BoardLocation(x: column, y: Board.rows + Board.hiddenRows - 1)
        
        while grid[location.index()] != nil {
            location += Direction.Up.location()
            
            if location.y < 0 {
                return nil
            }
        }
        
        return location
    }
    
    func locationForPoint(point: Spot) -> BoardLocation {
        return locationForX(x: point.x, y: point.y)
    }
    
    private func locationForX(x: GLfloat, y: GLfloat) -> BoardLocation {
        return BoardLocation(x: Int((x - left + cardSize.x) / cardSize.x) - 1, y: Int((y - top + cardSize.y) / cardSize.y) + Board.hiddenRows - 1)
    }
    
    private func spriteForCard(card: Card, tailIndex: Int) -> Sprite {
        let sprite = factory.sprite(definition: card.suit.rawValue)
        sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[0])
        sprite.animation.frameIndex = card.rank.rawValue
        
        sprite.x = self.left + 2 * cardSize.x  + cardSize.x / 2
        sprite.y = self.top - GLfloat(tailIndex) * cardSize.y - cardSize.y / 2
        sprite.width = cardSize.x
        sprite.height = cardSize.y
        
        return sprite
    }
    
    private func spriteForChipInColumn(column: Int, tailIndex: Int) -> Sprite {
        let sprite = factory.sprite(definition: Suit.all.count)
        
        sprite.x = self.left + GLfloat(column) * cardSize.x  + cardSize.x / 2
        sprite.y = self.top - GLfloat(tailIndex) * cardSize.y - cardSize.y / 2
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
    
    func chipAtLocation(location: BoardLocation) -> Chip? {
        if location.x >= 0 && location.x < Board.columns && location.y >= 0 && location.y < Board.rows + Board.hiddenRows, let sprite = grid[location.index()] {
            return Chip(sprite: sprite)
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
        let sorted = locations.sorted { (left, right) -> Bool in
            if left.y == right.y {
                return left.x < right.x
            } else {
                return left.y < right.y
            }
        }
        for location in sorted {
            removeCard(at: location)
        }
    }
    
    private func removeCard(at location: BoardLocation) {
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
                detached += 1
                tail[0].motion = FallMotion(board: self, tail: tail)
            }
        }
    }
    
    private func chipLocationsAroundMarkedLocations() -> [BoardLocation] {
        var locations = [BoardLocation]()
        
        var done = [Bool](repeating: false, count: grid.count)
        
        for location in marked {
            for direction in Direction.all {
                let neighbor = location + direction.location()
                if chipAtLocation(location: neighbor) != nil && !done[neighbor.index()] {
                    locations.append(neighbor)
                    done[neighbor.index()] = true
                }
            }
        }
        
        return locations
    }
    
}
