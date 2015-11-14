//
//  UIImage+Resize.m
//  ColourCalm
//
//  Created by Chris on 10/07/2015.
//  Copyright (c) 2015 Future plc. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

// Resizes an image whilst retaining aspect ratio and centering
-(instancetype)resizeTo:(CGSize)newSize withInterpolationQuality:(CGInterpolationQuality)interpolationQuality {
    
    CGFloat aspectRatio = self.size.width / self.size.height;
    
    CGRect drawRect;
    
    CGFloat scaleHeight = (self.size.height / newSize.height);
    if (self.size.width / scaleHeight <= newSize.width) {
         // Fit height
        CGFloat drawHeight = newSize.height;
        CGFloat drawWidth = newSize.height * aspectRatio;
        CGFloat hOffset = (newSize.width - drawWidth) / 2.0;
        drawRect = CGRectMake(hOffset, 0, drawWidth, drawHeight);
    } else {
        // Fit width
        CGFloat drawWidth = newSize.width;
        CGFloat drawHeight = newSize.width / aspectRatio;
        CGFloat vOffset = (newSize.height - drawHeight) / 2.0;
        drawRect = CGRectMake(0, vOffset, drawWidth, drawHeight);
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), interpolationQuality);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(UIGraphicsGetCurrentContext(), flipVertical);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), drawRect, [self CGImage]);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if (newImage) {
        return newImage;
    } else {
        return [self copy];
    }
}

-(instancetype)resizeTo:(CGSize)newSize {
    return [self resizeTo:newSize withInterpolationQuality:kCGInterpolationHigh];
}

- (UIImage *)imageScaledToSize:(CGSize)size
{
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //draw
    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

- (UIImage *)imageScaledToFitSize:(CGSize)size
{
    //calculate rect
    CGFloat aspect = self.size.width / self.size.height;
    if (size.width / aspect <= size.height)
    {
        return [self imageScaledToSize:CGSizeMake(size.width, size.width / aspect)];
    }
    else
    {
        return [self imageScaledToSize:CGSizeMake(size.height * aspect, size.height)];
    }
}

@end
