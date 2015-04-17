//
//  FilesViewControllerCell.m
//  ColaApp
//
//  Created by Chris on 16/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "FilesViewControllerCell.h"

#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 1

@interface FilesViewControllerCell()

@property (nonatomic, strong) UIImageView   *thumbnailView;
@property (nonatomic, strong) UILabel       *presetNameLabel;
@property (nonatomic, strong) UILabel       *dateLabel;
@property (nonatomic, strong) UIImageView   *deleteImage;

@property BOOL jiggling;

@end

@implementation FilesViewControllerCell

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 16, frame.size.width - 16, frame.size.height - 58)];
        [self.thumbnailView setBackgroundColor:[UIColor clearColor]];
        [self.thumbnailView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:self.thumbnailView];
        
        self.presetNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, frame.size.height - 40, frame.size.width - 16, 16)];
        [self.presetNameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.presetNameLabel setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:14]];
        [self.presetNameLabel setTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.presetNameLabel];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, frame.size.height - 24, frame.size.width - 16, 16)];
        [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
        [self.dateLabel setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:10]];
        [self.dateLabel setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:self.dateLabel];
        
        [self.layer setBorderColor:[[UIColor clearColor] CGColor]];
        [self.layer setBorderWidth:2.0];
    }
    return self;
}

-(void)updateContents {
    
    if (self.preset.thumbnail) {
        [self.thumbnailView setImage:self.preset.thumbnail];
    } else {
        [self.thumbnailView setImage:nil];
    }
    
    [self.presetNameLabel setText:self.preset.name];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    [self.dateLabel setText:[dateFormatter stringFromDate:self.preset.saveDate]];
}

@synthesize selected = _selected;

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        [self.layer setBorderColor:[[UIColor redColor] CGColor]];
    } else {
        [self.layer setBorderColor:[[UIColor clearColor] CGColor]];
    }
    
    _selected = selected;
}

-(BOOL)selected {
    return _selected;
}


@synthesize highlighted = _highlighted;

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        [self.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    } else {
        [self.layer setBorderColor:[[UIColor clearColor] CGColor]];
    }
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
