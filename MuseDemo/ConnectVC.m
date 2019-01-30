//
//  ConnectVC.m
//  MuseDemo
//
//  Created by Kevin Tian on 2018/7/23.
//  Copyright © 2018 MD. All rights reserved.
//

#import "ConnectVC.h"
#import "AppDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <Muse/Muse.h>

@interface ConnectVC () <CBCentralManagerDelegate>
@property (nonatomic, weak) AppDelegate *myDelegate;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@end

@implementation ConnectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLbl.text = self.myDelegate.muse.getName;
    self.connectBtn.enabled = self.myDelegate.muse.getConnectionState != IXNConnectionStateConnected;
    self.myDelegate.connectChangeBlock = ^(){
        self.nameLbl.text = self.myDelegate.muse.getName;
        self.connectBtn.enabled = self.myDelegate.muse.getConnectionState != IXNConnectionStateConnected;
    };
}

- (IBAction)connectAction:(id)sender {
    if (!self.myDelegate.muse.getName) {
        return;
    }
    if (self.myDelegate.muse.getConnectionState != IXNConnectionStateConnected) {
        [self.myDelegate connect];
        self.connectBtn.enabled = NO;
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AppDelegate *)myDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

@end
