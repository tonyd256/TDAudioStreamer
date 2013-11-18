//
//  TDAudioQueueController.h
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 10/29/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface TDAudioQueueController : NSObject

+ (OSStatus)playAudioQueue:(AudioQueueRef)audioQueue;
+ (OSStatus)pauseAudioQueue:(AudioQueueRef)audioQueue;
+ (OSStatus)stopAudioQueue:(AudioQueueRef)audioQueue;
+ (OSStatus)finishAudioQueue:(AudioQueueRef)audioQueue;

@end
