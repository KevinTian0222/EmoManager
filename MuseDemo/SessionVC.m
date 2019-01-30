//
//  SessionVC.m
//  MuseDemo
//
//  Created by Kevin Tian on 2018/7/16.
//  Copyright © 2018 MD. All rights reserved.
//

#import "SessionVC.h"
#import "UserModel.h"

@interface SessionVC ()
@property (weak, nonatomic) IBOutlet UILabel *welcomeLbl;

@end

@implementation SessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.welcomeLbl.text = [NSString stringWithFormat:@"Hi %@! We have prepared different types of courses for you, please make sure that your headband is connected!",[UserModel unarchiver].userName?:@"MuseUser"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
