//
//  ABUzh.h
//  Uzh
//
//  Created by Антон Буков on 10.03.13.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABUzh : NSObject

- (NSArray *)allPoints;

- (CGPoint)head;
- (CGPoint)tail;
- (CGSize)headDirection;
- (CGSize)tailDirection;
- (CGPoint)nextHead:(BOOL)food;
- (CGPoint)nextTail:(BOOL)food;

- (void)changeDirection:(CGSize)direction;
- (void)makeStep:(BOOL)food;

- (id)initAtPoint:(CGPoint)point
        direction:(CGSize)direction
           length:(NSInteger)length;

@end
