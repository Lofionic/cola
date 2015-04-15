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
    
    CGSize imageSize = self.frame.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    [self.layer renderInContext:context];
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
