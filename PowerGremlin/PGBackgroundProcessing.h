//
// Created by manuel on 11/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@protocol PGBackgroundProcessingDelegate

- (void)process;

@end


@interface PGBackgroundProcessing : NSObject

- (id)initWithDelegate:(id <PGBackgroundProcessingDelegate>)delegate;


- (void)start;


- (void)process;
@end