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
    
    if (component1.context != component2.context) {
        NSLog(@"Connection failed : Connecting components must exist in the same context.");
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
        SinWaveComponent *component = [[SinWaveComponent alloc] initWithContext:[COLAudioContext globalContext]];
        [component setName:@"Wave"];
       [self.components addObject:component];
        
        LFOComponent *lfo = [[LFOComponent alloc] initWithContext:[COLAudioContext globalContext]];
        [lfo setName:@"LFO"];
        [self.components addObject:lfo];
        
        //[self connectComponent:lfo outputIndex:0 toComponet:component inputIndex:0];
        //[self connectComponent:component outputIndex:0 toMasterIndex:0];
        
        SquareWaveComponent *square = [[SquareWaveComponent alloc] initWithContext:[COLAudioContext globalContext]];
        [square setName:@"square"];
        [self.components addObject:square];
        
        LFOComponent *lfo2 = [[LFOComponent alloc] initWithContext:[COLAudioContext globalContext]];
        [lfo2 setName:@"LFO2"];
        [self.components addObject:lfo2];
        
        [self connectComponent:lfo2 outputIndex:0 toComponet:square inputIndex:1];
        [self connectComponent:square outputIndex:0 toMasterIndex:1];
        
        WavePlayerComponent *wavePlayer = [[WavePlayerComponent alloc] initWithContext:[COLAudioContext globalContext]];
        [wavePlayer setName:@"WavePlayer"];
        [wavePlayer loadWAVFile:[[NSBundle mainBundle] URLForResource:@"gtr" withExtension:@"wav"]];
        [self.components addObject:wavePlayer];
        
        [self connectComponent:wavePlayer outputIndex:0 toMasterIndex:0];
        [self connectComponent:wavePlayer outputIndex:2 toComponet:square inputIndex:1];
    }
}

@end
