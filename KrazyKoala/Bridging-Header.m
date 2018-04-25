//
//  Bridging-Header.m
//  KrazyKoala
//
//  Created by Andrew Schools on 4/19/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *compileDate() {
    return [NSString stringWithUTF8String:__DATE__];
}

NSString *compileTime() {
    return [NSString stringWithUTF8String:__TIME__];
}
