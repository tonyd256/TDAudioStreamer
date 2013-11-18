//
//  TDAudioQueueBufferManager.m
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 10/29/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import "TDAudioQueueBufferManager.h"
#import "TDAudioQueueBuffer.h"
#import "NSMutableArray+QueueMethods.h"

@interface TDAudioQueueBufferManager ()

@property (assign, nonatomic) UInt32 bufferCount;
@property (assign, nonatomic) UInt32 bufferSize;
@property (strong, nonatomic) NSArray *audioQueueBuffers;
@property (strong, atomic) NSMutableArray *freeBuffers;

@end

@implementation TDAudioQueueBufferManager

- (instancetype)initWithAudioQueue:(AudioQueueRef)audioQueue size:(UInt32)size count:(UInt32)count
{
    self = [super init];
    if (!self) return nil;

    self.bufferCount = count;
    self.bufferSize = size;

    self.freeBuffers = [NSMutableArray arrayWithCapacity:self.bufferCount];
    NSMutableArray *audioqueuebuffers = [NSMutableArray arrayWithCapacity:self.bufferCount];

    for (NSUInteger i = 0; i < self.bufferCount; i++) {
        TDAudioQueueBuffer *buffer = [[TDAudioQueueBuffer alloc] initWithAudioQueue:audioQueue size:self.bufferSize];

        if (!buffer) {
            i--;
            continue;
        }

        audioqueuebuffers[i] = buffer;
        [self.freeBuffers pushObject:@(i)];
    }

    self.audioQueueBuffers = [audioqueuebuffers copy];

    return self;
}

#pragma mark - Public Methods

- (void)freeAudioQueueBuffer:(AudioQueueBufferRef)audioQueueBuffer
{
    for (NSUInteger i = 0; i < self.bufferCount; i++) {
        if ([(TDAudioQueueBuffer *)self.audioQueueBuffers[i] isEqual:audioQueueBuffer]) {
            [(TDAudioQueueBuffer *)self.audioQueueBuffers[i] reset];

            @synchronized(self) {
                [self.freeBuffers pushObject:@(i)];
            }
            break;
        }
    }

#if DEBUG
    if (self.freeBuffers.count > self.bufferCount >> 1) {
        NSLog(@"Free Buffers: %lu", (unsigned long)self.freeBuffers.count);
    }
#endif
}

- (TDAudioQueueBuffer *)nextFreeBuffer
{
    if (![self hasAvailableAudioQueueBuffer]) return nil;
    @synchronized(self) {
        return self.audioQueueBuffers[[[self.freeBuffers topObject] integerValue]];
    }
}

- (void)enqueueNextBufferOnAudioQueue:(AudioQueueRef)audioQueue
{
    @synchronized(self) {
        NSInteger nextBufferIndex = [[self.freeBuffers popObject] integerValue];
        TDAudioQueueBuffer *nextBuffer = self.audioQueueBuffers[nextBufferIndex];
        [nextBuffer enqueueWithAudioQueue:audioQueue];
    }
}

- (BOOL)hasAvailableAudioQueueBuffer
{
    @synchronized(self) {
        return self.freeBuffers.count > 0;
    }
}

- (BOOL)isProcessingAudioQueueBuffer
{
    @synchronized(self) {
        return self.freeBuffers.count != self.bufferCount;
    }
}

#pragma mark - Cleanup

- (void)freeBufferMemoryFromAudioQueue:(AudioQueueRef)audioQueue
{
    for (NSUInteger i = 0; i < self.audioQueueBuffers.count; i++) {
        [(TDAudioQueueBuffer *)self.audioQueueBuffers[i] freeFromAudioQueue:audioQueue];
    }
}

@end
