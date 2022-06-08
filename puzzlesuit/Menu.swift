//
//  Menu.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 20/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

typealias MenuItemListener = (_ item: MenuItem) -> Void

protocol MenuItem {
    
    var square : Square { get }
    var value : Any? { get set }
    
}

class TextMenuItem : MenuItem {
    
    let text : Text
    var value : Any?
    let padding : GLfloat = 4
    
    var square : Square {
        get {
            return Square(top: text.top - padding, bottom: text.bottom + padding, left: text.left, right: text.right)
        }
    }
    
    init(text: String, factory: SpriteFactory) {
        self.text = Text(factory: factory, x: 0, y: 0, text: text)
    }
    
}

protocol Layout {
    
    func pointForItem(item: MenuItem) -> Spot
    
}

class VerticalLayout : Layout {
    
    let origin : Spot
    let margin : GLfloat
    
    private var y : GLfloat
    
    init(origin: Spot, margin: GLfloat = 4) {
        self.origin = origin
        self.margin = margin
        self.y = origin.y
    }
    
    func pointForItem(item: MenuItem) -> Spot {
        let point = Spot(x: origin.x, y: y + margin)
        self.y += item.square.height + margin + margin
        return point
    }
    
}

class Menu {
    
    let factory : SpriteFactory
    let cursor : Sprite
    let layout : Layout?
    
    var items = [MenuItem]()
    var selection : Int = -1
    var selectedItem : MenuItem {
        get {
            return items[selection]
        }
    }
    
    var onSelection : MenuItemListener?
    
    init() {
        self.factory = SpriteFactory()
        self.cursor = Sprite()
        self.layout = nil
    }
    
    init(factory: SpriteFactory, layout: Layout? = nil) {
        self.factory = factory
        self.cursor = factory.sprite(definition: Sprite.cursorDefinition)
        self.layout = layout
    }
    
    func add(text: String, withValue value: Any? = nil, alignment: TextAlignment = .Left) {
        let item = TextMenuItem(text: text, factory: factory)
        item.value = value
        item.text.alignment = alignment
        
        if let location = layout?.pointForItem(item: item) {
            item.text.moveToLocation(location: location)
        }
        
        self.items.append(item)
        
        if selection == -1 {
            selectItemAtIndex(index: 0)
        }
    }
    
    func update() {
        if Input.instance.touches.count == 1 {
            let touch = Input.instance.touches.values.first!
            if let index = itemIndexForTouch(touch: touch) {
                selectItemAtIndex(index: index)
                onSelection?(selectedItem)
            }
        } else if Input.instance.pressed(button: .Down) {
            selectItemAtIndex(index: selection + 1)
        } else if Input.instance.pressed(button: .Up) {
            selectItemAtIndex(index: selection - 1)
        } else if Input.instance.pressed(button: .Start) {
            onSelection?(selectedItem)
        }
    }
    
    private func selectItemAtIndex(index: Int) {
        self.selection = min(max(index, 0), items.count - 1)
        
        let square = selectedItem.square
        cursor.center = Spot(x: square.left - cursor.width - cursor.width, y: square.y)
    }
    
    private func itemIndexForTouch(touch: Spot) -> Int? {
        let ratio = View.instance.ratio
        let point = Spot(x: touch.x * ratio, y: touch.y * ratio)
        
        for index in 0..<items.count {
            if SimpleHitbox(square: items[index].square).collidesWith(point: point) {
                return index
            }
        }
        
        return nil
    }
    
}
