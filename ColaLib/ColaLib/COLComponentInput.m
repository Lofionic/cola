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

@property (nonatomic) BOOL isDisconnecting;
@property (nonatomic) BOOL isConnecting;
@property (nonatomic) float attenuation;

@end

@implementation COLComponentInput

static AudioSignalType* emptyBuffer;
static UInt32 emptyBufferSize;

-(AudioSignalType *)getBuffer:(UInt32)numFrames {
    if (self.connectedTo) {
        NSAssert([self.connectedTo isKindOfClass:[COLComponentOutput class]], @"Input connectedTo must be COLComponentOUtput class");
        AudioSignalType* buffer = [(COLComponentOutput*)[self connectedTo] getBuffer:numFrames];
        if (buffer != NULL) {
            if (self.isDisconnecting) {
                // Attenuate the signal before disconnecting
                for (int i = 0; i < numFrames; i++) {
                    self.attenuation -= 1.0/10000;
                    if (self.attenuation < 0) {
                        self.attenuation = 0;
                    }
                    buffer[i] = buffer[i] * self.attenuation;
                }
                if (self.attenuation <= 0) {
                    [self doDisconnect];
                }
            } else if (self.isConnecting) {
                // Attenuate the signal whilst connecting
                for (int i = 0; i < numFrames; i++) {
                    self.attenuation += 1.0/10000;
                    if (self.attenuation > 1) {
                        self.attenuation = 1;
                    }
                    buffer[i] = buffer[i] * self.attenuation;
                }
                if (self.attenuation >= 1) {
                    self.isConnecting = NO;
                }
            }
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
        self.isDisconnecting = YES;
        self.attenuation = 1.0;
        return TRUE;
    } else {
        return FALSE;
    }
}

-(void)doDisconnect {
    self.connectedTo = nil;
    self.isDisconnecting = NO;
}

@synthesize connectedTo = _connectedTo;

-(void)setConnectedTo:(COLComponentIO *)connectedTo {
    _connectedTo = connectedTo;
    self.isConnecting = YES;
    
    if (self.isDisconnecting) {
        self.isDisconnecting = NO;
    } else {
        self.attenuation = 0;
    }
}

-(COLComponentIO*)connectedTo {
    return _connectedTo;
}

@end
