//
//  TDAudioQueueBuffer.h
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 10/11/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface TDAudioQueueBuffer : NSObject

- (instancetype)initWithAudioQueue:(AudioQueueRef)audioQueue size:(UInt32)size;

- (NSInteger)fillWithData:(const void *)data length:(UInt32)length offset:(UInt32)offset;
- (BOOL)fillWithData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription;

- (void)enqueueWithAudioQueue:(AudioQueueRef)auidoQueue;
- (void)reset;

- (BOOL)isEqual:(AudioQueueBufferRef)audioQueueBuffer;

- (void)freeFromAudioQueue:(AudioQueueRef)audioQueue;

@end
