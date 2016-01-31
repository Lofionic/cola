//
//  SequencerSubview.m
//  ColaApp
//
//  Created by Chris on 27/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import "SequencerSubview.h"
#import "SequencerLED.h"

@interface SequencerSubview()

@property (nonatomic, weak)     UIView *view;
@property (nonatomic, strong)   IBOutletCollection(SequencerLED) NSArray *noteLEDs;
@property (nonatomic, strong)   IBOutletCollection(SequencerLED) NSArray *stepLEDs;
@property (nonatomic, strong)   IBOutlet SequencerLED* timeModeOnLED;
@property (nonatomic, strong)   IBOutlet SequencerLED* timeModeTiedLED;
@property (nonatomic, strong)   IBOutlet SequencerLED* octaveDownLED;
@property (nonatomic, strong)   IBOutlet SequencerLED* octaveUpLED;
@property (nonatomic, strong)   IBOutlet SequencerLED* slideLED;

@property (nonatomic, strong)   StepSequence *sequence;
@property (nonatomic)           NSUInteger stepIndex;

@end

@implementation SequencerSubview

-(instancetype)initWithComponent:(CCOLComponentAddress)component description:(SubviewDescription*)description {
    if (self = [super initWithComponent:component description:description]) {
        // Load the sequencer view from xib
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"SequencerSubview" owner:self options:nil] objectAtIndex:0];
        [self.view setFrame:self.bounds];
        [self.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        
        [self addSubview:self.view];
        
        self.sequence = [[StepSequence alloc] initWithLength:16];
        [self setStepIndex:0];
    }
    return self;
}

-(void)didMoveToSuperview {
    [self updateUI];
}

-(void)updateUI {
    Step *step = [self.sequence getStep:self.stepIndex];
    
    for (int i = 0; i < 13; i++) {
        if (i == step.note) {
            [self.noteLEDs[i] setLevel:1];
        } else {
            [self.noteLEDs[i] setLevel:0];
        }
    }
    
    for (int i = 0; i < 16; i++) {
        if (i == self.stepIndex) {
            [self.stepLEDs[i] setLevel:1];
        } else {
            [self.stepLEDs[i] setLevel:0];
        }
    }
    
    [self.timeModeOnLED setLevel:(step.timeMode == TimeModeOn ? 1.0 : 0.0)];
    [self.timeModeTiedLED setLevel:(step.timeMode == TimeModeTied ? 1.0 : 0.0)];
    
    switch (step.octave) {
        case 0:
            [self.octaveDownLED setLevel:1.0];
            [self.octaveDownLED setBlinking:true];
            [self.octaveUpLED setLevel:0.0];
            [self.octaveUpLED setBlinking:false];
            break;
        case 1:
            [self.octaveDownLED setLevel:1.0];
            [self.octaveDownLED setBlinking:false];
            [self.octaveUpLED setLevel:0.0];
            [self.octaveUpLED setBlinking:false];
            break;
        case 2:
            [self.octaveDownLED setLevel:0.0];
            [self.octaveDownLED setBlinking:false];
            [self.octaveUpLED setLevel:0.0];
            [self.octaveUpLED setBlinking:false];
            break;
        case 3:
            [self.octaveDownLED setLevel:0.0];
            [self.octaveDownLED setBlinking:false];
            [self.octaveUpLED setLevel:1.0];
            [self.octaveUpLED setBlinking:false];
            break;
        case 4:
            [self.octaveDownLED setLevel:0.0];
            [self.octaveDownLED setBlinking:false];
            [self.octaveUpLED setLevel:1.0];
            [self.octaveUpLED setBlinking:true];
            break;
        default:
            break;
    }
    
    [self.slideLED setLevel:(step.slide ? 1.0 : 0.0)];
}

#pragma IBActions

-(IBAction)touchKey:(id)sender {
    
    UIView *senderView = (UIView*)sender;
    
    Step *step = [self.sequence getStep:self.stepIndex];
    [step setNote:senderView.tag];

    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    CCOLParameterAddress parameter = [cae getParameterNamed:[NSString stringWithFormat:@"Pitch %ld", (long)senderView.tag + 1] onComponent:self.component];
    [cae setParameter:parameter value:(senderView.tag / 13.0)];
    
    [self updateUI];
}

-(IBAction)touchTimeMode:(id)sender {
    
    Step *step = [self.sequence getStep:self.stepIndex];
    
    if (step.timeMode == TimeModeTied) {
        step.timeMode = TimeModeOff;
    } else {
        step.timeMode++;
    }
    
    [self updateUI];
}

-(IBAction)touchOctaveDown:(id)sender {
    Step *step = [self.sequence getStep:self.stepIndex];
    if (step.octave > 0) {
        step.octave --;
    }
    [self updateUI];
}

-(IBAction)touchOctacveUp:(id)sender {
    Step *step = [self.sequence getStep:self.stepIndex];
    if (step.octave < 4) {
        step.octave ++;
    }
    [self updateUI];
}

-(IBAction)touchSlide:(id)sender {
    Step *step = [self.sequence getStep:self.stepIndex];
    step.slide = !step.slide;
    [self updateUI];
}

-(IBAction)touchNexStep:(id)sender {
    if (self.stepIndex < self.sequence.length - 1) {
        ++self.stepIndex;
    } else {
        [self setStepIndex:0];
    }
    
    [self updateUI];
}

-(IBAction)touchBackStep:(id)sender {
    if (self.stepIndex == 0) {
        [self setStepIndex:self.sequence.length - 1];
    } else {
        --self.stepIndex;
    }
    
    [self updateUI];
}

@end

@interface StepSequence()

@property (nonatomic) NSUInteger length;
@property (nonatomic, strong) NSArray *steps;

@end

@implementation StepSequence

- (instancetype)initWithLength:(NSUInteger)length {
    self = [super init];
    if (self) {
        self.length = length;
        self.steps = [self createEmptyPatternOfLenght:16];
    }
    return self;
}

-(NSArray*)createEmptyPatternOfLenght:(NSUInteger)length {
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        [result addObject:[[Step alloc] init]];
    }
    
    return [NSArray arrayWithArray:result];
}

-(Step *)getStep:(NSUInteger)index {
    if (index < self.length) {
        return [self.steps objectAtIndex:index];
    } else {
        return nil;
    }
}

@end

@implementation Step

-(instancetype)init {
    if (self = [super init]) {
        self.note = 0;
        self.octave = 2;
        self.timeMode = TimeModeOff;
        self.slide = false;
    }
    return self;
}

@end

