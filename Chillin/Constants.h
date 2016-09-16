//
//  Constants.h
//  Chillin
//
//  Created by Viny on 10/05/2016.
//

#import <Foundation/Foundation.h>

#define Localized(s) NSLocalizedString(s, @"")

#define CellHeight 44.0f
#define CellHeightSmall 34.0f
#define CellHeightTB 68.0f
#define CellHeightLarge 54.0f

#ifdef DEBUG
    #define GA_UID_IBD @"UA-72944921-1"
    #define GA_UID_RD  @"UA-72944921-3"
#else
    #define GA_UID_IBD @"UA-72944921-2"
    #define GA_UID_RD  @"UA-72944921-4"
#endif

@interface Constants : NSObject

@end
