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

@interface COLComponentInput ()

@end

@implementation COLComponentInput

static AudioSignalType* emptyBuffer;
static UInt32 emptyBufferSize;

-(AudioSignalType *)getBuffer:(UInt32)numFrames {
    if (self.connectedTo) {
        NSAssert([self.connectedTo isKindOfClass:[COLComponentOutput class]], @"Input connectedTo must be COLComponentOUtput class");
        AudioSignalType* buffer = [(COLComponentOutput*)[self connectedTo] getBuffer:numFrames];
        if (buffer != NULL) {
            return buffer;
        } else {
            // Can't provide buffer yet, probably because buffer's input is forming a ring
            // Return an empty buffer
            return [COLComponentInput emptyBuffer:numFrames];
        }
    } else {
        // No connection - no signal. Return an empty buffer
        return [COLComponentInput emptyBuffer:numFrames];
    }
}

+(AudioSignalType*)emptyBuffer:(UInt32)numFrames {
    if (numFrames != emptyBufferSize) {
        NSLog(@"Creating empty buffer of size %u", (unsigned int)numFrames);
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

-(BOOL)disconnect {
    if ([self isConnected]) {
        self.connectedTo = nil;
        return TRUE;
    } else {
        return FALSE;
    }
}


@end
