//
//  ABCanvasView.m
//  Uzh
//
//  Created by Антон Буков on 10.03.13.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NSEnumerator+Linq.h"
#import "ABUzh.h"
#import "ABCanvasView.h"

@interface ABCanvasView ()
@property (nonatomic) NSTimer * timer;
@property (nonatomic) BOOL timerEnabled;
@property (nonatomic) CGSize virtualUzhSize;
@property (nonatomic) CGSize virtualMapSize;
@property (nonatomic) CGContextRef drawingContext;
@property (nonatomic) NSArray * map;
@property (nonatomic) CGPoint food;
@property (nonatomic) ABUzh * uzh;
@property (nonatomic) CGPoint uzhStartHead;
@property (nonatomic) CGSize uzhStartDirection;
@end

@implementation ABCanvasView

- (BOOL)isWall:(unichar)ch
{
    return (ch != ' ' && ch != '<' && ch != '>' && ch != '^' && ch != 'v');
}

- (BOOL)isEmpty:(unichar)ch
{
    return (ch == ' ');
}

- (BOOL)isHead:(unichar)ch
{
    return (ch == '<' || ch == '>' || ch == '^' || ch == 'v');
}

- (BOOL)isUzh:(CGPoint)point
{
    for (NSValue * value in [self.uzh allPoints])
        if (CGPointEqualToPoint(value.CGPointValue, point))
            return YES;
    return NO;
}

- (CGPoint)uzhFromMapCoordinates:(CGPoint)point
{
    return CGPointMake(point.x * self.virtualUzhSize.width / self.virtualMapSize.width,
                       point.y * self.virtualUzhSize.height / self.virtualMapSize.height);
}

- (CGPoint)mapFromUzhCoordinates:(CGPoint)point
{
    return CGPointMake(point.x * self.virtualMapSize.width / self.virtualUzhSize.width,
                       point.y * self.virtualMapSize.height / self.virtualUzhSize.height);
}

- (CGPoint)realFromUzhCoordinates:(CGPoint)point
{
    return CGPointMake(point.x * self.bounds.size.width / self.virtualUzhSize.width,
                       point.y * self.bounds.size.height / self.virtualUzhSize.height);
}

- (void)drawMe
{
    UIGraphicsPushContext(self.drawingContext);
    CGImageRef cgImage = CGBitmapContextCreateImage(self.drawingContext);
    UIImage * image = [[UIImage alloc] initWithCGImage:cgImage];
    UIGraphicsPopContext();
    CGImageRelease(cgImage);
    
    self.image = image;
}

- (void)drawMap
{
    CGFloat kw = self.bounds.size.width / self.virtualMapSize.width;
    CGFloat kh = self.bounds.size.height / self.virtualMapSize.height;
    
    UIGraphicsPushContext(self.drawingContext);
    [[UIColor blackColor] setFill];
    for (int r = 0; r < self.virtualMapSize.height; r++) {
        for (int c = 0; c < self.virtualMapSize.width; c++) {
            if ([self isWall:[self.map[r][c] unsignedShortValue]])
            {
                CGRect rect = CGRectIntegral(CGRectMake(kw*c, kh*r, kw, kh));
                CGContextFillRect(self.drawingContext, rect);            
            }
        }
    }
    UIGraphicsPopContext();
}

- (void)drawUzhPoint:(CGPoint)point withColor:(UIColor *)color
{
    CGFloat kw = self.bounds.size.width / self.virtualUzhSize.width;
    CGFloat kh = self.bounds.size.height / self.virtualUzhSize.height;
    
    UIGraphicsPushContext(self.drawingContext);
    [color setFill];
    CGRect rect = CGRectMake(kw*point.x, kh*point.y, kw, kh);
    CGContextFillRect(self.drawingContext, rect);
    UIGraphicsPopContext();
}

- (void)drawFoodPoint:(CGPoint)point withColor:(UIColor *)color
{
    CGFloat kw = self.bounds.size.width / self.virtualUzhSize.width;
    CGFloat kh = self.bounds.size.height / self.virtualUzhSize.height;
    
    UIGraphicsPushContext(self.drawingContext);
    [color setFill];
    CGRect rect = CGRectMake(kw*(point.x-1), kh*(point.y-1), 3*kw, 3*kh);
    CGContextFillRect(self.drawingContext, rect);
    UIGraphicsPopContext();
}

- (void)addFood
{
    while (YES)
    {
        CGPoint upoint = CGPointMake(rand() % (int)(self.virtualUzhSize.width - 2) + 1,
                                     rand() % (int)(self.virtualUzhSize.height - 2) + 1);
        CGPoint mpoint = [self mapFromUzhCoordinates:upoint];
        
        BOOL needRerand = NO;
        for (NSValue * value in [self.uzh allPoints])
        {
            CGPoint point = value.CGPointValue;
            if (point.x >= upoint.x - 1
                && point.y >= upoint.y - 1
                && point.x <= upoint.x + 1
                && point.y <= upoint.y + 1)
            {
                needRerand = YES;
                break;
            }
        }
        if (needRerand) continue;
        
        if ([self isEmpty:[self.map[(int)mpoint.y][(int)mpoint.x] unsignedShortValue]])
        {
            if (!CGPointEqualToPoint(self.food, CGPointZero))
                [self drawFoodPoint:self.food withColor:self.backgroundColor];
            self.food = upoint;
            [self drawFoodPoint:self.food withColor:[UIColor redColor]];
            break;
        }
    }
}

