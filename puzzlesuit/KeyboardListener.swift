//
//  WindowController.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 30/09/2015.
//  Copyright © 2015 Raphaël Calabro. All rights reserved.
//

import Cocoa

class KeyboardListener: NSWindowController {
    
    override func awakeFromNib() {
        if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            delegate.window = self.window
        }
    }
    
    override func keyDown(theEvent: NSEvent) {
        KeyboardInputSource.instance.keyDown(theEvent.keyCode)
    }
    
    override func keyUp(theEvent: NSEvent) {
        KeyboardInputSource.instance.keyUp(theEvent.keyCode)
    }
    
    // NOTE: Surcharger flagsChanged pour gérer shift, ctrl, etc.

}
