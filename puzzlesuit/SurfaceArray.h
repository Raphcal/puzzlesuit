//
//  SurfaceArray.h
//  MeltedIce
//
//  Created by Raphaël Calabro on 06/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

#import <GLKit/GLKit.h>

@class Palette;

@interface SurfaceArray : NSObject

@property (readonly, nonatomic) GLfloat * _Nonnull memory;
@property (readonly, nonatomic) GLsizei count;
@property (readonly, nonatomic) NSInteger capacity;
@property (readonly, nonatomic) NSInteger coordinates;

- (id _Nonnull)initWithCapacity:(NSInteger)capacity coordinates:(NSInteger)coordinates;

- (void)setValue:(GLfloat)value atIndex:(NSInteger)index;
- (GLfloat)valueAtIndex:(NSInteger)index;

- (void)clear;
- (void)clearFromIndex:(NSInteger)index count:(NSInteger)count;
- (void)clearQuadAtIndex:(NSInteger)index;

- (void)reset;
- (void)appendValue:(GLfloat)value;
- (void)appendTile:(NSInteger)tile fromPalette:(Palette * _Nonnull)palette;
- (void)appendTile:(GLfloat)width height:(GLfloat)height left:(GLfloat)left top:(GLfloat)top;
- (void)appendQuad:(NSInteger)x y:(NSInteger)y;
- (void)appendQuad:(GLfloat)width height:(GLfloat)height left:(GLfloat)left top:(GLfloat)top distance:(GLfloat)distance;

@end
