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

@property (weak) COLComponentWavePlayer *component;
@property (weak) COLComponentLFO *lfo1;
@property (weak) COLComponent *lfo2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    COLAudioEnvironment *env = [COLAudioEnvironment sharedEnvironment];
    COLAudioContext *ctx = [COLAudioContext globalContext];
    
    self.component = (COLComponentWavePlayer*)[env createComponentOfType:kCOLComponentWavePlayer];
    [self.component setName:@"WavePlayer"];
    [self.component loadWAVFile:[[NSBundle mainBundle] URLForResource:@"loop" withExtension:@"wav"]];
    
    [[self.component outputForIndex:0] connectTo:[ctx masterInputAtIndex:0]];
    [[self.component outputForIndex:1] connectTo:[ctx masterInputAtIndex:1]];
    
    [[self.component parameterForIndex:0] setNormalizedValue:0.5];
    
    self.lfo1 = (COLComponentLFO*)[env createComponentOfType:kCOLComponentLFO];
    [[self.lfo1 parameterForIndex:0] setNormalizedValue:4];
    //[[self.lfo1 outputForIndex:0] connectTo:[self.component inputForIndex:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sliderDidChange:(id)sender {
    COLComponentParameter *parameter = [self.component parameterForIndex:0];
    
    [parameter setNormalizedValue:self.slider.value];
    NSLog(@"NormalizedValue : %.2f  Output : %.2f", [parameter getNormalizedValue], [parameter outputAtDelta:1]);
}


@end
