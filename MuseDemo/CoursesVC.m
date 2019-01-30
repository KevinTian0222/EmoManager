//
//  CoursesVC.m
//  MuseDemo
//
//  Created by Kevin Tian on 2018/7/17.
//  Copyright © 2018 MD. All rights reserved.
//

#import "CoursesVC.h"
#import "AppDelegate.h"
#import "HeartView.h"
#import <AVFoundation/AVFoundation.h>

@interface CoursesVC ()

@property (weak, nonatomic) IBOutlet HeartView *heartView;
@property (strong, nonatomic) NSArray *audioArray;

@end

@implementation CoursesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.audioArray = @[
                        [AVPlayer playerWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"rain" ofType:@"mp3"]]],
                        [AVPlayer playerWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"wave" ofType:@"mp3"]]],
                        [AVPlayer playerWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"wind" ofType:@"mp3"]]],
                        [AVPlayer playerWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fire" ofType:@"mp3"]]],
                        ];
    [self.heartView setLineColor:UIColorFromRGB(0x50c5ac)];
    [self.heartView setDefaultPoints];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciveEEG1Data:) name:@"MuseDataNoti" object:nil];
}

- (void)reciveEEG1Data:(NSNotification *)noti {
    NSNumber *eeg1Num = noti.userInfo[@"eeg1"];
    [self.heartView updatePoint:-eeg1Num.doubleValue];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    AVPlayer *player = self.audioArray[indexPath.row];
    UIView *view = cell.contentView.subviews.firstObject;
    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            ((UIButton *)obj).selected = !((UIButton *)obj).selected;
            ((UIButton *)obj).selected ? [player play] : [player pause];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
