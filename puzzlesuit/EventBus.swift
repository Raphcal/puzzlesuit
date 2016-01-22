//
//  EventBus.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 02/07/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import Foundation

enum Event : Int {
    /// Nombre de bulle modifié.
    case BubbleCountChanged
    /// Vie gagnée.
    case LifeGained
    /// Vie perdue.
    case LifeLost
    /// Fin du niveau.
    case LevelFinished
    /// La connexion avec GameCenter a changée.
    case GameCenterStatusChanged
    /// Nombre d'événements.
    case Count
}

typealias EventListener = (value: Any?) -> Void

class EventBus {
    
    static let instance = EventBus()
    
    private var listeners : [EventBusEntry]
    
    init() {
        self.listeners = [EventBusEntry](count: Event.Count.rawValue, repeatedValue: EventBusEntry())
    }
    
    func setListener(listener: EventListener, forEvent event: Event, parent: AnyObject) {
        listeners[event.rawValue] = EventBusEntry(listener: listener, parent: parent)
    }
    
    func fireEvent(event: Event, withValue value: Any? = nil) {
        if let listener = listeners[event.rawValue].listener {
            listener(value: value)
        }
    }
    
    func removeListernersForEvent(event: Event, parent: AnyObject) {
        if let savedParent = listeners[event.rawValue].parent where unsafeAddressOf(savedParent) == unsafeAddressOf(parent) {
            self.listeners[event.rawValue] = EventBusEntry()
        }
    }
    
    func removeAllListeners() {
        self.listeners = [EventBusEntry](count: Event.Count.rawValue, repeatedValue: EventBusEntry())
    }
    
}

struct EventBusEntry {
    
    var listener : EventListener?
    var parent : AnyObject?
    
    init() {
        // Vide.
    }
    
    init(listener: EventListener, parent: AnyObject) {
        self.listener = listener
        self.parent = parent
    }
    
}