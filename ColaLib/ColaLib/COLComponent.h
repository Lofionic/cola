//
//  COLComponent.h
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "COLAudioContext.h"
#import "COLComponentInput.h"
#import "COLComponentOutput.h"
#import "COLComponentParameter.h"

@class COLAudioEnvironment;

@interface COLComponent : NSObject <COLOutputDelegate>

@property (readonly, weak) COLAudioContext *context;
@property (readonly, strong) NSArray *outputs;
@property (readonly, strong) NSArray *inputs;
@property (nonatomic, strong) NSString *name;
@property (readonly) BOOL hasRendered;

-(NSInteger)numberOfOutputs;
-(COLComponentOutput*)outputForIndex:(NSInteger)index;

-(NSInteger)numberOfInputs;
-(COLComponentInput *)inputForIndex:(NSInteger)index;

-(instancetype)initWithContext:(COLAudioContext*)context;
-(void)initializeIO;
-(void)renderOutputs:(UInt32)numFrames;
-(void)engineDidRender;

-(void)setOutputs:(NSArray*)outputs;
-(void)setInputs:(NSArray*)inputs;

@end
