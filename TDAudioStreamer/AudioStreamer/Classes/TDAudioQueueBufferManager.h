//
//  TDAudioQueueBufferManager.h
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 10/29/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class TDAudioQueueBuffer;

@interface TDAudioQueueBufferManager : NSObject

- (instancetype)initWithAudioQueue:(AudioQueueRef)audioQueue size:(UInt32)size count:(UInt32)count;

- (void)freeAudioQueueBuffer:(AudioQueueBufferRef)audioQueueBuffer;
- (TDAudioQueueBuffer *)nextFreeBuffer;
- (void)enqueueNextBufferOnAudioQueue:(AudioQueueRef)audioQueue;

- (BOOL)hasAvailableAudioQueueBuffer;
- (BOOL)isProcessingAudioQueueBuffer;

- (void)freeBufferMemoryFromAudioQueue:(AudioQueueRef)audioQueue;

@end
