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

@property (weak) COLComponent *osc;
@property (weak) COLComponentLFO *lfo1;
@property (weak) COLComponent *lfo2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    COLAudioEnvironment *env = [COLAudioEnvironment sharedEnvironment];
    
    self.osc = [env createComponentOfType:kCOLComponentOscillator];
    [self.osc setName:@"osc"];
    [self.osc setValue:0.1f forParameterAtIndex:0];

    [[self.osc outputForIndex:0] connectTo:[[COLAudioContext globalContext] masterInputAtIndex:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sliderDidChange:(id)sender {
    [self.osc setValue:self.slider.value / 4 forParameterAtIndex:0];}

@end
