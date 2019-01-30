//
//  HeartView.h
//  MuseStatsIos
//
//  Created by Kevin Tian on 2018/6/21.
//  Copyright © 2018 InteraXon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeartView : UIView

@property (nonatomic, strong) NSMutableArray *PointsArray;

- (void)updatePoint:(double)nextPointValue;
- (void)updatePoints:(NSArray<NSNumber *> *)pointValues;
- (void)setDefaultPoints;
- (void)setLineColor:(UIColor *)color;

@end
