//
//  ABUzh.m
//  Uzh
//
//  Created by Антон Буков on 10.03.13.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import "ABUzh.h"

@interface ABUzh ()
@property (nonatomic) CGSize virtualSize;
@property (nonatomic) CGSize currentDirection;
@property (nonatomic) NSMutableArray * points;
@property (nonatomic) NSMutableArray * directions;
@end

@implementation ABUzh

- (NSArray *)allPoints
{
    return self.points;
}

- (CGPoint)head
{
    return [[self.points lastObject] CGPointValue];
}

- (CGPoint)tail
{
    return [[self.points objectAtIndex:0] CGPointValue];
}

- (CGSize)headDirection
{
    return [[self.directions lastObject] CGSizeValue];
}

- (CGSize)tailDirection
{
    return [[self.directions objectAtIndex:0] CGSizeValue];
}

- (CGPoint)movePoint:(CGPoint)point bySize:(CGSize)size times:(int)times
{
    return CGPointMake((int)(point.x + times*size.width + self.virtualSize.width)
                       % (int)(self.virtualSize.width),
                       (int)(point.y + times*size.height + self.virtualSize.height)
                       % (int)(self.virtualSize.height));
}

- (CGPoint)nextHead:(BOOL)food
{
    CGPoint point = [self head];
    CGSize direction = [self headDirection];
    return [self movePoint:point bySize:direction times:1];
}

- (CGPoint)nextTail:(BOOL)food
{
    CGPoint point = [self tail];
    CGSize direction = [self tailDirection];
    if (food)
        return point;
    return [self movePoint:point bySize:direction times:1];
}

- (void)changeDirection:(CGSize)direction
{
    if (self.currentDirection.width + direction.width != 0
        || self.currentDirection.height + direction.height != 0)
    {
        self.currentDirection = direction;
    }
}

- (void)makeStep:(BOOL)food
{
    CGPoint point = [self nextHead:food];
    CGSize direction = self.currentDirection;
    
    [self.points addObject:[NSValue valueWithCGPoint:point]];
    [self.directions addObject:[NSValue valueWithCGSize:direction]];
    
    if (!food)
    {
        [self.points removeObjectAtIndex:0];
        [self.directions removeObjectAtIndex:0];
    }
}

- (id)initAtPoint:(CGPoint)point
    inVirtualSize:(CGSize)virtualSize
        direction:(CGSize)direction
           length:(NSInteger)length
{
    if (self = [super init])
    {
        self.points = [NSMutableArray array];
        self.directions = [NSMutableArray array];
        self.virtualSize = virtualSize;
        
        point = [self movePoint:point bySize:direction times:-length];
        self.currentDirection = direction;
        for (int i = 0; i < length; i++) {
            [self.points addObject:[NSValue valueWithCGPoint:point]];
            [self.directions addObject:[NSValue valueWithCGSize:direction]];
            point = [self movePoint:point bySize:direction times:1];
        }
    }
    return self;
}

@end
