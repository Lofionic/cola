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

-(void)setStepIndex:(NSUInteger)stepIndex {
    if (stepIndex < [self.sequence length]) {
        _stepIndex = stepIndex;
    } else {
        _stepIndex = 0;
    }
    NSLog(@"Step : %lu", (unsigned long)_stepIndex);
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
}

-(IBAction)touchKey:(id)sender {
    
    UIView *senderView = (UIView*)sender;
    
    Step *step = [self.sequence getStep:self.stepIndex];
    [step setNote:senderView.tag];
    
    [self updateUI];
}

-(IBAction)touchNexStep:(id)sender {
    self.stepIndex++;
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
    }
    return self;
}

@end

