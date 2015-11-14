//
//  UIImage+Resize.h
//  ColourCalm
//
//  Created by Chris on 10/07/2015.
//  Copyright (c) 2015 Future plc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

-(instancetype)resizeTo:(CGSize)newSize;
-(instancetype)resizeTo:(CGSize)newSize withInterpolationQuality:(CGInterpolationQuality)interpolationQuality;

- (UIImage *)imageScaledToSize:(CGSize)size;
- (UIImage *)imageScaledToFitSize:(CGSize)size;

@end
