//
//  TDSession.h
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 11/15/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <Foundation/Foundation.h>

@class TDSession, MCPeerID, MCBrowserViewController;
@protocol TDSessionDelegate <NSObject>

- (void)session:(TDSession *)session didReceiveAudioStream:(NSInputStream *)stream;
- (void)session:(TDSession *)session didReceiveData:(NSData *)data;

@end

@interface TDSession : NSObject

@property (weak, nonatomic) id<TDSessionDelegate> delegate;

- (instancetype)initWithPeerDisplayName:(NSString *)name;

- (void)startAdvertisingForServiceType:(NSString *)type discoveryInfo:(NSDictionary *)info;
- (void)stopAdvertising;
- (MCBrowserViewController *)browserViewControllerForSeriviceType:(NSString *)type;

- (NSArray *)connectedPeers;
- (NSOutputStream *)outputStreamForPeer:(MCPeerID *)peer;

- (void)sendData:(NSData *)data;

@end
