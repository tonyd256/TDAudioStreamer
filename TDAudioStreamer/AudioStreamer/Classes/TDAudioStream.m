//
//  TDAudioStream.m
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 10/4/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import "TDAudioStream.h"

@interface TDAudioStream () <NSStreamDelegate>

@property (strong, nonatomic) NSStream *stream;

@end

@implementation TDAudioStream

- (instancetype)initWithInputStream:(NSInputStream *)inputStream
{
    self = [super init];
    if (!self) return nil;

    self.stream = inputStream;

    return self;
}

- (instancetype)initWithOutputStream:(NSOutputStream *)outputStream
{
    self = [super init];
    if (!self) return nil;

    self.stream = outputStream;

    return self;
}

- (void)open
{
    self.stream.delegate = self;
    [self.stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    return [self.stream open];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            [self.delegate audioStream:self didRaiseEvent:TDAudioStreamEventHasData];
            break;

        case NSStreamEventHasSpaceAvailable:
            [self.delegate audioStream:self didRaiseEvent:TDAudioStreamEventWantsData];
            break;

        case NSStreamEventEndEncountered:
            [self.delegate audioStream:self didRaiseEvent:TDAudioStreamEventEnd];
            break;

        case NSStreamEventErrorOccurred:
            [self.delegate audioStream:self didRaiseEvent:TDAudioStreamEventError];
            break;

        default:
            break;
    }
}

- (UInt32)readData:(uint8_t *)data maxLength:(UInt32)maxLength
{
    return (UInt32)[(NSInputStream *)self.stream read:data maxLength:maxLength];
}

- (UInt32)writeData:(uint8_t *)data maxLength:(UInt32)maxLength
{
    return (UInt32)[(NSOutputStream *)self.stream write:data maxLength:maxLength];
}

- (void)close
{
    [self.stream close];
    self.stream.delegate = nil;
    [self.stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)dealloc
{
    if (self.stream)
        [self close];
}

@end
