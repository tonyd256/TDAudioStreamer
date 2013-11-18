//
//  TDAudioQueueFiller.m
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 10/31/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import "TDAudioQueueFiller.h"
#import "TDAudioQueueBuffer.h"
#import "TDAudioQueue.h"

@implementation TDAudioQueueFiller

+ (void)fillAudioQueue:(TDAudioQueue *)audioQueue withData:(const void *)data length:(UInt32)length offset:(UInt32)offset
{
    TDAudioQueueBuffer *audioQueueBuffer = [audioQueue nextFreeBuffer];

    NSInteger leftovers = [audioQueueBuffer fillWithData:data length:length offset:offset];

    if (leftovers == 0) return;

    [audioQueue enqueue];

    if (leftovers > 0)
        [self fillAudioQueue:audioQueue withData:data length:length offset:(length - (UInt32)leftovers)];
}

+ (void)fillAudioQueue:(TDAudioQueue *)audioQueue withData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription
{
    TDAudioQueueBuffer *audioQueueBuffer = [audioQueue nextFreeBuffer];

    BOOL hasMoreRoomForPackets = [audioQueueBuffer fillWithData:data length:length packetDescription:packetDescription];

    if (!hasMoreRoomForPackets) {
        [audioQueue enqueue];
        [self fillAudioQueue:audioQueue withData:data length:length packetDescription:packetDescription];
    }
}

@end
