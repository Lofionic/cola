//
//  IAAView.m
//  ColaApp
//
//  Created by Chris on 31/05/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "IAAView.h"
#import "defines.h"

@interface IAAView()

@property (nonatomic, strong) UIImageView *hostImageView;
@property (nonatomic, strong) UIButton *rewindButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *recordButton;

@end

@implementation IAAView

-(instancetype)init {
    if (self = [super init]) {
        [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
        
        self.hostImageView = [[UIImageView alloc] init];
        [self.hostImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        UITapGestureRecognizer *hostImageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hostImageTapped:)];
        [self.hostImageView addGestureRecognizer:hostImageTapGesture];
        [self.hostImageView setUserInteractionEnabled:YES];
        [self addSubview:self.hostImageView];
        
        self.rewindButton = [[UIButton alloc] init];
        [self.rewindButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.rewindButton addTarget:self action:@selector(rewindTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.rewindButton setImage:[UIImage imageNamed:TRANSPORT_ICON_REWIND] forState:UIControlStateNormal];
        [self addSubview:self.rewindButton];
        
        self.playButton = [[UIButton alloc] init];
        [self.playButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.playButton addTarget:self action:@selector(playTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.playButton setImage:[UIImage imageNamed:TRANSPORT_ICON_PLAY] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:TRANSPORT_ICON_PAUSE] forState:UIControlStateSelected];
        [self addSubview:self.playButton];
        
        self.recordButton = [[UIButton alloc] init];
        [self.recordButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.recordButton addTarget:self action:@selector(recordTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.recordButton setImage:[UIImage imageNamed:TRANSPORT_ICON_RECORD] forState:UIControlStateNormal];
        [self.recordButton setImage:[UIImage imageNamed:TRANSPORT_ICON_RECORD_ON] forState:UIControlStateSelected];
        [self addSubview:self.recordButton];
        
        NSDictionary *viewsDictionary = @{
                                          @"hostImage":self.hostImageView,
                                          @"rewindButton":self.rewindButton,
                                          @"playButton":self.playButton,
                                          @"recordButton":self.recordButton,
                                          };
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[hostImage(50)]-4-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[hostImage(50)]-4-[rewindButton(80)]-4-[playButton(80)]-4-[recordButton(80)]"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:nil
                                                                       views:viewsDictionary]];
    }
    return self;
}

-(void)updateContents {
//    COLAudioEngine *audioEngine = [[COLAudioEnvironment sharedEnvironment] audioEngine];
//    [self.hostImageView setImage:[audioEngine iaaHostImage]];
//    
//    [self.playButton setSelected:audioEngine.isHostPlaying];
//    [self.recordButton setSelected:audioEngine.isHostRecording];
}

-(void)hostImageTapped:(UIGestureRecognizer*)uigr {
//    COLAudioEngine *audioEngine = [[COLAudioEnvironment sharedEnvironment] audioEngine];
//    [audioEngine iaaGotoHost];
}

-(void)rewindTapped {
//    COLAudioEngine *audioEngine = [[COLAudioEnvironment sharedEnvironment] audioEngine];
//    [audioEngine iaaRewind];
}

-(void)playTapped {
//    COLAudioEngine *audioEngine = [[COLAudioEnvironment sharedEnvironment] audioEngine];
//    [audioEngine iaaTogglePlay];
}

-(void)recordTapped {
//    COLAudioEngine *audioEngine = [[COLAudioEnvironment sharedEnvironment] audioEngine];
//    [audioEngine iaaToggleRecord];
}

@end
