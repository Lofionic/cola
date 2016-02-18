//
//  SequencerLED.m
//  ColaApp
//
//  Created by Chris on 26/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import "SequencerLED.h"

#define NOTIFICATION_LED_BLINK @"Notification_LED_Blink"
#define NOTIFICATION_KEY_BLINKON @"Notification_Key_BlinkOn"

@interface SequencerLED()

@property (nonatomic, strong)   UIImage *imageRoll;
@property (nonatomic)           CGSize imageFrameSize;
@property (nonatomic)           CGRect imageDrawRect;
@property (nonatomic)           bool mute;

// IB properties
//#if TARGET_INTERFACE_BUILDER
@property (nonatomic, strong)   UIImage *ibImage;
@property (nonatomic)           CGRect ibDrawRect;
//#endif

@end

@implementation SequencerLED

// A universal timer to sync blinking across all LEDs, maintained whilst 1+ LEDs exist
static int blinkCount = 0;
static bool blinking = false;
static bool blinkOn = false;

// Must be called whenever a new LED is created.
+(void)addBlinkCount {
    blinkCount ++;
    if (!blinking) {
        // Start the timer.
        blinking = true;
        [NSTimer scheduledTimerWithTimeInterval:0.2
                                         target:self
                                       selector:@selector(blink:)
                                       userInfo:nil
                                        repeats:YES];
    }
}

// Must be called whenever an LED is destroyed.
+(void)removeBlinkCount {
    blinkCount--;
}

+(void)blink:(NSTimer*)timer {
    blinkOn = !blinkOn;
    
    // Post notification for LEDs to change their blink state.
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LED_BLINK object:nil userInfo:@{ NOTIFICATION_KEY_BLINKON : [NSNumber numberWithBool:blinkOn] }];
    
    // When blinkcount is 0, we have no LEDs to blink.
    if (blinkCount == 0) {
        blinking = false;
        [timer invalidate];
    }
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [SequencerLED addBlinkCount];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [SequencerLED addBlinkCount];
    }
    return self;
}

-(instancetype)init {
    if (self = [super init]) {
        [SequencerLED addBlinkCount];
    }
    return self;
}

-(void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self setUserInteractionEnabled:false];
    [self loadImageRoll];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blinkDidChange:) name:NOTIFICATION_LED_BLINK object:nil];
}

-(void)blinkDidChange:(NSNotification*)note {
    self.mute = (self.blinking && !blinkOn);
    [self setNeedsDisplay];
}

-(void)setBlinking:(bool)blinking {
    _blinking = blinking;
    
    if (!blinking) {
        self.mute = false;
    }
}

-(void)loadImageRoll {
    self.imageRoll = [UIImage imageNamed:@"sequencer_led"];
    if (self.imageRoll) {
        float screenScale = [[UIScreen mainScreen] scale];
        self.imageFrameSize = CGSizeMake(self.imageRoll.size.width * screenScale, (self.imageRoll.size.height / 11) * screenScale);
    } else {
        self.imageFrameSize = CGSizeMake(0, 0);
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.imageRoll) {
        // Calculate a centered rect to draw into
        float frameSize = self.imageRoll.size.width;
        
        float offsetX = (self.bounds.size.width - frameSize) / 2.0;
        float offsetY = (self.bounds.size.height -  frameSize) / 2.0;
        
        self.imageDrawRect = CGRectMake(offsetX, offsetY, frameSize, frameSize);
    } else {
        self.imageDrawRect = CGRectMake(0, 0, 0, 0);
    }
}

-(void)setLevel:(float)level {
    _level = level;
    [self setNeedsDisplay];
}

#if TARGET_INTERFACE_BUILDER
-(void)prepareForInterfaceBuilder {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    self.ibImage = [UIImage imageNamed:@"sequencer_led" inBundle:bundle compatibleWithTraitCollection:self.traitCollection];
    
    if (self.ibImage) {
        // Calculate a centered rect to draw into
        float frameSize = self.ibImage.size.width ;
        float offsetX = (self.bounds.size.width - frameSize) / 2.0;
        float offsetY = (self.bounds.size.height -  frameSize) / 2.0;
        
        self.ibDrawRect = CGRectMake(offsetX, offsetY, frameSize, frameSize);
    } else {
        self.ibDrawRect = CGRectMake(0, 0, 0, 0);
    }
}
#endif

- (void)drawRect:(CGRect)rect {
#if TARGET_INTERFACE_BUILDER
    // Custom drawing code for IB
    if (self.ibImage) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1.0, -1.0);

        float scale = [[UIScreen mainScreen] scale];
        CGImageRef drawImage = CGImageCreateWithImageInRect([self.ibImage CGImage], CGRectMake(0, 0 * scale, 20 * scale , 20 * scale));
   
        CGContextDrawImage(ctx, CGRectApplyAffineTransform(self.ibDrawRect, CGAffineTransformMakeScale(1.0, -1.0)), drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(ctx);
    }
#else
    if (self.imageRoll) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        NSInteger frame;
    
        if (self.mute) {
           frame = 0;
        } else {
            frame = floor((self.level / 1.0) * 10);
        }
        CGRect sourceRect = CGRectMake(0, (frame * self.imageFrameSize.height), self.imageFrameSize.width, self.imageFrameSize.height);
        CGImageRef drawImage = CGImageCreateWithImageInRect([self.imageRoll CGImage], sourceRect);
        
        CGContextDrawImage(ctx, CGRectApplyAffineTransform(self.imageDrawRect, CGAffineTransformMakeScale(1.0, -1.0)), drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(ctx);
    }
#endif
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [SequencerLED removeBlinkCount];
}


@end
