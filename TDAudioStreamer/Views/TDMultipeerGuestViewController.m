//
//  TDMultipeerGuestViewController.m
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 11/15/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import "TDMultipeerGuestViewController.h"
#import "TDSession.h"
#import "TDAudioStreamer.h"

@interface TDMultipeerGuestViewController () <TDSessionDelegate>

@property (strong, nonatomic) TDSession *session;
@property (strong, nonatomic) TDAudioInputStreamer *inputStream;

@end

@implementation TDMultipeerGuestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.session = [[TDSession alloc] initWithPeerDisplayName:@"Guest"];
    [self.session startAdvertisingForServiceType:@"dance-party" discoveryInfo:nil];
    self.session.delegate = self;
}

- (void)session:(TDSession *)session didReceiveAudioStream:(NSInputStream *)stream
{
    if (!self.inputStream) {
        self.inputStream = [[TDAudioInputStreamer alloc] initWithInputStream:stream];
        [self.inputStream start];
    }
}

@end
