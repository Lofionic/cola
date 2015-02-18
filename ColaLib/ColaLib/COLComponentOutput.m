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

@property (nonatomic, weak) COLComponent<COLOutputDelegate> *outputDelegate;

@end

@implementation COLComponentOutput

-(instancetype)initWithComponent:(COLComponent *)component ofType:(kComponentIOType)type withName:(NSString *)name {
    
    if (self = [super initWithComponent:component ofType:type withName:name]) {
        if ([component conformsToProtocol:@protocol(COLOutputDelegate)]) {
            self.outputDelegate = component;
        } else {
            NSLog(@"Warning : Component for output does not conform to output protocol");
        }
    }
    
    return self;
}

-(AudioSignalType*)getBuffer:(UInt32)numFrames {
    
    if (![self.component hasRendered]) {
        // If the component hasn't rendered, now's the time to do it
        // Render the component's inputs first
        [self.component renderInputs:numFrames];
        [self.component renderOutputs:numFrames];
    }
    
    return buffer;
}

-(AudioSignalType*)prepareBufferOfSize:(UInt32)numFrames {
    if (numFrames != bufferSize) {
        free(buffer);
        bufferSize = numFrames;
        buffer = (AudioSignalType*)malloc(bufferSize * sizeof(AudioSignalType));
        memset(buffer, 0, bufferSize * sizeof(AudioSignalType));
    }
    
    return buffer;
}

-(void)renderComponents:(UInt32)numFrames {
    if (![self.component hasRendered]) {
        [self.component renderInputs:numFrames];
        [self.component renderOutputs:numFrames];
    }
}

-(void)engineDidRender {
    [self.component engineDidRender];
}

-(BOOL)connectTo:(COLComponentInput *)input {
    if (input.type != self.type) {
        NSLog(@"Connection failed : Output and input types must match");
        return FALSE;
    }
    
    if (self.isConnected) {
        [self disconnect];
    }
    
    [[self connectedTo] setConnectedTo:nil];
    self.connectedTo = input;
    [input setConnectedTo:self];
    
    
    NSLog(@"%@ connected to %@", self.name, input.name);
        
    return TRUE;
}

-(BOOL)disconnect {
    if (self.connectedTo) {
        NSLog(@"%@ disconnected from %@", self.name, self.connectedTo.name);
        [[self connectedTo] setConnectedTo:nil];
        self.connectedTo = nil;
    }    
    return TRUE;
}

-(BOOL)isConnected {
    return self.connectedTo != nil;
}

@end
