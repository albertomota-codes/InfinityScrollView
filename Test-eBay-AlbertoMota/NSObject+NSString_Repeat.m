//
//  NSObject+NSString_Repeat.m
//  Test-eBay-AlbertoMota
//
//  Created by Al on 4/26/18.
//  Copyright © 2018 Alberto Mota. All rights reserved.
//

#import "NSObject+NSString_Repeat.h"



@implementation NSString (NSString_Repeat)

- (NSString *)repeatTimes:(NSUInteger)times {
    return [@"" stringByPaddingToLength:times * [self length] withString:self startingAtIndex:0];
}

@end

