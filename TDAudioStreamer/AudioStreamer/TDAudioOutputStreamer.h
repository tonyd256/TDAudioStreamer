//
//  TDAudioOutputStreamer.h
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 11/14/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <Foundation/Foundation.h>

@class AVURLAsset;

@interface TDAudioOutputStreamer : NSObject

- (instancetype)initWithOutputStream:(NSOutputStream *)stream;

- (void)streamAudioFromURL:(NSURL *)url;
- (void)start;
- (void)stop;

@end
