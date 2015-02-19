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

@property (weak) COLComponentWavePlayer *waveplayer;
@property (weak) COLComponentLFO *lfo1;
@property (weak) COLComponent *lfo2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    COLAudioEnvironment *env = [COLAudioEnvironment sharedEnvironment];
    COLAudioContext *ctx = [COLAudioContext globalContext];
    
    self.waveplayer = (COLComponentWavePlayer*)[env createComponentOfType:kCOLComponentWavePlayer];
    [self.waveplayer loadWAVFile:[[NSBundle mainBundle] URLForResource:@"gtr" withExtension:@"wav"]];
    [[self.waveplayer outputForIndex:0] connectTo:[ctx masterInputAtIndex:0]];
    
    self.lfo1 = (COLComponentLFO*)[env createComponentOfType:kCOLComponentLFO];
    [self.lfo1 setFrequency:1];
    [[self.lfo1 outputForIndex:0] connectTo:[self.waveplayer inputForIndex:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
   
}

@end
