//
//  COLAudioEnvironment.m
//  ColaLib
//
//  Created by Chris on 11/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLAudioEnvironment.h"

#import "CCOLAudioEngine.hpp"

@interface COLAudioEnvironment() {
    CCOLAudioEngine ccAudioEngine;
}

@property (nonatomic, strong) COLAudioEngine*   audioEngine;
@property (nonatomic, strong) NSMutableArray    *components;
@property (nonatomic) Float64                   sampleRate;

@property (nonatomic, strong) COLKeyboardComponent      *keyboardComponent;
@property (nonatomic, strong) COLTransportController    *transportController;

@end

@implementation COLAudioEnvironment

+ (instancetype) sharedEnvironment {
    static COLAudioEnvironment *sharedEnvironment = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEnvironment = [[self alloc] init];
    });
    return sharedEnvironment;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Get the current audiosession sample rate
        self.sampleRate = [[AVAudioSession sharedInstance] sampleRate];
                
        id appDelegate = [[UIApplication sharedApplication] delegate];
        if ([appDelegate conformsToProtocol:@protocol(COLAudioEnvironmentInfoDelegate) ]) {
            self.infoDelegate = appDelegate;
        }
        
//        self.audioEngine = [[COLAudioEngine alloc] init];
//        [self.audioEngine setDelegate:self];
        
        self.components = [[NSMutableArray alloc] initWithCapacity:10];
        
//        self.keyboardComponent = [[COLKeyboardComponent alloc] initWithContext:[COLAudioContext globalContext]];
//        self.transportController = [[COLTransportController alloc] init];
        
        // Cherry Cola
        ccAudioEngine.init();
    }
    return self;
}

-(void)start {
//    [self.audioEngine initializeAUGraph];
    
    ccAudioEngine.initializeAUGraph();
}

-(void)mute {
    //[self.audioEngine mute];
}
-(void)unmute {
    //[self.audioEngine unmute];
}

#pragma mark Component Factory
-(CCOLComponentAddress)createCComponentOfType:(char*)componentType {
    return ccAudioEngine.createComponent(componentType);
}

-(CCOLOutputAddress)getOutputNamed:(char*)outputName onComponent:(CCOLComponentAddress)componentAddress {
    return ccAudioEngine.getOutput(componentAddress, outputName);
}

-(BOOL)connectOutput:(CCOLOutputAddress)outputAddress toInput:(CCOLInputAddress)inputAddress {
    return ccAudioEngine.connect(outputAddress, inputAddress);
}

-(CCOLInputAddress)getMasterInputAtIndex:(UInt32)index {
    return ccAudioEngine.getMasterInput(index);
}

#pragma mark AudioEngine delegates

-(NSDictionary *)interAppInfoDictionaryForAudioEngine:(COLAudioEngine *)audioEngine {
    // Fetch the inter-app audio info from the app delegate
    if ([self.infoDelegate respondsToSelector:@selector(interAppInfoDictionary)]) {
        return [self.infoDelegate interAppInfoDictionary];
    }
    else {
        return nil;
    }
}

-(void)audioEngineInterAppAudioConnected:(COLAudioEngine *)audioEngine {
    NSLog(@"Inter-app audio connected");
}

-(void)audioEngineInterAppAudioDisconnected:(COLAudioEngine *)audioEngine {
    NSLog(@"Inter-app audio disconnected");
}

-(BOOL)isInterAppAudioConnected {
    // return [self.audioEngine iaaConnected];
    return NO;
}

-(void)exportEnvironment {
    // [COLExporter getJSONObjectForEnvironment:self];
}

@end
