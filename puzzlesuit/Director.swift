//
//  Director.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 30/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

class Director : NSObject {
    
    static let fadeDuration : NSTimeInterval = 0.5
    static let fullProgress : Float = 1
    static let halfProgress : Float = 0.5
    
    static let audio : Audio = OpenALAudio()
    static let operationQueue = NSOperationQueue()
    
    var scene : Scene = EmptyScene()
    var nextScene : Scene?
    var preloadedScene : PreloadableScene?
    
    var fade : Fade = NoFade()
    
    func start() {
        View.instance.applyZoom()
        
        self.fade = FadeScene()
        self.scene = TitleScene()
        scene.director = self
        fade.director = self
        scene.load?()
        scene.willAppear?()
    }
    
    func restart() {
        scene.reload?()
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        if var nextScene = self.nextScene {
            if !(self.scene is Fade) {
                Director.audio.stopStream()
                
                // TODO: Voir comment faire le unload ailleurs.
                nextScene.director = self
                nextScene.load?()
                
                fade.previousScene = scene
                fade.nextScene = nextScene
                fade.load?()
                
                nextScene = fade
            } else {
                fade.previousScene.unload?()
                fade.previousScene = EmptyScene()
                fade.nextScene = EmptyScene()
            }

            self.scene = nextScene
            self.nextScene = nil
            
        } else {
            scene.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
        }
    }
    
    func draw() {
        // TODO : Faire la translation qu'une fois.
        let screen = Spot(x: 0, y: View.instance.height)
        Draws.clearWithColor(scene.backgroundColor)
        Draws.translateForPoint(screen)
        scene.draw()
        Draws.cancelTranslationForPoint(screen)
    }
    
    /// Préchargement de la prochaine scène.
    func preload(scene: PreloadableScene) {
        self.preloadedScene = scene
        
        scene.loadInBackground(Director.operationQueue)
    }
    
    func waitAndSwitchToPreloadedScene() {
        Director.operationQueue.waitUntilAllOperationsAreFinished()
        
        if preloadedScene != nil {
            self.nextScene = preloadedScene
            self.preloadedScene = nil
        }
    }
    
    func cancelPreloading() {
        if let preloadedScene = self.preloadedScene {
            Director.operationQueue.cancelAllOperations()
            preloadedScene.unload?()
            self.preloadedScene = nil
        }
    }
    
}

class NoAudio : NSObject, Audio {
    
    func loadSound(sound: Sound, fromResource name: String) {
        // Pas de chargement.
    }
    
    func playSound(sound: Sound) {
        // Pas de lecture.
    }
    
    func playStreamAtURL(url: NSURL) {
        // Pas de lecture.
    }
    
    func playOnceStreamAtURL(url: NSURL, withCompletionBlock block: () -> Void) {
        // Pas de lecture.
    }
    
    func stopStream() {
        // Pas de lecture.
    }

}