- (void)timerFire:(id)sender
{
    CGPoint nextHead = [self.uzh nextHead:NO];
    int mc = nextHead.x * self.virtualMapSize.width / self.virtualUzhSize.width;
    int mr = nextHead.y * self.virtualMapSize.height / self.virtualUzhSize.height;
    BOOL dead = ([self isWall:[self.map[mr][mc] unsignedShortValue]] || [self isUzh:nextHead]);
    if (dead)
    {
        for (NSValue * value in [self.uzh allPoints])
            [self drawUzhPoint:value.CGPointValue withColor:self.backgroundColor];
        
        self.uzh = [[ABUzh alloc] initAtPoint:self.uzhStartHead
                                inVirtualSize:self.virtualUzhSize
                                    direction:self.uzhStartDirection
                                       length:5];
        
        [self drawMap];
        for (NSValue * value in [self.uzh allPoints])
            [self drawUzhPoint:value.CGPointValue withColor:[UIColor blackColor]];
    }
    
    BOOL food = (nextHead.x >= self.food.x - 1
                 && nextHead.y >= self.food.y - 1
                 && nextHead.x <= self.food.x + 1
                 && nextHead.y <= self.food.y + 1);
    if (food) [self addFood];
    
    [self drawUzhPoint:[self.uzh nextHead:food] withColor:[UIColor blackColor]];
    if (!CGPointEqualToPoint([self.uzh tail], [self.uzh nextTail:food]))
        [self drawUzhPoint:[self.uzh tail] withColor:self.backgroundColor];
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

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    CGPoint head = [self realFromUzhCoordinates:[self.uzh head]];
    CGPoint point = [recognizer locationInView:self];
    
    CGFloat xDist = (head.x - point.x);
    CGFloat yDist = (head.y - point.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    if (distance < 40)
    {
        if (self.timerEnabled)
            [self.timer invalidate];
        else
        {
            self.timer = [NSTimer timerWithTimeInterval:1/20. target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }
        self.timerEnabled = !self.timerEnabled;
        return;
    }
    
    CGFloat dx = point.x - head.x;
    CGFloat dy = point.y - head.y;
    if (abs(dx) > abs(dy))
        [self.uzh changeDirection:CGSizeMake((dx>0)?1:-1,0)];
    else
        [self.uzh changeDirection:CGSizeMake(0,(dy>0)?1:-1)];
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

- (void)loadMap:(NSString *)filename
{
    NSArray * lines = [[NSEnumerator readLines:filename] allObjects];
    int maxLength = [[[lines objectEnumerator] max:FUNC(id, NSString * a, @(a.length))] length];
    
    self.map = [[[[lines objectEnumerator] select:^id(NSString * a) {
        return [a stringByPaddingToLength:maxLength withString:@" " startingAtIndex:0];
    }] select:^id(NSString * a) {
        return [[a enumerateCharacters] allObjects];
    }] allObjects];
    
    self.virtualMapSize = CGSizeMake([self.map[0] count], [self.map count]);
    
    for (int r = 0; r < self.virtualMapSize.height; r++) {
        for (int c = 0; c < self.virtualMapSize.width; c++) {
            unichar ch = [self.map[r][c] unsignedShortValue];
            if (ch == '<' || ch == '>' || ch == '^' || ch == 'v')
            {
                CGFloat kw = self.virtualUzhSize.width / self.virtualMapSize.width;
                CGFloat kh = self.virtualUzhSize.height / self.virtualMapSize.height;
                self.uzhStartHead = CGPointMake(kw*(c + 0.5), kh*(r + 0.5));
                self.uzhStartDirection = CGSizeMake((ch == '>') - (ch == '<'),
                                                    (ch == 'v') - (ch == '^'));
            }
        }
    }
    
    [self drawMap];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.timer = [NSTimer timerWithTimeInterval:1/20. target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        self.timerEnabled = YES;
        
        self.virtualUzhSize = CGSizeMake(self.bounds.size.width/4, self.bounds.size.height/4);
        self.drawingContext = [self createOffscreenContext:self.bounds.size];
        
        [self loadMap:[[NSBundle mainBundle] pathForResource:@"Uzh" ofType:@"txt"]];
        
        self.uzh = [[ABUzh alloc] initAtPoint:self.uzhStartHead
                                inVirtualSize:self.virtualUzhSize
                                    direction:self.uzhStartDirection
                                       length:5];
        
        [self addFood];
        
        for (NSValue * value in [self.uzh allPoints])
            [self drawUzhPoint:value.CGPointValue withColor:[UIColor blackColor]];
        
        UISwipeGestureRecognizer * l2r = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftToRight:)];
        UISwipeGestureRecognizer * r2l = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightToLeft:)];
        UISwipeGestureRecognizer * t2b = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(topToBottom:)];
        UISwipeGestureRecognizer * b2t = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(bottomToTop:)];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        
        l2r.direction = UISwipeGestureRecognizerDirectionRight;
        r2l.direction = UISwipeGestureRecognizerDirectionLeft;
        t2b.direction = UISwipeGestureRecognizerDirectionDown;
        b2t.direction = UISwipeGestureRecognizerDirectionUp;
        
        [self addGestureRecognizer:l2r];
        [self addGestureRecognizer:r2l];
        [self addGestureRecognizer:t2b];
        [self addGestureRecognizer:b2t];
        [self addGestureRecognizer:tap];
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
