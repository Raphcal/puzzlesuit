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
        
        let location = locationForSprite(sprite)
        dirty.append(location)
        
        for sprite in sprites {
            let location = locationForSprite(sprite)
            
            // Correction de la position.
            sprite.x = self.left + cardSize.x * GLfloat(location.x) + cardSize.x / 2
            sprite.y = self.top + cardSize.y * GLfloat(location.y - Board.hiddenRows) + cardSize.y / 2
            sprite.factory.updateLocationOfSprite(sprite)
            
            // Placement dans la grille.
            grid[location.index()] = sprite
        }
    }
    
    func detachSpriteAtIndex(index: Int) {
        // TODO: Écrire la méthode.
    }
    
    func resolve() {
        for location in dirty {
            if let card = cardAtLocation(location) {
                
                // Vérification des brelans / carrés / etc.
                var sameKinds = [location]
                sameKinds.appendContentsOf(sameKindLocations(card.value, start: location, direction: BoardLocation(x: 0, y: -1)))
                sameKinds.appendContentsOf(sameKindLocations(card.value, start: location, direction: BoardLocation(x: 0, y: 1)))
                sameKinds.appendContentsOf(sameKindLocations(card.value, start: location, direction: BoardLocation(x: -1, y: 0)))
                sameKinds.appendContentsOf(sameKindLocations(card.value, start: location, direction: BoardLocation(x: 1, y: 0)))
                
                if sameKinds.count > 2 {
                    // TODO: Supprimer les cartes et faire tomber les sprites affectés.
                    NSLog("\(sameKinds.count) of a kind")
                    removeCardsAtLocations(sameKinds)
                }
                
                // TODO: Vérification des doubles pairs.
                
                // TODO: Vérification des suites.
                
                // TODO: Vérification des couleurs.
            }
        }
        dirty.removeAll()
    }
    
    func spriteAtX(x: Int, y: Int) -> Sprite? {
        return grid[y * Board.rows + x]
    }
    
    func areSprites(sprites: [Sprite], ableToMoveToDirection direction: Direction) -> Bool {
        var result = true
        
        for sprite in sprites {
            result = result && isSprite(sprite, ableToMoveToDirection: direction)
        }
        
        return result
    }
    
    func isSprite(sprite: Sprite, ableToMoveToDirection direction: Direction) -> Bool {
        // TODO: Vérifier la présence de sprites.
        switch direction {
        case .Left:
            return locationForSprite(sprite).x > 0
        case .Right:
            return locationForSprite(sprite).x < Board.columns
        case .Down:
            return locationForSprite(sprite).y < Board.rows + Board.hiddenRows
        case .Up:
            return locationForSprite(sprite).y > 0
        }
    }
    
    private func locationForSprite(sprite: Sprite) -> BoardLocation {
        return locationForX(sprite.x, y: sprite.y)
    }
    
    private func locationForX(x: GLfloat, y: GLfloat) -> BoardLocation {
        return BoardLocation(x: Int((x - self.left) / cardSize.x), y: Int((y - self.top) / cardSize.y) + Board.hiddenRows)
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
    
    private func cardAtLocation(location: BoardLocation) -> Card? {
        if location.x >= 0 && location.x < Board.columns && location.y >= 0 && location.y < Board.rows + Board.hiddenRows, let sprite = grid[location.index()] {
            return Card(sprite: sprite)
        } else {
            return nil
        }
    }
    
    private func sameKindLocations(value: Int, start: BoardLocation, direction: BoardLocation) -> [BoardLocation] {
        var locations = [BoardLocation]()
        
        var current = start + direction
        while let card = cardAtLocation(current) where card.value == value {
            locations.append(current)
            current += direction
        }
        
        return locations
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
        grid[index]!.destroy()
        grid[index] = nil
        
        var tail = [Sprite]()
        
        let top = BoardLocation(x: 0, y: -1)
        var nextLocation = location + top
        
        while nextLocation.y >= 0, let sprite = grid[nextLocation.index()] {
            tail.append(sprite)
            grid[nextLocation.index()] = nil
            nextLocation += top
        }
        
        if tail.count >= 1 {
            detached++
            tail[0].motion = FallMotion(board: self, tail: tail)
        }
    }
    
}