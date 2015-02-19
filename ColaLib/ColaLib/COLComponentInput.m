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

-(AudioSignalType *)getBuffer:(UInt32)numFrames {
    if (self.connectedTo) {
        AudioSignalType* buffer = [[self connectedTo] getBuffer:numFrames];
        if (buffer != NULL) {
            return buffer;
        } else {
            // Can't provide buffer yet, probably because buffer is input is forming a ring
            // Return an empty buffer
            return [self emptyBuffer:numFrames];
        }
    } else {
        // No connection - no signal. Return an empty buffer
        return [self emptyBuffer:numFrames];
    }
}

-(AudioSignalType*)emptyBuffer:(UInt32)numFrames {
    if (numFrames != emptyBufferSize) {
        free(emptyBuffer);
        emptyBufferSize = numFrames;
        emptyBuffer = (AudioSignalType*)malloc(emptyBufferSize * sizeof(AudioSignalType));
        memset(emptyBuffer, 0, emptyBufferSize * sizeof(AudioSignalType));
    }
    return emptyBuffer;
}

-(void)engineDidRender {
    [[self connectedTo] engineDidRender];
}

-(BOOL)isConnected {
    return self.connectedTo != nil;
}

-(BOOL)disconnect {
    if ([self isConnected]) {
        self.connectedTo = nil;
        return TRUE;
    } else {
        return FALSE;
    }
}


@end
