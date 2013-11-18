//
//  NSMutableArray+QueueMethods.m
//  TDAudioPlayer
//
//  Created by Tony DiPasquale on 11/12/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import "NSMutableArray+QueueMethods.h"

@implementation NSMutableArray (QueueMethods)

- (void)pushObject:(id)object
{
    [self addObject:object];
}

- (id)popObject
{
    if (self.count > 0) {
        id object = self[0];
        [self removeObjectAtIndex:0];
        return object;
    }

    return nil;
}

- (id)topObject
{
    if (self.count > 0) {
        return self[0];
    }

    return nil;
}

@end
