//
//  Screen.m
//  Chillin
//
//  Created by Viny on 10/05/2016.
//

#import "Screen.h"

@implementation Screen

+ (float)width {
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    return screenSize.width;
}

+ (float)height {
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    return screenSize.height;
}

@end
