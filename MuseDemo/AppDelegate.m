//
//  AppDelegate.m
//  MuseDemo
//
//  Created by Kevin Tian on 2018/6/25.
//  Copyright © 2018 MD. All rights reserved.
//

#import "AppDelegate.h"
#import "UserModel.h"
#import "ConnectVC.h"

@interface AppDelegate () <IXNMuseListener,IXNMuseConnectionListener,IXNMuseDataListener,IXNLogListener>

@end

@implementation AppDelegate {
    MBProgressHUD *hud;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.manager = [IXNMuseManagerIos sharedManager];
    [self.manager setMuseListener:self];
    [[IXNLogManager instance] setLogListener:self];
    [self.manager startListening];
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self connect];
    if (self.muse.getConnectionState != IXNConnectionStateConnected) {
        if(!hud.superview) hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.3f];
        hud.label.text = @"Please Put the Muse Headband On!";
        [hud hideAnimated:YES afterDelay:3.f];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)museListChanged {
    IXNMuse *muse = [[IXNMuseManagerIos sharedManager] getMuses].firstObject;
    if (muse) {
        self.muse = muse;
        [self connect];
    }
}

- (void)connect {
    [self.muse registerConnectionListener:self];
    [self.muse registerDataListener:self
                               type:IXNMuseDataPacketTypeArtifacts];
    [self.muse registerDataListener:self
                               type:IXNMuseDataPacketTypeAlphaAbsolute];
    /*
     [self.muse registerDataListener:self
     type:IXNMuseDataPacketTypeEeg];
     */
    [self.muse runAsynchronously];
    // Change the background view style and color.
}

- (void)receiveMuseDataPacket:(IXNMuseDataPacket *)packet
                         muse:(IXNMuse *)muse {
    if (packet.packetType == IXNMuseDataPacketTypeAlphaAbsolute ||
        packet.packetType == IXNMuseDataPacketTypeEeg) {
//        [self log:@"%5.2f %5.2f %5.2f %5.2f",
//         [packet.values[IXNEegEEG1] doubleValue],
//         [packet.values[IXNEegEEG2] doubleValue],
//         [packet.values[IXNEegEEG3] doubleValue],
//         [packet.values[IXNEegEEG4] doubleValue]];
//        if ([self.dataChangeDelegate conformsToProtocol:@protocol(MuseDataChangeDelegate)]) {
//            [self.dataChangeDelegate museDataChange:[packet.values[IXNEegEEG1] doubleValue] eeg2:[packet.values[IXNEegEEG2] doubleValue] eeg3:[packet.values[IXNEegEEG3] doubleValue] eeg4:[packet.values[IXNEegEEG4] doubleValue]];
//        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MuseDataNoti" object:nil userInfo:@{@"eeg1":packet.values[IXNEegEEG1]}];
        [self saveMuseEEG1Value:packet.values[IXNEegEEG1].doubleValue];
    }
}

- (void)receiveMuseConnectionPacket:(nonnull IXNMuseConnectionPacket *)packet muse:(nullable IXNMuse *)muse {
    !self.connectChangeBlock?:self.connectChangeBlock();
    switch (packet.currentConnectionState) {
        case IXNConnectionStateDisconnected:{
            if(!hud.superview) hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
            hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.3f];
            hud.label.text = @"Please Put the Muse Headband On!";
            [hud hideAnimated:YES afterDelay:3.f];
            ConnectVC *conVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ConnectVC"];
            UITabBarController *tabVC = (UITabBarController *)self.window.rootViewController;
            tabVC.selectedIndex = 1;
            UINavigationController *vc = tabVC.viewControllers[1];
            if (![vc.visibleViewController isKindOfClass:[ConnectVC class]]) {
                [vc pushViewController:conVC animated:YES];
            }
        }
            break;
        case IXNConnectionStateConnected: {
            if(!hud.superview) hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
            hud.mode = MBProgressHUDModeCustomView;
            UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            hud.customView = [[UIImageView alloc] initWithImage:image];
            hud.label.text = @"Muse Connected";
            [hud hideAnimated:YES afterDelay:3.f];
        }
            break;
        case IXNConnectionStateConnecting: {
            if(!hud.superview) hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
            hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.3f];
            hud.label.text = @"Muse Connecting...";
            [hud showAnimated:YES];
        }
            break;
        default: NSAssert(NO, @"impossible connection state received");
    }
}

- (void)receiveMuseArtifactPacket:(nonnull IXNMuseArtifactPacket *)packet muse:(nullable IXNMuse *)muse {
    if (packet.blink) {
        [self log:@"blink detected"];
    }
}

- (void)receiveLog:(nonnull IXNLogPacket *)l {
    [self log:@"%@: %llu raw:%d %@", l.tag, l.timestamp, l.raw, l.message];
}

- (void)log:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    NSString *line = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    NSLog(@"%@", line);
}

double totalValue;
- (void)saveMuseEEG1Value:(double)eeg1 {
    NSNumber *eeg1Num = [NSNumber numberWithDouble:eeg1];
    NSNumber *lastNum = self.eeg1Values.lastObject;
    if (fabs(eeg1 - lastNum.doubleValue) > 0.01) {
        totalValue += eeg1;
        [self.eeg1Values addObject:eeg1Num];
    }
    NSInteger count = (self.window.bounds.size.width - 64) * 2;
    if (self.eeg1Values.count > count) {
        SessionModel *sessionModel = [SessionModel unarchiver];
        NSDateFormatter *format = [NSDateFormatter new];
        [format setDateFormat:@"yyyy-MM-dd HH:mm"];
        sessionModel.dateStr = [format stringFromDate:[NSDate date]];
        double averageValue = 0;
        averageValue = totalValue / self.eeg1Values.count;
        totalValue = 0;
        if (averageValue < 0.35) {
            sessionModel.stateStr = @"State Unhappy 😞";
            sessionModel.feelingStr = @"I'm not feeling too well, something is wrong...";
        }else if (0.55 > averageValue >= 0.35) {
            sessionModel.stateStr = @"State Relaxed ☺️";
            sessionModel.feelingStr = @"I'm feeling relaxed; just enjoying the moment.";
        }else {
            sessionModel.stateStr = @"State: Happy 😄";
            sessionModel.feelingStr = @"I'm feeling great,thank you for being here!";
        }
        sessionModel.sessionType = @"1";
        sessionModel.musePacket = self.eeg1Values.copy;
        [SessionModel archiverModel:sessionModel];
        [self.eeg1Values removeAllObjects];
        
        UserModel *userModel = [UserModel unarchiver];
        NSMutableArray *sessions = userModel.sessionModels.mutableCopy;
        [sessions addObject:sessionModel];
        userModel.sessionModels = sessions.copy;
        [UserModel archiverModel:userModel];
    }
}

- (NSMutableArray *)eeg1Values {
    if (!_eeg1Values) {
        _eeg1Values = @[].mutableCopy;
    }
    return _eeg1Values;
}

@end
