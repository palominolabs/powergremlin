//
// Created by manuel on 11/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PGPowerLog.h"

@implementation PGPowerLog {
    NSString *_logFilePath;
    NSTimer *_timer;
}
- (id)initWithLogFileName:(NSString *)logFileName {
    self = [super init];
    if (self) {
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = documentPaths[0];
        _logFilePath = [[documentsDir stringByAppendingPathComponent:logFileName] stringByAppendingPathExtension:@"csv"];

        if (![[NSFileManager defaultManager] fileExistsAtPath:_logFilePath]) {
            NSArray *headers = @[
            @"Raw Battery Voltage (mV)",
            @"Battery Level (%)",
            @"Current Battery Capacity (mAh)",
            @"Battery Design Capacity (mAh)",
            @"Battery Max Capacity (mAh)",
            @"Charger Current (mA)",
            @"Rough CPU Die Temperature (deg C)"
            ];
            NSData *headersData = [[NSString stringWithFormat:@"%@\n", [headers componentsJoinedByString:@","]] dataUsingEncoding:NSUTF8StringEncoding];
            [headersData writeToFile:_logFilePath atomically:YES];
        }

        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(appendLogEntry) userInfo:nil repeats:YES];
    }

    return self;
}

- (void)appendLogEntry {
    NSArray *logEntryComponents = @[
    [NSDate new],
    [NSNumber numberWithInt:PG_getRawBatteryVoltage()],
    [NSNumber numberWithInt:PG_getBatteryLevel()],
    [NSNumber numberWithInt:PG_getBatteryCurrentCapacity()],
    [NSNumber numberWithInt:PG_getBatteryDesignCapacity()],
    [NSNumber numberWithInt:PG_getBatteryMaxCapacity()],
    [NSNumber numberWithInt:PG_getChargerCurrent()],
    [NSNumber numberWithFloat:PG_getTemperature()]
    ];

    NSString *logEntry = [logEntryComponents componentsJoinedByString:@","];


    NSLog(@"%@", logEntry);

    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:_logFilePath];
    [handle seekToEndOfFile];
    NSString *logEntryWithNewLine = [NSString stringWithFormat:@"%@\n", logEntry];
    [handle writeData:[logEntryWithNewLine dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}

- (void)dealloc {
    [_timer invalidate];
}


@end