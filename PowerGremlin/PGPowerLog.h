//
// Created by manuel on 11/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface PGPowerLog : NSObject
- (id)initWithLogFileName:(NSString *)logFileName;

- (void)appendLogEntry;


@end