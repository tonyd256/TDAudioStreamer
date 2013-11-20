//
//  TDAudioInputStreamer.m
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 10/4/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import "TDAudioInputStreamer.h"
#import "TDAudioFileStream.h"
#import "TDAudioStream.h"
#import "TDAudioQueue.h"
#import "TDAudioQueueBuffer.h"
#import "TDAudioQueueFiller.h"
#import "TDAudioStreamerConstants.h"

@interface TDAudioInputStreamer () <TDAudioStreamDelegate, TDAudioFileStreamDelegate, TDAudioQueueDelegate>

@property (strong, nonatomic) NSThread *audioStreamerThread;
@property (assign, atomic) BOOL isPlaying;

@property (strong, nonatomic) TDAudioStream *audioStream;
@property (strong, nonatomic) TDAudioFileStream *audioFileStream;
@property (strong, nonatomic) TDAudioQueue *audioQueue;

@end

@implementation TDAudioInputStreamer

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    self.audioFileStream = [[TDAudioFileStream alloc] init];
    if (!self.audioFileStream) return nil;

    self.audioFileStream.delegate = self;

    return self;
}

- (instancetype)initWithInputStream:(NSInputStream *)inputStream
{
    self = [self init];
    if (!self) return nil;

    self.audioStream = [[TDAudioStream alloc] initWithInputStream:inputStream];
    if (!self.audioStream) return nil;

    self.audioStream.delegate = self;

    return self;
}

- (void)start
{
    if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        return [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    }

    self.audioStreamerThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [self.audioStreamerThread start];
}

- (void)run
{
    @autoreleasepool {
        [self.audioStream open];

        self.isPlaying = YES;

        while (self.isPlaying && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) ;
    }
}

#pragma mark - Properties

- (UInt32)audioStreamReadMaxLength
{
    if (!_audioStreamReadMaxLength)
        _audioStreamReadMaxLength = kTDAudioStreamReadMaxLength;

    return _audioStreamReadMaxLength;
}

- (UInt32)audioQueueBufferSize
{
    if (!_audioQueueBufferSize)
        _audioQueueBufferSize = kTDAudioQueueBufferSize;

    return _audioQueueBufferSize;
}

- (UInt32)audioQueueBufferCount
{
    if (!_audioQueueBufferCount)
        _audioQueueBufferCount = kTDAudioQueueBufferCount;

    return _audioQueueBufferCount;
}

#pragma mark - TDAudioStreamDelegate

- (void)audioStream:(TDAudioStream *)audioStream didRaiseEvent:(TDAudioStreamEvent)event
{
    switch (event) {
        case TDAudioStreamEventHasData: {
            uint8_t bytes[self.audioStreamReadMaxLength];
            UInt32 length = [audioStream readData:bytes maxLength:self.audioStreamReadMaxLength];
            [self.audioFileStream parseData:bytes length:length];
            break;
        }

        case TDAudioStreamEventEnd:
            self.isPlaying = NO;
            [self.audioQueue finish];
            break;

        case TDAudioStreamEventError:
            [[NSNotificationCenter defaultCenter] postNotificationName:TDAudioStreamDidFinishPlayingNotification object:nil];
            break;

        default:
            break;
    }
}

#pragma mark - TDAudioFileStreamDelegate

- (void)audioFileStreamDidBecomeReady:(TDAudioFileStream *)audioFileStream
{
    UInt32 bufferSize = audioFileStream.packetBufferSize ? audioFileStream.packetBufferSize : self.audioQueueBufferSize;

    self.audioQueue = [[TDAudioQueue alloc] initWithBasicDescription:audioFileStream.basicDescription bufferCount:self.audioQueueBufferCount bufferSize:bufferSize magicCookieData:audioFileStream.magicCookieData magicCookieSize:audioFileStream.magicCookieLength];

    self.audioQueue.delegate = self;
}

- (void)audioFileStream:(TDAudioFileStream *)audioFileStream didReceiveError:(OSStatus)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TDAudioStreamDidFinishPlayingNotification object:nil];
}

- (void)audioFileStream:(TDAudioFileStream *)audioFileStream didReceiveData:(const void *)data length:(UInt32)length
{
    [TDAudioQueueFiller fillAudioQueue:self.audioQueue withData:data length:length offset:0];
}

- (void)audioFileStream:(TDAudioFileStream *)audioFileStream didReceiveData:(const void *)data length:(UInt32)length packetDescription:(AudioStreamPacketDescription)packetDescription
{
    [TDAudioQueueFiller fillAudioQueue:self.audioQueue withData:data length:length packetDescription:packetDescription];
}

#pragma mark - TDAudioQueueDelegate

- (void)audioQueueDidFinishPlaying:(TDAudioQueue *)audioQueue
{
    [self performSelectorOnMainThread:@selector(notifyMainThread:) withObject:TDAudioStreamDidFinishPlayingNotification waitUntilDone:NO];
}

- (void)audioQueueDidStartPlaying:(TDAudioQueue *)audioQueue
{
    [self performSelectorOnMainThread:@selector(notifyMainThread:) withObject:TDAudioStreamDidStartPlayingNotification waitUntilDone:NO];
}

- (void)notifyMainThread:(NSString *)notificationName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

#pragma mark - Public Methods

- (void)resume
{
    [self.audioQueue play];
}

- (void)pause
{
    [self.audioQueue pause];
}

- (void)stop
{
    [self performSelector:@selector(stopThread) onThread:self.audioStreamerThread withObject:nil waitUntilDone:YES];
}

- (void)stopThread
{
    self.isPlaying = NO;
    [self.audioQueue stop];
}

@end
