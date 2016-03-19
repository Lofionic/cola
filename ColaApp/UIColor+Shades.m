//
//  UIColor+Shades.m
//  ColaApp
//
//  Created by Chris on 25/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "UIColor+Shades.h"

@implementation UIColor (Shades)

-(UIColor*)lighterShade {
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    return nil;
}

-(UIColor*)midShade {
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 0.9, 1.0)
                               alpha:a];
    return nil;
}

-(UIColor*)darkerShade {
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.8
                               alpha:a];
    return nil;
}

@end
