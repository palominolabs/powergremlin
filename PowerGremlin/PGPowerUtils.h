//
// Created by manuel on 11/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR
#error PowerGremlin only works on physical iOS devices
#endif

void PG_loadOSDBattery(void);

int PG_getRawBatteryVoltage(void);

int PG_getBatteryLevel(void);

int PG_getBatteryCurrentCapacity(void);

int PG_getBatteryDesignCapacity(void);

int PG_getBatteryMaxCapacity(void);

int PG_getChargerCurrent(void);

float PG_getTemperature(void);