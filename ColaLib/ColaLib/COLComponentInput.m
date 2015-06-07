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
#import "COLComponent.h"

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

@synthesize connectedTo = _connectedTo;

-(void)setConnectedTo:(COLComponentIO *)connectedTo { 
    _connectedTo = connectedTo;
}

-(COLComponentIO*)connectedTo {
    return _connectedTo;
}

-(BOOL)makeDynamicConnectionWithOutput:(COLComponentOutput *)output {
    if ([self isDynamic]) {
        kComponentIOType dynamicType = output.type;
        NSArray *componentOutputs = [[self.component outputs] copy];
        NSMutableArray *disconnectedOutputs = [[NSMutableArray alloc] initWithCapacity:componentOutputs.count];
        for (COLComponentOutput *thisOutput in componentOutputs) {
            if ([thisOutput isDynamic] &&
                [thisOutput connectedTo] &&
                thisOutput.linkedInput == self &&
                [[thisOutput connectedTo] type] != dynamicType) {
                    // thisOutput is dynamically linked to this input
                [thisOutput disconnect];
                [disconnectedOutputs addObject:thisOutput];
            }
        }
        
        if ([disconnectedOutputs count] > 0) {
            NSDictionary *userInfo = @{
                                       @"input" :   self,
                                       @"disconnectedOutputs" : disconnectedOutputs
                                       };
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kCOLEventDynamicInputDidForceDisconnect
                                                                object:nil
                                                              userInfo:userInfo];
        }
        
        return true;
    } else {
        NSLog(@"Error : Attempted to make dynamic connection with an input that is not dynamic.");
        return false;
    }
}

@synthesize type = _type;
-(kComponentIOType)type {
    if (_type != kComponentIOTypeDynamic || !self.connectedTo) {
        return _type;
    } else {
        return [self.connectedTo type];
    }
}

-(void)setType:(kComponentIOType)newType {
    _type = newType;
}

-(BOOL)isDynamic {
    return _type == kComponentIOTypeDynamic;
}


@end
