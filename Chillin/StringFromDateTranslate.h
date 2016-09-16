//
//  stringFromDateTranslate.h
//  Chillin
//
//  Created by Viny on 10/05/2016.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface StringFromDateTranslate : NSObject

+ (NSString *)translateDate:(NSDate *)date;
+ (NSString *)translateTime:(NSDate *)date;

@end
