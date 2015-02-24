//
//  COLComponent.h
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "COLComponentInput.h"
#import "COLComponentOutput.h"
#import "COLComponentParameter.h"

@class COLAudioEnvironment;
@class COLAudioContext;

@interface COLComponent : NSObject

@property (readonly, weak) COLAudioContext  *context;
@property (readonly, strong) NSArray        *outputs;
@property (readonly, strong) NSArray        *inputs;
@property (nonatomic, strong) NSString      *name;

@property (readonly) BOOL hasRendered;

-(NSUInteger)numberOfOutputs;
-(COLComponentOutput*)outputForIndex:(NSUInteger)index;

-(NSUInteger)numberOfInputs;
-(COLComponentInput *)inputForIndex:(NSUInteger)index;

-(COLComponentParameter*)parameterForIndex:(NSUInteger)index;

-(instancetype)initWithContext:(COLAudioContext*)context;
-(void)initializeIO;
-(void)renderOutputs:(UInt32)numFrames;
-(void)engineDidRender;

-(void)setOutputs:(NSArray*)outputs;
-(void)setInputs:(NSArray*)inputs;
-(void)setParameters:(NSArray*)parameters;
-(void)disconnectAll;

@end
