//
//  AppDelegate.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 22/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    weak var window : NSWindow?
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true;
    }


}

