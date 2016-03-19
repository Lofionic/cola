//
//  IAAView.m
//  ColaApp
//
//  Created by Chris on 31/05/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "IAAView.h"
#import "defines.h"

#import <ColaLib/CCOLTypes.h>

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iaaTransportStateDidChange:) name:kCCOLEventIAATransportStateDidChange object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)iaaTransportStateDidChange:(NSNotification*)note {
    [self updateContents];
}

-(void)updateContents {
    if (self.delegate) {
        // Update Host Image
        UIImage *hostImage = nil;
        if ([self.delegate respondsToSelector:@selector(getIAAHostImageForIAAView:)]) {
            hostImage = [self.delegate getIAAHostImageForIAAView:self];
        }
        
        bool isPlaying = false;
        if ([self.delegate respondsToSelector:@selector(isIAAHostPlayingForIAAView:)]) {
            isPlaying = [self.delegate isIAAHostPlayingForIAAView:self];
        }
        
        bool isRecording = false;
        if ([self.delegate respondsToSelector:@selector(isIAAHostRecordingForIAAView:)]) {
            isRecording = [self.delegate isIAAHostRecordingForIAAView:self];
        }
        
        // Update states of play / record toggles.
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.hostImageView setImage:[self.delegate getIAAHostImageForIAAView:self]];
            [self.playButton setSelected:isPlaying];
            [self.recordButton setSelected:isRecording];
        });
    }
}

-(void)hostImageTapped:(UIGestureRecognizer*)uigr {
    if (self.delegate && [self.delegate respondsToSelector:@selector(iaaViewDidTapHostImage:)]) {
        [self.delegate iaaViewDidTapHostImage:self];
    }
}

-(void)rewindTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(iaaViewdidTapRewind:)]) {
        [self.delegate iaaViewdidTapRewind:self];
    }
}

-(void)playTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(iaaViewDidTapPlay:)]) {
        [self.delegate iaaViewDidTapPlay:self];
    }
}

-(void)recordTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(iaaViewDidTapRecord:)]) {
        [self.delegate iaaViewDidTapRecord:self];
    }
}

@end
