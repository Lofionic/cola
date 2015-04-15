//
//  COLComponent.m
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLAudioEnvironment.m"
#import "COLAudioEngine.H"
#import "COLComponent.h"
#import "COLComponentInput.h"
#import "COLComponentOutput.h"
#import "COLContinuousParameter.h"


@interface COLComponent ()

@property (nonatomic, weak) COLAudioContext *context;
@property (nonatomic, strong) NSArray *inputs;
@property (nonatomic, strong) NSArray *outputs;
@property (nonatomic, strong) NSArray *parameters;
@property (nonatomic) BOOL hasRendered;

@end

@implementation COLComponent

-(instancetype)initWithContext:(COLAudioContext *)context {
    self = [super init];
    if (self) {
        self.context = context;
        [self initializeIO];
    }
    return self;
}

-(void)assignUniqueName {
    NSUInteger componentCount = 0;
    NSString *name;
    BOOL uniqueName = NO;
    
    while (!uniqueName) {
        componentCount ++;
        name = [NSString stringWithFormat:@"%@ %lu", [self.class defaultName], (unsigned long)componentCount];
        uniqueName = YES;
        for (COLComponent *thisComponent in [[COLAudioEnvironment sharedEnvironment] components]) {
            if ([thisComponent.identifier isEqualToString:name]) {
                uniqueName = NO;
            }
        }
    };
    
    self.identifier = name;
}

-(void)initializeIO {
    // Override this method to setup the component's IO & parameters
}

// Data source
-(NSUInteger)numberOfOutputs {
    return [self.outputs count];
}

-(COLComponentOutput *)outputForIndex:(NSUInteger)index {
    if (index < [self.outputs count]) {
        return [self.outputs objectAtIndex:index];
    } else {
        return nil;
    }
}

-(COLComponentOutput *)outputNamed:(NSString*)name {
    
    __block COLComponentOutput *result = nil;
    
    [self.outputs enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        COLComponentOutput *thisOutput = (COLComponentOutput*)obj;
        if ([thisOutput.name isEqualToString:name]) {
            result = thisOutput;
            *stop = YES;
        }
    }];
    
    return result;
}

-(NSUInteger)numberOfInputs {
    return [self.inputs count];
}

-(COLComponentInput *)inputForIndex:(NSUInteger)index {
    if (index < [self.inputs count]) {
        return [self.inputs objectAtIndex:index];
    } else {
        return nil;
    }
}

-(COLComponentInput *)inputNamed:(NSString*)name {
    
    __block COLComponentInput *result = nil;
    
    [self.inputs enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        COLComponentInput *thisInput = (COLComponentInput*)obj;
        if ([thisInput.name isEqualToString:name]) {
            result = thisInput;
            *stop = YES;
        }
    }];
    
    return result;
}

-(NSUInteger)numberOfParameters {
    return [self.parameters count];
}

-(COLParameter*)parameterForIndex:(NSUInteger)index {
    if (index < [self.parameters count]) {
        return [self.parameters objectAtIndex:index];
    } else {
        NSLog(@"Warning: Invalid parameter index %lu for component %@", (unsigned long)index, self.identifier);
        return nil;
    }
}

-(COLParameter *)parameterNamed:(NSString*)name {
    
    __block COLParameter *result = nil;
    
    [self.parameters enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        COLParameter *thisParameter = (COLParameter*)obj;
        if ([thisParameter.name isEqualToString:name]) {
            result = thisParameter;
            *stop = YES;
        }
    }];
    
    return result;
}

-(void)renderOutputs:(UInt32)numFrames {
    self.hasRendered = YES;
}

// Called when engine render has completed
-(void)engineDidRender {
    self.hasRendered = NO;
    for (COLComponentInput *thisInput in self.inputs) {
        [thisInput engineDidRender];
    }
    
    for (COLParameter *thisParameter in self.parameters) {
        [thisParameter engineDidRender];
    }
}

-(void)disconnectAll {
    for (COLComponentOutput* thisOutput in self.outputs) {
        [thisOutput disconnect];
    }
    
    for (COLComponentInput* thisInput in self.inputs) {
        [thisInput disconnect];
    }
}

-(void)parameterDidChange:(COLParameter *)parameter {

}

+(NSString*)defaultName {
    return @"Component";
}

@end
