//
//  COLAudioEnvironment.m
//  ColaLib
//
//  Created by Chris on 11/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "COLAudioEnvironment.h"
#import "COLAudioEngine.h"
#import "COLComponent.h"
#import "SinWaveComponent.h"
#import "SquareWaveComponent.h"
#import "LFOComponent.h"
#import "WavePlayerComponent.h"

@interface COLAudioEnvironment()

@property (nonatomic, strong) COLAudioEngine* audioEngine;
@property (nonatomic, strong) NSMutableArray *components;
@property (nonatomic) Float64 sampleRate;

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
        
        self.audioEngine = [[COLAudioEngine alloc] init];
        [self.audioEngine setDelegate:self];
        
        self.components = [[NSMutableArray alloc] initWithCapacity:10];
        
        [self prepareTest];
    }
    return self;
}

-(void)start {
    [self.audioEngine initializeAUGraph];
}

-(BOOL)connectComponent:(COLComponent*)component1 outputIndex:(NSInteger)outputIndex toComponet:(COLComponent*)component2 inputIndex:(NSInteger)inputIndex {
    
    if (component1.environment != component2.environment) {
        NSLog(@"Connection failed : Connecting components must exist in the same environment.");
        return FALSE;
    }
    
    COLComponentOutput *theOutput = [component1 outputForIndex:outputIndex];
    if (!theOutput) {
        NSLog(@"Connection failed : Invalid output");
        return FALSE;
    }
    
    COLComponentInput *theInput = [component2 inputForIndex:inputIndex];
    if (!theInput) {
        NSLog(@"Connection failed : Invalid input");
        return FALSE;
    }
    
    return [theOutput connectTo:theInput];
}

-(BOOL)connectComponent:(COLComponent*)component outputIndex:(NSInteger)outputIndex toMasterIndex:(NSInteger)masterIndex {
    
    COLComponentOutput *theOutput = [component outputForIndex:outputIndex];
    if (!theOutput) {
        NSLog(@"Connection failed : Invalid output");
        return FALSE;
    }
    
    COLComponentInput *theInput;
    if (masterIndex == 0) {
        theInput = [[self audioEngine] masterInputL];
    } else if (masterIndex == 1) {
        theInput = [[self audioEngine] masterInputR];
    }
    if (!theInput) {
        NSLog(@"Connection failed : Invalid input");
        return FALSE;
    }
    
    return [theOutput connectTo:theInput];
}

#pragma mark AudioEngine delegates

-(NSDictionary *)interAppInfoDictionaryForAudioEngine:(COLAudioEngine *)audioEngine {
    if ([self.infoDelegate respondsToSelector:@selector(interAppInfoDictionary)]) {
        return [self.infoDelegate interAppInfoDictionary];
    }
    else {
        return nil;
    }
}

#pragma mark Testing

-(void)prepareTest {
    NSLog(@"Setting up test environment");
    // Test environment
    {
        WavePlayerComponent *wavePlayer = [[WavePlayerComponent alloc] initWithEnvironment:self];
        [wavePlayer setName:@"Wave"];
        [self.components addObject:wavePlayer];
        
        [wavePlayer loadWAVFile:[[NSBundle mainBundle] URLForResource:@"gtr" withExtension:@"wav"]];
        
        [self connectComponent:wavePlayer outputIndex:0 toMasterIndex:0];
        [self connectComponent:wavePlayer outputIndex:1 toMasterIndex:1];
        
        
    }
}

@end
