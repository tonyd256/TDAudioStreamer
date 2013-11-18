//
//  TDAudioFileStream.m
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 10/4/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import "TDAudioFileStream.h"

@interface TDAudioFileStream ()

@property (assign, nonatomic) AudioFileStreamID audioFileStreamID;

- (void)didChangeProperty:(AudioFileStreamPropertyID)propertyID flags:(UInt32 *)flags;
- (void)didReceivePackets:(const void *)packets packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions numberOfPackets:(UInt32)numberOfPackets numberOfBytes:(UInt32)numberOfBytes;

@end

void TDAudioFileStreamPropertyListener(void *inClientData, AudioFileStreamID inAudioFileStreamID, AudioFileStreamPropertyID inPropertyID, UInt32 *ioFlags)
{
    TDAudioFileStream *audioFileStream = (__bridge TDAudioFileStream *)inClientData;
    [audioFileStream didChangeProperty:inPropertyID flags:ioFlags];
}

void TDAudioFileStreamPacketsListener(void *inClientData, UInt32 inNumberBytes, UInt32 inNumberPackets, const void *inInputData, AudioStreamPacketDescription *inPacketDescriptions)
{
    TDAudioFileStream *audioFileStream = (__bridge TDAudioFileStream *)inClientData;
    [audioFileStream didReceivePackets:inInputData packetDescriptions:inPacketDescriptions numberOfPackets:inNumberPackets numberOfBytes:inNumberBytes];
}

@implementation TDAudioFileStream

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    OSStatus err = AudioFileStreamOpen((__bridge void *)self, TDAudioFileStreamPropertyListener, TDAudioFileStreamPacketsListener, 0, &_audioFileStreamID);

    if (err) return nil;

    self.discontinuous = YES;

    return self;
}

- (void)didChangeProperty:(AudioFileStreamPropertyID)propertyID flags:(UInt32 *)flags
{
    if (propertyID == kAudioFileStreamProperty_ReadyToProducePackets) {
        UInt32 basicDescriptionSize = sizeof(self.basicDescription);
        OSStatus err = AudioFileStreamGetProperty(self.audioFileStreamID, kAudioFileStreamProperty_DataFormat, &basicDescriptionSize, &_basicDescription);

        if (err) return [self.delegate audioFileStream:self didReceiveError:err];

        UInt32 byteCountSize;
        AudioFileStreamGetProperty(self.audioFileStreamID, kAudioFileStreamProperty_AudioDataByteCount, &byteCountSize, &_totalByteCount);

        UInt32 sizeOfUInt32 = sizeof(UInt32);
        err = AudioFileStreamGetProperty(self.audioFileStreamID, kAudioFileStreamProperty_PacketSizeUpperBound, &sizeOfUInt32, &_packetBufferSize);

        if (err || !self.packetBufferSize) {
            AudioFileStreamGetProperty(self.audioFileStreamID, kAudioFileStreamProperty_MaximumPacketSize, &sizeOfUInt32, &_packetBufferSize);
        }

        Boolean writeable;
        err = AudioFileStreamGetPropertyInfo(self.audioFileStreamID, kAudioFileStreamProperty_MagicCookieData, &_magicCookieLength, &writeable);

        if (!err) {
            self.magicCookieData = calloc(1, self.magicCookieLength);
            AudioFileStreamGetProperty(self.audioFileStreamID, kAudioFileStreamProperty_MagicCookieData, &_magicCookieLength, self.magicCookieData);
        }

        [self.delegate audioFileStreamDidBecomeReady:self];
    }
}

- (void)didReceivePackets:(const void *)packets packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions numberOfPackets:(UInt32)numberOfPackets numberOfBytes:(UInt32)numberOfBytes
{
    if (packetDescriptions) {
        for (NSUInteger i = 0; i < numberOfPackets; i++) {
            SInt64 packetOffset = packetDescriptions[i].mStartOffset;
            UInt32 packetSize = packetDescriptions[i].mDataByteSize;

            [self.delegate audioFileStream:self didReceiveData:(const void *)(packets + packetOffset) length:packetSize packetDescription:(AudioStreamPacketDescription)packetDescriptions[i]];
        }
    } else {
        [self.delegate audioFileStream:self didReceiveData:(const void *)packets length:numberOfBytes];
    }
}

- (void)parseData:(const void *)data length:(UInt32)length
{
    OSStatus err;

    if (self.discontinuous) {
        err = AudioFileStreamParseBytes(self.audioFileStreamID, length, data, kAudioFileStreamParseFlag_Discontinuity);
        self.discontinuous = NO;
    } else {
        err = AudioFileStreamParseBytes(self.audioFileStreamID, length, data, 0);
    }

    if (err) [self.delegate audioFileStream:self didReceiveError:err];
}

- (void)dealloc
{
    AudioFileStreamClose(self.audioFileStreamID);
    free(_magicCookieData);
}

@end
