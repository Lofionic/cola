//
//  COLComponentOutput.m
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLComponentOutput.h"
#import "COLComponent.h"
#import "COLComponentInput.h"

@interface COLComponentOutput () {
    AudioSignalType *buffer;
    UInt32 bufferSize;
}

@end

@implementation COLComponentOutput

-(AudioSignalType*)getBuffer:(UInt32)numFrames {
    
    if (![self.component hasRendered]) {
        // If the component hasn't rendered, now's the time to do it
        // Render the component's inputs first
        [self.component renderOutputs:numFrames];
    }
    
    return buffer;
}

-(AudioSignalType*)prepareBufferOfSize:(UInt32)numFrames {
    // Create or resize the buffer, if necessary
    if (numFrames != bufferSize) {
        NSLog(@"Creating buffer of size %u for output %@", (unsigned int)numFrames, [self nameWithComponent]);
        free(buffer);
        bufferSize = numFrames;
        buffer = (AudioSignalType*)malloc(bufferSize * sizeof(AudioSignalType));
        memset(buffer, 0, bufferSize * sizeof(AudioSignalType));
    }
    
    return buffer;
}

-(void)engineDidRender {
    if ([self.component hasRendered]) {
        [self.component engineDidRender];
    }
}

-(BOOL)connectTo:(COLComponentInput *)input {
    if ([input component] && [self component] && [[input component] context] != [[self component] context]) {
        NSLog(@"Connection failed : Connecting components must exist in the same context.");
        return FALSE;
    }
    
    if (input.type != self.type) {
        NSLog(@"Connection failed : Output and input types must match");
        return FALSE;
    }
    
    if (input.component == self.component) {
        NSLog(@"Connection failed : Component cannot connect to self");
        return FALSE;
    }
    
    if (self.isConnected) {
        [self disconnect];
    }
    
    if (input.isConnected) {
        [input.connectedTo disconnect];
    }
    
    self.connectedTo = input;
    [input setConnectedTo:self];

    return TRUE;
}

-(BOOL)disconnect {
    if ([self isConnected]) {
        [self.connectedTo disconnect];
        self.connectedTo = nil;
        return TRUE;
    } else {
        return FALSE;
    }
}

@end
