//
// Created by manuel on 11/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PGBackgroundProcessing.h"

OSStatus Render(
        void *inRefCon,
        AudioUnitRenderActionFlags *ioActionFlags,
        const AudioTimeStamp *inTimeStamp,
        UInt32 inBusNumber,
        UInt32 inNumberFrames,
        AudioBufferList *ioData) {
    PGBackgroundProcessing *backgroundProcessing = (__bridge PGBackgroundProcessing *) inRefCon;
    [backgroundProcessing process];

    return noErr;
}


@implementation PGBackgroundProcessing {
    id <PGBackgroundProcessingDelegate> _delegate;
    AudioComponentInstance _audioUnit;
}

- (void)process {
    [_delegate process];
}

- (id)initWithDelegate:(id <PGBackgroundProcessingDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;

        _audioUnit = [self createAudioUnit];


        OSStatus err = AudioSessionInitialize(NULL, NULL, NULL, NULL);
        NSAssert(err == kAudioSessionNoError, @"Unable to initialize session");

        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);

        AudioSessionSetActive(true);
    }

    return self;
}

- (AudioComponentInstance)createAudioUnit {
    AudioComponentInstance audioUnit;

    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;

    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);

    OSStatus err = AudioComponentInstanceNew(defaultOutput, &audioUnit);
    NSAssert(err == noErr, @"Unable to create audio unit");

    // Set rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = Render;
    input.inputProcRefCon = (__bridge void *) self;
    err = AudioUnitSetProperty(audioUnit,
            kAudioUnitProperty_SetRenderCallback,
            kAudioUnitScope_Input,
            0,
            &input,
            sizeof(input));
    NSAssert(err == noErr, @"Unable to set rendering function");

    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = 8000;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = 1;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    err = AudioUnitSetProperty(audioUnit,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Input,
            0,
            &streamFormat,
            sizeof(AudioStreamBasicDescription));
    NSAssert(err == noErr, @"Unable to set stream properties");

    return audioUnit;
}

- (void)start {
    OSStatus err = AudioUnitInitialize(_audioUnit);
    NSAssert(err == noErr, @"Unable to initialize start audio unit");

    err = AudioOutputUnitStart(_audioUnit);
    NSAssert(err == noErr, @"Unable to start audio unit");
}


@end