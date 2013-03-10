//
//  ABCanvasView.m
//  Uzh
//
//  Created by Антон Буков on 10.03.13.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ABUzh.h"
#import "ABCanvasView.h"

@interface ABCanvasView ()
@property (nonatomic) NSTimer * timer;
@property (nonatomic) CGSize virtualSize;
@property (nonatomic) CGContextRef drawingContext;
@property (nonatomic) ABUzh * uzh;
@end

@implementation ABCanvasView

- (void)drawMe
{
    UIGraphicsPushContext(self.drawingContext);
    CGImageRef cgImage = CGBitmapContextCreateImage(self.drawingContext);
    UIImage * image = [[UIImage alloc] initWithCGImage:cgImage];
    UIGraphicsPopContext();
    CGImageRelease(cgImage);
    
    self.image = image;
}

- (void)addPoint:(CGPoint)point withColor:(UIColor *)color
{
    CGFloat kw = self.bounds.size.width / self.virtualSize.width;
    CGFloat kh = self.bounds.size.height / self.virtualSize.height;
    
    UIGraphicsPushContext(self.drawingContext);
    [color setFill];
    CGRect rect = CGRectMake(kw*point.x, kh*point.y, kw, kh);
    CGContextFillRect(self.drawingContext, rect);
    UIGraphicsPopContext();
}

- (void)timerFire:(id)sender
{
    BOOL food = NO;
    
    [self addPoint:[self.uzh nextHead:food] withColor:[UIColor blackColor]];
    if (!CGPointEqualToPoint([self.uzh tail], [self.uzh nextTail:food]))
        [self addPoint:[self.uzh tail] withColor:self.backgroundColor];
    [self.uzh makeStep:food];
    
    [self drawMe];
}

- (void)leftToRight:(id)sender
{
    [self.uzh changeDirection:CGSizeMake(1,0)];
}

- (void)rightToLeft:(id)sender
{
    [self.uzh changeDirection:CGSizeMake(-1,0)];
}

- (void)topToBottom:(id)sender
{
    [self.uzh changeDirection:CGSizeMake(0,1)];
}

- (void)bottomToTop:(id)sender
{
    [self.uzh changeDirection:CGSizeMake(0,-1)];
}

- (CGContextRef)createOffscreenContext:(CGSize)size
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width*4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    return context;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.timer = [NSTimer timerWithTimeInterval:1/15. target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        
        self.virtualSize = CGSizeMake(self.bounds.size.width/4, self.bounds.size.height/4);
        self.drawingContext = [self createOffscreenContext:self.bounds.size];
        
        self.uzh = [[ABUzh alloc] initAtPoint:CGPointMake(self.virtualSize.width/2,self.virtualSize.height/2) direction:CGSizeMake(0,-1) length:5];
        for (NSValue * value in [self.uzh allPoints])
            [self addPoint:value.CGPointValue withColor:[UIColor blackColor]];
        
        UISwipeGestureRecognizer * l2r = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftToRight:)];
        UISwipeGestureRecognizer * r2l = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightToLeft:)];
        UISwipeGestureRecognizer * t2b = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(topToBottom:)];
        UISwipeGestureRecognizer * b2t = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(bottomToTop:)];
        
        l2r.direction = UISwipeGestureRecognizerDirectionRight;
        r2l.direction = UISwipeGestureRecognizerDirectionLeft;
        t2b.direction = UISwipeGestureRecognizerDirectionDown;
        b2t.direction = UISwipeGestureRecognizerDirectionUp;
        
        [self addGestureRecognizer:l2r];
        [self addGestureRecognizer:r2l];
        [self addGestureRecognizer:t2b];
        [self addGestureRecognizer:b2t];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIGraphicsPushContext(self.drawingContext);
    CGImageRef cgImage = CGBitmapContextCreateImage(self.drawingContext);
    UIImage * image = [[UIImage alloc] initWithCGImage:cgImage];
    UIGraphicsPopContext();
    CGImageRelease(cgImage);

    //CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    
    self.image = image;
    //[image drawInRect:rect];
}

@end
