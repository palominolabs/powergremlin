//
// Created by manuel on 11/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PGPowerDetailsTableViewController.h"
#import "PGPowerLog.h"
#import "PGBackgroundProcessing.h"

NSString *const kCurrentLogSettingsKey = @"current_log_file";

static int const kLogUpdateIntervalSeconds = 5;

@implementation PGPowerDetailsTableViewController {
    NSTimer *_refreshTimer;
    PGPowerLog *_powerLog;
    PGBackgroundProcessing *_backgroundProcessing;
    CFTimeInterval _lastLogEntryTime;
}

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        NSString *currentLog = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentLogSettingsKey];
        if (currentLog) {
            _powerLog = [[PGPowerLog alloc] initWithLogFileName:currentLog];
            _backgroundProcessing = [[PGBackgroundProcessing alloc] initWithDelegate:self];
            [_backgroundProcessing start];
            _lastLogEntryTime = CACurrentMediaTime();
        }
    }

    return self;
}

- (void)dealloc {
    [_refreshTimer invalidate];
}

- (void)startNewLog {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log File Name" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];

}

#pragma mark PGBackgroundProcessing

- (void)process {
    if (CACurrentMediaTime() - _lastLogEntryTime < kLogUpdateIntervalSeconds) {
        return;
    }

    [_powerLog appendLogEntry];
    _lastLogEntryTime = CACurrentMediaTime();
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *logFileName = [alertView textFieldAtIndex:0].text;
    [[NSUserDefaults standardUserDefaults] setObject:logFileName forKey:kCurrentLogSettingsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _powerLog = [[PGPowerLog alloc] initWithLogFileName:logFileName];

    self.trialStartCapacity = PG_getBatteryCurrentCapacity();
    self.trialStartTime = CACurrentMediaTime();
    [self.tableView reloadData];
}


#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!self.trialStartCapacity) {
        [self startNewLog];
    } else {
        [self.tableView reloadData];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [_refreshTimer invalidate];
}



#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 7;
        case 1:
            return 3;
        case 2:
            return 2;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int chargerCurrentMilliamps = PG_getChargerCurrent();


    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];

    if (indexPath.section == 0) {

        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Raw Voltage (mV)";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", PG_getRawBatteryVoltage()];
                break;
            case 1:
                cell.textLabel.text = @"Level";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", PG_getBatteryLevel()];
                break;
            case 2:
                cell.textLabel.text = @"Current Capacity (mAh)";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", PG_getBatteryCurrentCapacity()];
                break;
            case 3:
                cell.textLabel.text = @"Design Capacity (mAh)";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", PG_getBatteryDesignCapacity()];
                break;
            case 4:
                cell.textLabel.text = @"Max Capacity (mAh)";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", PG_getBatteryMaxCapacity()];
                break;
            case 5:
                cell.textLabel.text = @"Charger Current (mA)";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", chargerCurrentMilliamps];
                break;
            case 6:
                cell.textLabel.text = @"Temperature (C)";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.00f", PG_getTemperature()];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        double elapsedMinutes = [self elapsedSeconds] / 60;
        double elapsedHours = elapsedMinutes / 60;
        int usedMilliampHours = (int) (self.trialStartCapacity - PG_getBatteryCurrentCapacity());
        double currentDrawMilliamps = usedMilliampHours / elapsedHours;

        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Current Draw (mA)";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.00f", currentDrawMilliamps];
                break;
            case 1:
                cell.textLabel.text = @"Used capacity (mAh)";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", usedMilliampHours];
                break;
            case 2:
                cell.textLabel.text = @"Elapsed Minutes";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.02f", elapsedMinutes];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Start New Log";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 1:
                cell.textLabel.text = @"Current Log";
                cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentLogSettingsKey];
                break;
            default:
                break;
        }
    }

    return cell;
}

- (double)elapsedSeconds {
    return CACurrentMediaTime() - self.trialStartTime;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self startNewLog];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 2 && indexPath.row == 0;
}


#pragma mark properties

#define PG_TRIAL_START_CAPACITY @"trialStartCapacity"
#define PG_TRIAL_START_TIME @"trialStartTime"

- (int)trialStartCapacity {
    return [[NSUserDefaults standardUserDefaults] integerForKey:PG_TRIAL_START_CAPACITY];
}

- (void)setTrialStartCapacity:(int)trialStartCapacity {
    [[NSUserDefaults standardUserDefaults] setInteger:trialStartCapacity forKey:PG_TRIAL_START_CAPACITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (double)trialStartTime {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:PG_TRIAL_START_TIME];
}

- (void)setTrialStartTime:(double)trialStartTime {
    [[NSUserDefaults standardUserDefaults] setDouble:trialStartTime forKey:PG_TRIAL_START_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end