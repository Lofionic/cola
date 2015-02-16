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

@class COLAudioEnvironment;

@interface COLComponent : NSObject <COLOutputDelegate>

@property (readonly, weak) COLAudioEnvironment *environment;
@property (nonatomic, strong) NSString *name;

-(NSInteger)numberOfOutputs;
-(COLComponentOutput*)outputForIndex:(NSInteger)index;

-(NSInteger)numberOfInputs;
-(COLComponentInput *)inputForIndex:(NSInteger)index;

-(instancetype)initWithEnvironment:(COLAudioEnvironment*)environment;
-(void)renderOutput:(COLComponentOutput *)output toBuffer:(AudioSignalType *)outA samples:(UInt32)numFrames;
-(void)initializeIO;

-(void)setOutputs:(NSArray*)outputs;
-(void)setInputs:(NSArray*)inputs;

@end
