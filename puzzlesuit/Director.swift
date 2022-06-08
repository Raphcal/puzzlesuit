//
//  Director.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 30/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

@objc
class Director : NSObject {
    
    static let fadeDuration : TimeInterval = 0.5
    static let fullProgress : Float = 1
    static let halfProgress : Float = 0.5
    
    static let audio : Audio = OpenALAudio()
    static let operationQueue = OperationQueue()
    
    var scene : Scene = EmptyScene()
    var nextScene : Scene?
    var preloadedScene : PreloadableScene?
    
    var fade : Fade = NoFade()
    
    @objc func start() {
        View.instance.applyZoom()
        
        self.fade = FadeScene()
        self.scene = TitleScene()
        scene.director = self
        fade.director = self
        scene.load?()
        scene.willAppear?()
    }
    
    @objc func restart() {
        scene.reload?()
    }
    
    @objc func updateWith(timeSinceLastUpdate: TimeInterval) {
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
            scene.update(timeSinceLastUpdate: timeSinceLastUpdate)
        }
    }
    
    @objc func draw() {
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
        
        scene.loadInBackground(operationQueue: Director.operationQueue)
    }
    
    @objc func waitAndSwitchToPreloadedScene() {
        Director.operationQueue.waitUntilAllOperationsAreFinished()
        
        if preloadedScene != nil {
            self.nextScene = preloadedScene
            self.preloadedScene = nil
        }
    }
    
    @objc func cancelPreloading() {
        if let preloadedScene = self.preloadedScene {
            Director.operationQueue.cancelAllOperations()
            preloadedScene.unload?()
            self.preloadedScene = nil
        }
    }
    
}

class NoAudio : NSObject, Audio {
    
    func load(_ sound: Sound, fromResource name: String) {
        // Pas de chargement.
    }
    
    func play(_ sound: Sound) {
        // Pas de lecture.
    }
    
    func playStream(at url: URL) {
        // Pas de lecture.
    }
    
    func playOnceStream(at url: URL, withCompletionBlock block: @escaping () -> Void) {
        // Pas de lecture.
    }
    
    func stopStream() {
        // Pas de lecture.
    }

}
