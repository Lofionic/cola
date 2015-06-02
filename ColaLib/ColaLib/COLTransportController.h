//
//  COLTransportController.h
//  ColaLib
//
//  Created by Chris on 25/05/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponent.h"

@interface COLTransportController : NSObject

@property (nonatomic, readonly) Float64 *beatBuffer;
@property (readonly) BOOL isPlaying;

-(void)renderOutputs:(UInt32)numFrames;
-(void)start;
-(void)stop;
-(void)stopAndReset;
-(void)interappAudioTransportStateDidChange;

@end
