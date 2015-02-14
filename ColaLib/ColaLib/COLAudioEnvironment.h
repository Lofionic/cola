//
//  COLAudioEnvironment.h
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLAudioEngine.h"

@protocol COLAudioEnvironmentInfoDelegate <NSObject>

-(NSDictionary*)interAppInfoDictionary;

@end


@interface COLAudioEnvironment : NSObject <COLAudioEngineDelegate>

@property (nonatomic, weak) id infoDelegate;
@property (readonly) COLAudioEngine *audioEngine;

@property (nonatomic, strong) NSMutableArray *components;

+(instancetype)sharedEnvironment;
-(void)start;
-(Float64)sampleRate;


@end