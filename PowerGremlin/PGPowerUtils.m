//
// Created by manuel on 11/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


void PG_loadOSDBattery(void) {
    NSBundle *b = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/GAIA.framework"];
    if (![b load]) {
        @throw [NSError errorWithDomain:@"com.palominolabs.UnableToLoadGAIA" code:0 userInfo:nil];
    }
}

id PG_getSKController() {
    Class SKHIDController = NSClassFromString(@"SKHIDController");
    return [SKHIDController performSelector:@selector(sharedInstance)];
}

float PG_getTemperature() {
    return [[PG_getSKController() valueForKey:@"temperature"] floatValue];
}

id PG_getOSDBattery(void) {
    Class OSDBattery = NSClassFromString(@"OSDBattery");
    return [OSDBattery performSelector:@selector(sharedInstance)];
}

int PG_getRawBatteryVoltage(void) {
    return [[PG_getOSDBattery() valueForKey:@"getRawBatteryVoltage"] intValue];
}

int PG_getBatteryLevel(void) {
    return [[PG_getOSDBattery() valueForKey:@"getBatteryLevel"] intValue];
}

int PG_getBatteryCurrentCapacity(void) {
    return [[PG_getOSDBattery() valueForKey:@"getBatteryCurrentCapacity"] intValue];
}

int PG_getBatteryDesignCapacity(void) {
    return [[PG_getOSDBattery() valueForKey:@"getBatteryDesignCapacity"] intValue];
}

int PG_getBatteryMaxCapacity(void) {
    return [[PG_getOSDBattery() valueForKey:@"getBatteryMaxCapacity"] intValue];
}

int PG_getChargerCurrent(void) {
    return [[PG_getOSDBattery() valueForKey:@"getChargerCurrent"] intValue];
}