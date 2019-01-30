//
//  HeartView.m
//  MuseStatsIos
//
//  Created by Kevin Tian on 2018/6/21.
//  Copyright © 2018 InteraXon. All rights reserved.
//

#import "HeartView.h"
#import "AppDelegate.h"

@interface HeartView()

@property (nonatomic,strong) UIColor *color;

@end

/* gap between each point*/

const CGFloat KXScale = 0.2;

/* height of each image*/

const CGFloat KYScale = 50.0;

/* generate a symmetric function*/

static inline CGAffineTransform

CGAffineTransformMakeScaleTranslate(CGFloat sx ,CGFloat sy,CGFloat dx ,CGFloat dy){
    
    return CGAffineTransformMake(sx, 0.f, 0.f, sy, dx, dy);
    
}

@implementation HeartView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self == [super initWithFrame:frame]) {
        
        /* background color*/
        self.backgroundColor = [UIColor whiteColor];
        
    }
    
    return self;
}

- (void)setLineColor:(UIColor *)color {
    self.color = color;
}

-(void)updatePoint:(double)nextPointValue {
    
    /* switch target to save*/
    NSNumber * NextPointObject = [NSNumber numberWithDouble:nextPointValue];
    
    /* save in the arrays*/
    if (self.PointsArray.count == 0) {
        [self.PointsArray addObject:@0];
    }
    [self.PointsArray addObject:NextPointObject];
    
    /* count the number of points the canvas could hold*/
    
    NSInteger CanvasCount = (NSInteger)floorl(self.frame.size.width/KXScale);
    
    /* eliminate the exceeded points from the array*/
    
    if ([self.PointsArray count] > CanvasCount) {

        [self.PointsArray removeObjectsInRange:NSMakeRange(0,self.PointsArray.count - CanvasCount)];
    }
    
    /* draw */
    
    [self setNeedsDisplay];
    
}

- (void)updatePoints:(NSArray<NSNumber *> *)pointValues {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /* save in the array*/
        if (self.PointsArray.count == 0) {
            [self.PointsArray addObject:@0];
        }
        [self.PointsArray addObjectsFromArray:pointValues];
        
        /* count the number of points the canvas could hold*/
        
        NSInteger CanvasCount = (NSInteger)floorl(self.frame.size.width/KXScale);
        
        if ([self.PointsArray count] > CanvasCount) {
            
            [self.PointsArray removeObjectsInRange:NSMakeRange(0,self.PointsArray.count - CanvasCount)];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            /* draw */
            [self setNeedsDisplay];
        });
    });
}

- (void)setDefaultPoints {
    NSInteger CanvasCount = (NSInteger)floorl(self.frame.size.width/KXScale);
    for (NSInteger i = 0; i <= CanvasCount; i++) {
        [self.PointsArray addObject:@(0)];
    }
}

#pragma mark -- 进行绘制的代码

- (void)drawRect:(CGRect)rect {
    
    /* check if there is data in the array*/
    
    if ([self.PointsArray count]==0) {
        
        return;
        
    }
    
    
    CGContextRef ContextRef =  UIGraphicsGetCurrentContext();
    
    /* setting color*/
    
    CGContextSetStrokeColorWithColor(ContextRef, self.color.CGColor);
    
    /* width of the stroke*/
    
    CGContextSetLineWidth(ContextRef, 2.5);
    
    /* the style of the connection between canvases*/
    
    CGContextSetLineJoin(ContextRef, kCGLineJoinRound);
    
    CGMutablePathRef Paths = CGPathCreateMutable();
    
    /* take half the height of the canvas*/
    
    CGFloat CanvasMidHeightFloat = self.bounds.size.height * 0.5;
    
    CGFloat CanvasYScale = KYScale * self.bounds.size.height / 300;
    
    /* generate an object of rotation*/
    
    CGAffineTransform transform = CGAffineTransformMakeScaleTranslate(KXScale, CanvasYScale, 0, CanvasMidHeightFloat);
    
    /* beginning point of the stroke*/
    
    CGFloat startY = [self.PointsArray[0] floatValue];
    
    /* generate stroke*/
    
    CGPathMoveToPoint(Paths, &transform, 0, startY);
    
    for (NSUInteger x =1; x<self.PointsArray.count; ++x) {
        
        /* transform data*/
        
        startY = [self.PointsArray[x] floatValue];
        
        /* store it in to the path*/
        
        CGPathAddLineToPoint(Paths, &transform, x, startY);
        
    }
    
    /* start drawing*/
    
    CGContextAddPath(ContextRef, Paths);
    
    /* release path*/
    
    CGPathRelease(Paths);
    
    /* close path*/
    
    CGContextStrokePath(ContextRef);
    
}

- (NSMutableArray *)PointsArray {
    if (!_PointsArray) {
        _PointsArray = @[].mutableCopy;
    }
    return _PointsArray;
}

- (UIColor *)color {
    if (!_color) {
        _color = UIColorFromRGB(0x0b5cb1);
    }
    return _color;
}

- (void)dealloc {
    
}

@end
