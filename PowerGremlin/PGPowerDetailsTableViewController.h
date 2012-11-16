//
// Created by manuel on 11/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "PGBackgroundProcessing.h"


@interface PGPowerDetailsTableViewController : UITableViewController <UIAlertViewDelegate, PGBackgroundProcessingDelegate>

@property(nonatomic) int trialStartCapacity;
@property(nonatomic) double trialStartTime;

@end