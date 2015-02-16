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

@interface COLComponentOutput ()

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

-(void)renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {
     [self.component renderOutput:self toBuffer:outA samples:numFrames];
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
