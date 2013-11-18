//
//  NSMutableArray+QueueMethods.h
//  TDAudioPlayer
//
//  Created by Tony DiPasquale on 11/12/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueMethods)

- (void)pushObject:(id)object;
- (id)popObject;
- (id)topObject;

@end
