//
//  IAAView.m
//  ColaApp
//
//  Created by Chris on 31/05/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "IAAView.h"
#import <ColaLib/ColaLib.h>

@interface IAAView()

@property (nonatomic, strong) UIImageView *hostImageView;

@end

@implementation IAAView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
        
        self.hostImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 50, 50)];
        UITapGestureRecognizer *hostImageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hostImageTapped:)];
        [self.hostImageView addGestureRecognizer:hostImageTapGesture];
        [self.hostImageView setUserInteractionEnabled:YES];
        [self addSubview:self.hostImageView];
    }
    return self;
}

-(void)updateContents {
    COLAudioEngine *audioEngine = [[COLAudioEnvironment sharedEnvironment] audioEngine];
    [self.hostImageView setImage:[audioEngine iaaHostImage]];
}

-(void)hostImageTapped:(UIGestureRecognizer*)uigr {
    COLAudioEngine *audioEngine = [[COLAudioEnvironment sharedEnvironment] audioEngine];
    [audioEngine iaaGotoHost];
}

@end
