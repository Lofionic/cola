//
//  FilesViewControllerCell.m
//  ColaApp
//
//  Created by Chris on 16/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "FilesViewControllerCell.h"
#import "PresetController.h"
#import <QuartzCore/QuartzCore.h>

#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 1

@interface FilesViewControllerCell()

@property (nonatomic, strong) UIView                        *thumbnailContainerView;
@property (nonatomic, strong) UIImageView                   *thumbnailView;

@property (nonatomic, strong) UIView                        *labelContainerView;
@property (nonatomic, strong) UILabel                       *presetNameLabel;
@property (nonatomic, strong) UILabel                       *dateLabel;
@property (nonatomic, strong) UIImageView                   *deleteImage;
@property (nonatomic, strong) UIActivityIndicatorView       *activityIndicator;

@property BOOL jiggling;

@end

@implementation FilesViewControllerCell

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
//        [self setBackgroundColor:[UIColor blackColor]];
//        [self.layer setBorderWidth:1.0];
//        [self.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
        
        self.thumbnailContainerView = [[UIView alloc] init];
        [self.thumbnailContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.thumbnailContainerView];
        
        self.thumbnailView = [[UIImageView alloc] init];
        [self.thumbnailView setContentMode:UIViewContentModeScaleAspectFit];
        [self.thumbnailView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.thumbnailContainerView addSubview:self.thumbnailView];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] init];
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [self.activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.thumbnailContainerView addSubview:self.activityIndicator];
        
        self.labelContainerView = [[UIView alloc] init];
        [self.labelContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.labelContainerView];
        
        self.presetNameLabel = [[UILabel alloc] init];
        [self.presetNameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.presetNameLabel setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:14]];
        [self.presetNameLabel setTextColor:[UIColor whiteColor]];
        [self.presetNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.labelContainerView addSubview:self.presetNameLabel];
        
        UITapGestureRecognizer *tapPresetName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapLabel:)];
        [self.labelContainerView addGestureRecognizer:tapPresetName];
//        [self.labelContainerView setUserInteractionEnabled:YES];
        
        self.dateLabel = [[UILabel alloc] init];
        [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
        [self.dateLabel setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:10]];
        [self.dateLabel setTextColor:[UIColor grayColor]];
        [self.dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.labelContainerView addSubview:self.dateLabel];
        
        // Layout
        NSDictionary *viewsDictionary = @{
                                          @"thumbnail"          :   self.thumbnailView,
                                          @"thumbnailContainer" :   self.thumbnailContainerView,
                                          @"labelContainer"     :   self.labelContainerView,
                                          @"nameLabel"          :   self.presetNameLabel,
                                          @"dateLabel"          :   self.dateLabel,
                                          @"activityIndicator"  :   self.activityIndicator
                                          };
        
        [self.thumbnailContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[thumbnail]-8-|" options:0 metrics:nil views:viewsDictionary]];
        [self.thumbnailContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[thumbnail]-8-|" options:0 metrics:nil views:viewsDictionary]];

        [self.thumbnailContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[activityIndicator]-8-|" options:0 metrics:nil views:viewsDictionary]];
        [self.thumbnailContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[activityIndicator]-8-|" options:0 metrics:nil views:viewsDictionary]];

        [self.labelContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[nameLabel(16)]-2-[dateLabel(16)]-4-|" options:0 metrics:nil views:viewsDictionary]];
        [self.labelContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[nameLabel]-8-|" options:0 metrics:nil views:viewsDictionary]];
        [self.labelContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[dateLabel]-8-|" options:0 metrics:nil views:viewsDictionary]];

        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[thumbnailContainer]|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[labelContainer]|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[thumbnailContainer][labelContainer]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDictionary]];
        
        [[self.thumbnailContainerView layer] setBorderColor:[[UIColor clearColor] CGColor]];
        [[self.thumbnailContainerView layer] setBorderWidth:2.0];
    }
    return self;
}

-(void)onTapThumbnail:(UIGestureRecognizer*)uigr {
    if ([self.delegate respondsToSelector:@selector(FilesViewControllerCellDidTapThumbnail:)]) {
        [self.delegate FilesViewControllerCellDidTapThumbnail:self];
    }
}

-(void)onTapLabel:(UIGestureRecognizer*)uigr {
    if ([self.delegate respondsToSelector:@selector(FilesViewControllerCellDidTapLabel:)]) {
        [self.delegate FilesViewControllerCellDidTapLabel:self];
    }
}

-(void)updateContents {
    
    // Fetch the thumbnail async
    [self.activityIndicator startAnimating];
    [[PresetController sharedController] fetchThumbnailForPresetAtIndex:self.presetIndex onCompletion:^(NSUInteger index, UIImage *image) {
        if (index == self.presetIndex) {
            [self.activityIndicator stopAnimating];
            [self.thumbnailView setImage:image];
        }
    }];

    [self.presetNameLabel setText:[[PresetController sharedController] nameOfPresetAtIndex:self.presetIndex]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    [self.dateLabel setText:[dateFormatter stringFromDate:[[PresetController sharedController] dateOfPresetAtIndex:self.presetIndex]]];
}

@synthesize selected = _selected;

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        [self.thumbnailContainerView setBackgroundColor:[UIColor colorWithRed:0.6 green:0 blue:0 alpha:1]];
        [self.thumbnailContainerView.layer setCornerRadius:16.0];
    } else {
        [self.thumbnailContainerView setBackgroundColor:[UIColor clearColor]];
        [self.thumbnailContainerView.layer setCornerRadius:0.0];
    }
    
    _selected = selected;
}

-(BOOL)selected {
    return _selected;
}

- (void)startJiggling {

    const float amplitude = 1.0f; // degrees
    float r = ( rand() / (float)RAND_MAX ) - 0.5f;
    float angleInDegrees = amplitude * (1.0f + r * 0.1f);
    float animationRotate = angleInDegrees / 180. * M_PI; // Convert to radians
    
    NSTimeInterval duration = 0.1;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.duration = duration;
    animation.additive = YES;
    animation.autoreverses = YES;
    animation.repeatCount = FLT_MAX;
    animation.fromValue = @(-animationRotate);
    animation.toValue = @(animationRotate);
    animation.timeOffset = ( rand() / (float)RAND_MAX ) * duration;
    [self.contentView.layer addAnimation:animation forKey:@"jiggle"];

}

- (void)stopJiggling {
    [self.contentView.layer removeAnimationForKey:@"jiggle"];
}

@end
