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
#import "COLComponentOscillator.h"
#import "COLComponents.h"
#import "COLComponentLFO.h"
#import "COLComponentWavePlayer.h"
#import "COLAudioContext.h"

@interface COLAudioEnvironment()

@property (nonatomic, strong) COLAudioEngine*   audioEngine;
@property (nonatomic, strong) NSMutableArray    *components;
@property (nonatomic) Float64                   sampleRate;

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
        
        self.keyboardComponent = [[COLKeyboardComponent alloc] initWithContext:[COLAudioContext globalContext]];
    }
    return self;
}

-(void)start {
    [self.audioEngine initializeAUGraph];
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

#pragma mark Component Factory
-(COLComponent*)createComponentOfType:(NSString *)componentType {
    
    COLAudioContext *context = [COLAudioContext globalContext];
    COLComponent *newComponent;
    
    if ([componentType isEqualToString:kCOLComponentOscillator]) {
        newComponent = [[COLComponentOscillator alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentLFO]) {
        newComponent = [[COLComponentLFO alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentWavePlayer]) {
        newComponent = [[COLComponentWavePlayer alloc] initWithContext:context];
    } else if ([componentType isEqualToString:kCOLComponentEnvelope]) {
        newComponent = [[COLCompenentEnvelope alloc] initWithContext:context];
    }
    
    if (newComponent) {
        [self.components addObject:newComponent];
    }

    return newComponent;
}

-(BOOL)removeComponent:(COLComponent*)component {
    if ([self.components containsObject:component]) {
        [component disconnectAll];
        [self.components removeObject:component];
        return TRUE;
    } else {
        return FALSE;
    }
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

@end
