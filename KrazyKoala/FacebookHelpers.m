//
//  FacebookHelpers.m
//  KrazyKoala
//
//  Created by Andrew Schools on 2/21/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookHelpers.h"

@implementation FacebookHelpers

-(void) sendPostWithScore:(int32_t) score clearStreak:(int32_t) clearStreak level:(int32_t) level type:(NSString*) type difficulty:(NSString*) difficulty{
    NSString* fbaction = @"";
    NSString* fbactiontype = @"";
    NSString* fbtitle = @"";
    NSString* fbmessage = @"";
    
    if ([type isEqual: @"score"]) {
        fbaction = @"new_high_score";
        fbactiontype = @"aschools:get";
        fbtitle = @"New High Score!";
        fbmessage = [NSString stringWithFormat:@"%i in %@ mode.", score, difficulty];
    } else if ([type isEqual: @"level"]) {
        fbaction = @"new_high_level";
        fbactiontype = @"aschools:get";
        fbtitle = @"New High Level!";
        fbmessage = [NSString stringWithFormat:@"Level %i in %@ mode.", level, difficulty];
    } else if ([type isEqual: @"game"]) {
        fbaction = @"game";
        fbactiontype = @"aschools:completed";
        fbtitle = @"Completed Game!";
        fbmessage = [NSString stringWithFormat:@"%i/%i in %@ mode.", score, clearStreak, difficulty];
    } else {
        fbaction = @"new_clear_streak";
        fbactiontype = @"aschools:get";
        fbtitle = @"New Clear Streak!";
        fbmessage = [NSString stringWithFormat:@"%i in %@ mode.", clearStreak, difficulty];
    }
    
    id<FBGraphObject> object =
    [FBGraphObject openGraphObjectForPostWithType:fbaction
                                            title:fbtitle
                                            image:@"https://s3.amazonaws.com/krazykoala/KrazyKoala180x180_2.png"
                                              url:@"https://www.facebook.com/pages/Krazy-Koala/1553928058198425"
                                      description:fbmessage];
    
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    [action setObject:object forKey:fbaction];
    
    FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
    params.action = action;
    params.actionType = fbactiontype;
    
    // If the Facebook app is installed and we can present the share dialog
    if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
        [FBDialogs presentShareDialogWithOpenGraphAction:action
                                              actionType:fbactiontype
                                     previewPropertyName:fbaction
                                                 handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                     if(error) {
                                                         NSLog(@"Error publishing story: %@", error.description);
                                                     }
                                                 }];
        
    // If the Facebook app is NOT installed fallback to web based dialog
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       fbtitle, @"name",
                                       @"Play Krazy Koala!", @"caption",
                                       fbmessage, @"description",
                                       @"https://www.facebook.com/pages/Krazy-Koala/1553928058198425", @"link",
                                       @"https://s3.amazonaws.com/krazykoala/KrazyKoala180x180_2.png", @"picture",
                                       nil];
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
           parameters:params
              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                  if (error) {
                      NSLog(@"Error publishing story: %@", error.description);
                  }
              }];
    }
}

-(void) shareLink {
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://www.facebook.com/pages/Krazy-Koala/1553928058198425"];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              NSLog(@"Error publishing story: %@", error.description);
                                          }
                                      }];
    } else {
        // If the Facebook app is NOT installed fallback to web based dialog
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Krazy Koala", @"name",
                                       @"Give Krazy Koala a try!", @"caption",
                                       @"Krazy Koala is a FREE iOS8 game.  Checkout our Facebook page for more information.", @"description",
                                       @"https://www.facebook.com/pages/Krazy-Koala/1553928058198425", @"link",
                                       @"https://s3.amazonaws.com/krazykoala/KrazyKoala180x180_2.png", @"picture",
                                       nil];
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      }
                                                  }];
    }
}
@end