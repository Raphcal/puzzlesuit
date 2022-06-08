//
//  EventBus.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 02/07/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import Foundation

enum Event : Int {
    /// Le joueur de gauche vient d'envoyer des jetons au joueur de droite.
    case LeftSideSentChips
    /// Le joueur de droite vient d'envoyer des jetons au joueur de gauche.
    case RightSideSentChips
    /// La connexion avec GameCenter a changée.
    case GameCenterStatusChanged
    /// Nombre d'événements.
    case Count
}

typealias EventListener = (_ value: Any?) -> Void

class EventBus {
    
    static let instance = EventBus()
    
    private var listeners : [EventBusEntry]
    
    init() {
        self.listeners = [EventBusEntry](repeating: EventBusEntry(), count: Event.Count.rawValue)
    }
    
    func setListener(listener: @escaping EventListener, forEvent event: Event, parent: AnyObject) {
        listeners[event.rawValue] = EventBusEntry(listener: listener, parent: parent)
    }
    
    func fireEvent(event: Event, withValue value: Any? = nil) {
        if let listener = listeners[event.rawValue].listener {
            listener(value)
        }
    }
    
    func removeListernersForEvent(event: Event, parent: AnyObject) {
        if let savedParent = listeners[event.rawValue].parent, ObjectIdentifier(savedParent) == ObjectIdentifier(parent) {
            self.listeners[event.rawValue] = EventBusEntry()
        }
    }
    
    func removeAllListeners() {
        self.listeners = [EventBusEntry](repeating: EventBusEntry(), count: Event.Count.rawValue)
    }
    
}

struct EventBusEntry {
    
    var listener : EventListener?
    var parent : AnyObject?
    
    init() {
        // Vide.
    }
    
    init(listener: @escaping EventListener, parent: AnyObject) {
        self.listener = listener
        self.parent = parent
    }
    
}
