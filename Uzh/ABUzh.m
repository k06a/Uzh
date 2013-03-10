//
//  ABUzh.m
//  Uzh
//
//  Created by Антон Буков on 10.03.13.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import "ABUzh.h"

@interface ABUzh ()
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

- (CGPoint)nextHead:(BOOL)food
{
    CGPoint point = [self head];
    CGSize direction = [self headDirection];
    point.x += direction.width;
    point.y += direction.height;
    return point;
}

- (CGPoint)nextTail:(BOOL)food
{
    CGPoint point = [self tail];
    CGSize direction = [self tailDirection];
    if (!food)
    {
        point.x += direction.width;
        point.y += direction.height;
    }
    return point;
}

- (void)changeDirection:(CGSize)direction
{
    self.currentDirection = direction;
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
        direction:(CGSize)direction
           length:(NSInteger)length
{
    if (self = [super init])
    {
        self.points = [NSMutableArray array];
        self.directions = [NSMutableArray array];
        
        point.x += length * (-direction.width);
        point.y += length * (-direction.height);
        self.currentDirection = direction;
        for (int i = 0; i < length; i++) {
            [self.points addObject:[NSValue valueWithCGPoint:point]];
            [self.directions addObject:[NSValue valueWithCGSize:direction]];
            point.x += direction.width;
            point.y += direction.height;
        }
    }
    return self;
}

- (id)init
{
    return [self initAtPoint:CGPointZero direction:CGSizeMake(0, 1) length:1];
}

@end
