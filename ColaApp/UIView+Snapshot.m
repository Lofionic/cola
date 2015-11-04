//
//  UIView+Snapshot.m
//  ColaApp
//
//  Created by Chris on 14/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "UIView+Snapshot.h"

@implementation UIView (Snapshot)

-(UIImage*)snapshot {
    
    BOOL prevClipsToBounds = self.clipsToBounds;
    [self setClipsToBounds:NO];
    
    CGSize imageSize = self.bounds.size;
    if ([self respondsToSelector:@selector(contentSize)]) {
        imageSize = [(id)self contentSize];
    }
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    
    [self.layer renderInContext:context];
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setClipsToBounds:prevClipsToBounds];
    
    return image;
}

@end
