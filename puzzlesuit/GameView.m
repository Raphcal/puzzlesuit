//
//  GameView.m
//  MeltedIce
//
//  Created by Raphaël Calabro on 21/10/2015.
//  Copyright © 2015 Raphaël Calabro. All rights reserved.
//

#import "GameView.h"
#import "PuzzleSuit-Swift.h"

@implementation GameView

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reshape)
                                                 name:NSViewGlobalFrameDidChangeNotification
                                               object:self];
}

- (void)dealloc {
    CVDisplayLinkRelease(_displayLink);
}

- (void)initializeDisplayLink {
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(_displayLink, &MyDisplayLinkCallback, (__bridge void * _Nullable)(self));
    
    // Set the display link for the current renderer
    CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
    
    // Activate the display link
    CVDisplayLinkStart(_displayLink);
}

- (CVReturn)frameForTime:(const CVTimeStamp*)outputTime {
    [self.openGLContext makeCurrentContext];
    
    CGLLockContext(self.openGLContext.CGLContextObj);
    
    [_director updateWithTimeSinceLastUpdate: [self timeSinceLastUpdate: outputTime]];
    [_director draw];
    
    CGLFlushDrawable(self.openGLContext.CGLContextObj);
    CGLUnlockContext(self.openGLContext.CGLContextObj);
    
    return kCVReturnSuccess;
}

- (NSTimeInterval) timeSinceLastUpdate:(const CVTimeStamp *)outputTime {
    NSTimeInterval now = (NSTimeInterval) outputTime->videoTime / (NSTimeInterval) outputTime->videoTimeScale;
    NSTimeInterval before = _previousTime;
    
    _previousTime = now;
    
    if (before != 0) {
        return now - before;
    } else {
        return 0;
    }
}

- (void)reshape {
    [super reshape];
    CGLLockContext([[self openGLContext] CGLContextObj]);
    
    CGRect bounds = self.bounds;
    glViewport(0, 0, bounds.size.width, bounds.size.height);
    
    View *view = [View instance];
    [view updateViewWithBounds:bounds];
    [view applyZoom];

    CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime,
                                      CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext) {
    GameView *gameView = (__bridge GameView *)displayLinkContext;
    CVReturn result = [gameView frameForTime:outputTime];
    return result;
}

@end
