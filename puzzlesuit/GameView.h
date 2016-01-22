//
//  GameView.h
//  MeltedIce
//
//  Created by Raphaël Calabro on 21/10/2015.
//  Copyright © 2015 Raphaël Calabro. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Director;

@interface GameView : NSOpenGLView {
    NSTimeInterval _previousTime;
}

@property (strong, nonatomic) Director *director;
@property (readonly) CVDisplayLinkRef displayLink;

- (void)initializeDisplayLink;

@end
