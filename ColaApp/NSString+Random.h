//
//  NSString+Random.h
//  ColaApp
//
//  Created by Chris on 06/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Random)

+(NSString *)randomAlphanumericStringWithLength:(NSInteger)length;
+(NSString *)randomName;

@end