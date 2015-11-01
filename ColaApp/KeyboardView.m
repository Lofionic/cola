//
//  keyboardView.m
//  iPhoneAudio2
//
//  Created by Chris on 9/9/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "KeyboardView.h"

@implementation KeyboardView {
    int octaves;
    int keyValues[88];
    CGRect keyRects[88];
    NSMutableDictionary *keyTouches;
    NSSet *prevKeysDown;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.backgroundColor = [UIColor redColor];
        self.keyboardShift = 2;
        [self initKeys];
    }
    return self;
}

-(void)awakeFromNib {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    self.backgroundColor = [UIColor redColor];
    self.keyboardShift = 2;
    [self initKeys];
}

-(void)initKeys {
    
    keyTouches = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        octaves = 2;
    } else {
        octaves = 1;
    }
    
    CGFloat keyWidth = 1.0 / ((octaves * 7.0) + 1);
    CGFloat keyHeight = 1;
    CGFloat blackKeyHeight = 1 * 0.6;
    CGFloat blackKeyWidth = keyWidth / 1.5;
    
    int thisKey = 0;
    
    for (int i = 0; i < octaves; i++ ) {
        
        CGFloat leftPoint = i * keyWidth * 7.0;
        keyRects[thisKey + 0] = CGRectMake(leftPoint, 0, keyWidth, keyHeight); // C
        keyValues[thisKey + 0] = thisKey + 0;
        
        keyRects[thisKey + 1] = CGRectMake(leftPoint + keyWidth, 0, keyWidth, keyHeight); // D
        keyValues[thisKey + 1] = thisKey + 2;
        
        keyRects[thisKey + 2] = CGRectMake(leftPoint + (keyWidth * 2.0), 0, keyWidth, keyHeight); // E
        keyValues[thisKey + 2] = thisKey + 4;
        
        keyRects[thisKey + 3] = CGRectMake(leftPoint + (keyWidth * 3.0), 0, keyWidth, keyHeight); // F
        keyValues[thisKey + 3] = thisKey + 5;
        
        keyRects[thisKey + 4] = CGRectMake(leftPoint + (keyWidth * 4.0), 0, keyWidth, keyHeight); // G
        keyValues[thisKey + 4] = thisKey + 7;
        
        keyRects[thisKey + 5] = CGRectMake(leftPoint + (keyWidth * 5.0), 0, keyWidth, keyHeight); // A
        keyValues[thisKey + 5] = thisKey + 9;
        
        keyRects[thisKey + 6] = CGRectMake(leftPoint + (keyWidth * 6.0), 0, keyWidth, keyHeight); // B
        keyValues[thisKey + 6] = thisKey + 11;
        
        keyRects[thisKey + 7] = CGRectMake(leftPoint + (keyWidth * 0.6), 0, blackKeyWidth, blackKeyHeight); // C#
        keyValues[thisKey + 7] = thisKey + 1;
        
        keyRects[thisKey + 8] = CGRectMake(leftPoint + (keyWidth * 1.7), 0, blackKeyWidth, blackKeyHeight); // Eb
        keyValues[thisKey + 8] = thisKey + 3;
        
        keyRects[thisKey + 9] = CGRectMake(leftPoint + (keyWidth * 3.6), 0, blackKeyWidth, blackKeyHeight); // F#
        keyValues[thisKey + 9] = thisKey + 6;
        
        keyRects[thisKey + 10] = CGRectMake(leftPoint + (keyWidth * 4.65), 0, blackKeyWidth, blackKeyHeight); // Ab
        keyValues[thisKey +10] = thisKey + 8;
        
        keyRects[thisKey + 11] = CGRectMake(leftPoint + (keyWidth * 5.7), 0, blackKeyWidth, blackKeyHeight); // Bb
        keyValues[thisKey + 11] = thisKey + 10;
        
        thisKey += 12;
    }
    
    keyRects[thisKey] = CGRectMake(octaves * keyWidth * 7.0, 0, keyWidth, keyHeight);
    keyValues[thisKey] = thisKey;
    
    prevKeysDown = [[NSSet alloc] init];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch* thisTouch in touches) {
        
        NSNumber *thisTouchRef = [NSNumber numberWithInt:(int)(size_t)thisTouch];
        
        CGPoint touchLocation = [thisTouch locationInView:self];
        CGPoint touchNormalized = CGPointMake(
                                              touchLocation.x / self.bounds.size.width,
                                              touchLocation.y / self.bounds.size.height);
        
        int keyCount = (octaves * 12) + 1;
        for (int i = 0; i < keyCount; i++){
            if (CGRectContainsPoint(keyRects[i], touchNormalized)) {
                [keyTouches setObject:thisTouch forKey:thisTouchRef];
            }
        }
    }
    
    [self updateKBComponent];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *thisTouch in touches) {
        
        NSNumber *thisTouchRef = [NSNumber numberWithInt:(int)(size_t)thisTouch];
        [keyTouches removeObjectForKey:thisTouchRef];
    }
    
    [self updateKBComponent];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateKBComponent];
}

