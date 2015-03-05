//
//  ViewController.m
//  ColaApp
//
//  Created by Chris on 11/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "ViewController.h"
#import <ColaLib/ColaLib.h>

@interface ViewController ()

@property (nonatomic, weak) COLComponentWavePlayer  *wave;
@property (nonatomic, weak) COLComponentOscillator  *osc;
@property (nonatomic, weak) COLCompenentEnvelope    *eg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    COLAudioEnvironment *env = [COLAudioEnvironment sharedEnvironment];
    COLAudioContext *ctx = [COLAudioContext globalContext];

    self.osc = (COLComponentOscillator*)[env createComponentOfType:kCOLComponentOscillator];
    [self.osc setName:@"Osc"];
    [[self.osc parameterForIndex:0] setNormalizedValue:0.2];
    
    self.wave = (COLComponentWavePlayer*)[env createComponentOfType:kCOLComponentWavePlayer];
    [self.wave setName:@"Wave"];
    [self.wave loadWAVFile:[[NSBundle mainBundle] URLForResource:@"loop" withExtension:@"wav"]];
    
    [[self.wave outputForIndex:0] connectTo:[ctx masterInputAtIndex:0]];
    
    self.eg = (COLCompenentEnvelope*)[env createComponentOfType:kCOLComponentEnvelope];
    [self.eg setName:@"EG"];
    [[self.eg parameterForIndex:0] setNormalizedValue:0.01];
    [[self.eg parameterForIndex:1] setNormalizedValue:0.5];
    [[self.eg parameterForIndex:2] setNormalizedValue:0.5];
    [[self.eg parameterForIndex:3] setNormalizedValue:0.5];
    
    [[self.eg outputForIndex:0] connectTo:[self.wave inputForIndex:1]];
    
    [self.eg setRetriggers:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sliderDidChange:(id)sender {
    [[self.wave parameterForIndex:0] setNormalizedValue:[self.slider value]];
}

-(IBAction)buttonDown:(id)sender {
    [self.eg openGate];
}

-(IBAction)buttonUp:(id)sender {
    [self.eg closeGate];
}

@end
