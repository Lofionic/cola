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
    UInt32              bufferSize;
    AudioSignalType     *buffer;
}

@end

@implementation COLComponentInput

-(AudioSignalType*)renderSamples:(UInt32)numFrames {
    // Prepare buffer
    if (numFrames != bufferSize) {
        free(buffer);
        bufferSize = numFrames;
        buffer = (AudioSignalType*)malloc(bufferSize * sizeof(AudioSignalType));
    }

    if (self.connectedTo) {
        [self.connectedTo renderBuffer:buffer samples:numFrames];
    } else {
        for (int i = 0; i < numFrames; i++) {
            buffer[i] = 0;
        }
    }
    return buffer;
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
