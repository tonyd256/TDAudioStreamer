//
//  TDAudioFileStream.h
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 10/4/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class TDAudioFileStream;
@protocol TDAudioFileStreamDelegate <NSObject>

- (void)audioFileStream:(TDAudioFileStream *)audioFileStream didReceiveError:(OSStatus)error;

@required
- (void)audioFileStreamDidBecomeReady:(TDAudioFileStream *)audioFileStream;
- (void)audioFileStream:(TDAudioFileStream *)audioFileStream didReceiveData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription;
- (void)audioFileStream:(TDAudioFileStream *)audioFileStream didReceiveData:(const void *)data length:(UInt32)length;

@end

@interface TDAudioFileStream : NSObject

@property (assign, nonatomic) AudioStreamBasicDescription basicDescription;
@property (assign, nonatomic) UInt64 totalByteCount;
@property (assign, nonatomic) UInt32 packetBufferSize;
@property (assign, nonatomic) void *magicCookieData;
@property (assign, nonatomic) UInt32 magicCookieLength;
@property (assign, nonatomic) BOOL discontinuous;
@property (assign, nonatomic) id<TDAudioFileStreamDelegate> delegate;

- (instancetype)init;

- (void)parseData:(const void *)data length:(UInt32)length;

@end
