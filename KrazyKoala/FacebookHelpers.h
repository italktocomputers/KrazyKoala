//
//  FacebookHelpers.h
//  KrazyKoala
//
//  Created by Andrew Schools on 2/21/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

#ifndef KrazyKoala_FacebookHelpers_h
#define KrazyKoala_FacebookHelpers_h

@interface FacebookHelpers : NSObject

-(void) sendPostWithScore:(int32_t) score clearStreak: (int32_t) clearStreak level: (int32_t) level type:(NSString*) type difficulty:(NSString*) difficulty;
-(void) shareLink;

@end

#endif
