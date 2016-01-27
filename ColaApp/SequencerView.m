//
//  SequencerView.m
//  ColaApp
//
//  Created by Chris on 13/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import "SequencerView.h"
#import <ColaLib/COLAudioEnvironment.h>

@interface SequencerView()

@property (nonatomic) CCOLComponentAddress component;
@property (nonatomic, weak) UIView *mainView;

@property (nonatomic, weak) IBOutlet UIButton *downButton;

@end

@implementation SequencerView

-(instancetype)init {
    if (self = [super init]) {
//        self.mainView = [[[NSBundle mainBundle] loadNibNamed:@"SequencerView" owner:self options:nil] objectAtIndex:0];
//        [self.mainView setFrame:self.bounds];
//        [self.mainView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
//        
//        [self addSubview:self.mainView];
//    
//        [self createSequencerComponent];
//        
//        [self.downButton setSelected:true];
    }
    return self;
}

-(void)createSequencerComponent {
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    self.component = [cae createComponentOfType:"CCOLComponentTypeSequencer"];
}

- (IBAction)touchDownButton:(id)sender {
    NSLog(@"MEH");
}

- (IBAction)touchNoteButton:(id)sender {
    NSLog(@"FOO");
}

@end
