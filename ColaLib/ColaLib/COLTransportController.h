//
//  COLTransportController.h
//  ColaLib
//
//  Created by Chris on 25/05/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponent.h"

@interface COLTransportController : NSObject

@property (nonatomic, readonly) UInt16  *stepBuffer;
@property (nonatomic, readonly) Float32 *stepDeltaBuffer;
@property (readonly) BOOL playing;

-(void)renderOutputs:(UInt32)numFrames;
-(void)start;
-(void)stop;
-(void)reset;

@end