-(void)updateKBComponent {
    
    int keyCount = (octaves * 12) + 1;
    
    // Store the current keyboard state
    NSMutableSet *keysDown = [[NSMutableSet alloc] initWithCapacity:10];
    
    // Process all touches and record which keys are pressed
    for (UITouch *thisTouch in [keyTouches allValues]) {
        CGPoint touchLocation = [thisTouch locationInView:self];
        CGPoint touchNormalized = CGPointMake(
                                              touchLocation.x / self.bounds.size.width,
                                              touchLocation.y / self.bounds.size.height);
        
        for (int i = keyCount; i >= 0; i--){
            if (CGRectContainsPoint(keyRects[i], touchNormalized)) {
                [keysDown addObject:[NSNumber numberWithInt:i]];
                break;
            }
        }
    }

    if (![keysDown isEqualToSet:prevKeysDown]) {
        // Something's changed
        
        // Determine released keys
        NSMutableSet *releasedKeys = [NSMutableSet setWithSet:prevKeysDown];
        [releasedKeys minusSet:keysDown];
        for (NSNumber *n in releasedKeys) {
            int midiNote = keyValues[[n integerValue]] + 24 + ((int)self.keyboardShift * 12);
            //[self.kbComponent noteOff:midiNote];
        }
        [self setNeedsDisplay];
        
        // Determine new keys down
        NSMutableSet *newKeys = [NSMutableSet setWithSet:keysDown];
        [newKeys minusSet:prevKeysDown];
        
        for (NSNumber *n in newKeys) {
            int midiNote = keyValues[[n integerValue]] + 24 + ((int)self.keyboardShift * 12);
            //[self.kbComponent noteOn:midiNote];
        }
    }
    
    prevKeysDown = [NSSet setWithSet:keysDown];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    NSInteger totalKeys = (12 * octaves) + 1;
    
    for (int i = 0; i < totalKeys; i++) {
        
        UIImage *drawImage;
        NSNumber *keyNumber = [NSNumber numberWithInt:i];
        
        UIColor *keyColour;
        
        if (i % 12 < 7) {
            keyColour = [UIColor whiteColor];
            if ([prevKeysDown containsObject:keyNumber]) {
                drawImage = [UIImage imageNamed:@"white_key_down"];
                keyColour = [UIColor redColor];
            } else {
                drawImage = [UIImage imageNamed:@"white_key_up"];
            }
        } else {
            keyColour = [UIColor blackColor];
            if ([prevKeysDown containsObject:keyNumber]) {
                drawImage = [UIImage imageNamed:@"black_key_down"];
                keyColour = [UIColor redColor];
            } else {
                drawImage = [UIImage imageNamed:@"black_key_up"];
            }
        }
        
        [[UIColor lightGrayColor] setStroke];
        
        CGRect thisKey = keyRects[i];
        CGRect drawRect = CGRectMake(
                                     thisKey.origin.x * self.frame.size.width,
                                     thisKey.origin.y * self.frame.size.height,
                                     thisKey.size.width * self.frame.size.width,
                                     -thisKey.size.height * self.frame.size.height);
        
        if (drawImage) {
            CGContextSaveGState(ctx);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CGContextDrawImage(ctx, drawRect, [drawImage CGImage]);
            CGContextRestoreGState(ctx);
        } else {
            CGContextSaveGState(ctx);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CGContextSetFillColorWithColor(ctx, [keyColour CGColor]);
            CGContextFillRect(ctx, drawRect);
            CGContextRestoreGState(ctx);
        }
    }
}

@end
