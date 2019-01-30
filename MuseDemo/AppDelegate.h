//
//  AppDelegate.h
//  MuseDemo
//
//  Created by Kevin Tian on 2018/6/25.
//  Copyright © 2018 MD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Muse/Muse.h>
#import "MBProgressHUD.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@protocol MuseDataChangeDelegate<NSObject>

@required
- (void)museDataChange:(double)eeg1 eeg2:(double)eeg2 eeg3:(double)eeg3 eeg4:(double)eeg4;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property IXNMuseManagerIos * manager;
@property (strong, nonatomic) IXNMuse * muse;
@property (copy , nonatomic) dispatch_block_t connectChangeBlock;
@property (weak , nonatomic) id<MuseDataChangeDelegate> dataChangeDelegate;

@property (strong, nonatomic) NSMutableArray *eeg1Values;

- (void)connect;

@end

