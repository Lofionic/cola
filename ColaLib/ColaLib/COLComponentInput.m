//
//  COLComponentInput.m
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLDefines.h"
#import "COLComponentInput.h"
#import "COLComponentOutput.h"

@interface COLComponentInput () {
    AudioSignalType *emptyBuffer;
    UInt32 emptyBufferSize;
}

@end

@implementation COLComponentInput

-(void)renderComponents:(UInt32)numFrames {
    if ([self isConnected]) {
        [[self connectedTo] renderComponents:numFrames];
    }
}

-(AudioSignalType *)getBuffer:(UInt32)numFrames {
    if (self.connectedTo) {
        return [[self connectedTo] getBuffer:numFrames];
    } else {
        // No connection - no signal. Return an empty buffer
        if (numFrames != emptyBufferSize) {
            free(emptyBuffer);
            emptyBufferSize = numFrames;
            emptyBuffer = (AudioSignalType*)malloc(emptyBufferSize * sizeof(AudioSignalType));
            memset(emptyBuffer, 0, emptyBufferSize * sizeof(AudioSignalType));
        }

        return emptyBuffer;
    }
}

-(void)engineDidRender {
    [[self connectedTo] engineDidRender];
}

-(BOOL)disconnect {
    [[self connectedTo] disconnect];
    self.connectedTo = nil;
    return TRUE;
}

-(BOOL)isConnected {
    return self.connectedTo != nil;
}


@end
