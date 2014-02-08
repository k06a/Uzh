//
//  ABPlayground.h
//  Uzh
//
//  Created by Антон Буков on 26.01.14.
//  Copyright (c) 2014 Anton Bukov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABPlayground : NSObject

@property (strong, nonatomic) NSArray *walls;
@property (assign, nonatomic, readonly) CGSize size;
- (CGPoint)pointFromPoint:(CGPoint)point withDirection:(CGSize)direction;


@end
