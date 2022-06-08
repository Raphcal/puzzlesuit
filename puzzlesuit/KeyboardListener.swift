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
        (NSApplication.shared.delegate as? AppDelegate)?.window = self.window
    }

    override func keyDown(with event: NSEvent) {
        KeyboardInputSource.instance.keyDown(keyCode: event.keyCode)
    }

    override func keyUp(with event: NSEvent) {
        KeyboardInputSource.instance.keyUp(keyCode: event.keyCode)
    }
    
    // NOTE: Surcharger flagsChanged pour gérer shift, ctrl, etc.

}
