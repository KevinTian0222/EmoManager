//
//  SettingsVC.m
//  MuseDemo
//
//  Created by Kevin Tian on 2018/7/16.
//  Copyright © 2018 MD. All rights reserved.
//

#import "SettingsVC.h"
#import "AppDelegate.h"
#import "HeartView.h"
#import "UserModel.h"

@interface SettingsVC ()
@property (weak, nonatomic) IBOutlet HeartView *alphaView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *stateLbl;
@property (weak, nonatomic) IBOutlet UILabel *feelinglbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *practiceLbl;
@property (weak, nonatomic) IBOutlet UILabel *fansLbl;
@property (weak, nonatomic) IBOutlet UILabel *idolLbl;

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.alphaView.layer.cornerRadius = 8.f;
    self.alphaView.layer.masksToBounds = YES;
//    ((AppDelegate *)[UIApplication sharedApplication].delegate).dataChangeDelegate = self;
    [self.alphaView setDefaultPoints];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciveEEG1Data:) name:@"MuseDataNoti" object:nil];
}

- (void)reciveEEG1Data:(NSNotification *)noti {
    NSNumber *eeg1Num = noti.userInfo[@"eeg1"];
    [self.alphaView updatePoint:-eeg1Num.doubleValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UserModel *usermodel = [UserModel unarchiver];
    NSData *imageData = [NSData dataWithContentsOfFile:getFilePathByName(usermodel.userAvatarPath.lastPathComponent)];
    UIImage *image = [UIImage imageWithData:imageData];
    if (image) self.avatarImgView.image = image;
    self.nameLbl.text = usermodel.userName?:@"MuseUser";
    self.practiceLbl.text = [NSString stringWithFormat:@"%lu",usermodel.sessionModels.count];
    __block NSUInteger emo = 0,feel = 0;
    [usermodel.sessionModels enumerateObjectsUsingBlock:^(SessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.sessionType isEqualToString:@"1"]) {
            emo++;
        }else {
            feel++;
        }
    }];
    self.fansLbl.text = [NSString stringWithFormat:@"%lu",emo];
    self.idolLbl.text = [NSString stringWithFormat:@"%lu",feel];
    SessionModel *sessionmodel = usermodel.sessionModels.lastObject;
    if (sessionmodel) {
        self.stateLbl.text = sessionmodel.stateStr;
        self.feelinglbl.text = sessionmodel.feelingStr;
        self.timeLbl.text = sessionmodel.dateStr;
        if ([sessionmodel.stateStr containsString:@"Happy"]) {
            [self.alphaView setLineColor:UIColorFromRGB(0x0b5cb1)];
        }else if ([sessionmodel.stateStr containsString:@"Relaxed"]) {
            [self.alphaView setLineColor:UIColorFromRGB(0x50c5ac)];
        }else {
            [self.alphaView setLineColor:UIColorFromRGB(0xa03557)];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

//- (void)museDataChange:(double)eeg1 eeg2:(double)eeg2 eeg3:(double)eeg3 eeg4:(double)eeg4 {
//    [self.alphaView updatePoint:-eeg1];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
