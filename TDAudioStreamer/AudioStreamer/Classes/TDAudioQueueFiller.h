//
//  TDAudioQueueFiller.h
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 10/31/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class TDAudioQueue;

@interface TDAudioQueueFiller : NSObject

+ (void)fillAudioQueue:(TDAudioQueue *)audioQueue withData:(const void *)data length:(UInt32)length offset:(UInt32)offset;
+ (void)fillAudioQueue:(TDAudioQueue *)audioQueue withData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription;

@end
