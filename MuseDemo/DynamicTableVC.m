//
//  TableViewController1.m
//  MuseDemo
//
//  Created by Kevin Tian on 2018/7/16.
//  Copyright © 2018 MD. All rights reserved.
//

#import "DynamicTableVC.h"
#import "UserModel.h"
#import "HeartView.h"
#import "AppDelegate.h"

@interface TableViewCell1 ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *stateLbl;
@property (weak, nonatomic) IBOutlet UILabel *feelingLbl;
@property (weak, nonatomic) IBOutlet HeartView *alphaView;

@end

@implementation TableViewCell1

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end

@interface TableViewCell2 ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *feelingLbl;
@property (weak, nonatomic) IBOutlet UIImageView *feelingImg;
@end

@implementation TableViewCell2

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end

@interface DynamicTableVC ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UserModel *userModel;

@end

@implementation DynamicTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.userModel = [UserModel unarchiver];
    self.dataArray = self.userModel.sessionModels;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count?:1.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count == 0) {
        TableViewCell2 *cell2 = [tableView dequeueReusableCellWithIdentifier:@"dynamiccontent" forIndexPath:indexPath];
        cell2.nameLbl.text = self.userModel.userName?: @"MuseUser";
        UIImage *image = [UIImage imageWithContentsOfFile:getFilePathByName(self.userModel.userAvatarPath.lastPathComponent)];
        if (image) cell2.avatarImg.image = image;
        cell2.feelingLbl.text = @"I'm feeling happy now, thank you for you being here!";
        cell2.feelingImg.image = [UIImage imageNamed:@"test"];
        cell2.timeLbl.text = @"2018-6-4 18:00";
        return cell2;
    }
    SessionModel *sessionModel = [self.dataArray objectAtIndex:indexPath.row];
    if ([sessionModel.sessionType isEqualToString:@"1"]) {
        TableViewCell1 * cell1 = [tableView dequeueReusableCellWithIdentifier:@"dynamicstate" forIndexPath:indexPath];
        cell1.nameLbl.text = self.userModel.userName?:@"MuseUser";
        UIImage *image = [UIImage imageWithContentsOfFile:getFilePathByName(self.userModel.userAvatarPath.lastPathComponent)];
        if (image) cell1.avatarImg.image = image;
        cell1.timeLbl.text = sessionModel.dateStr;
        cell1.stateLbl.text = sessionModel.stateStr;
        cell1.feelingLbl.text = sessionModel.feelingStr;
        if ([sessionModel.stateStr containsString:@"Happy"]) {
            [cell1.alphaView setLineColor:UIColorFromRGB(0x0b5cb1)];
        }else if ([sessionModel.stateStr containsString:@"Relaxed"]) {
            [cell1.alphaView setLineColor:UIColorFromRGB(0x50c5ac)];
        }else {
            [cell1.alphaView setLineColor:UIColorFromRGB(0xa03557)];
        }
        [cell1.alphaView updatePoints:sessionModel.musePacket];
        return cell1;
    }
    TableViewCell2 *cell2 = [tableView dequeueReusableCellWithIdentifier:@"dynamiccontent" forIndexPath:indexPath];
    cell2.nameLbl.text = self.userModel.userName?:@"MuseUser";
    UIImage *image = [UIImage imageWithContentsOfFile:getFilePathByName(self.userModel.userAvatarPath.lastPathComponent)];
    if (image) cell2.avatarImg.image = image;
    cell2.timeLbl.text = sessionModel.dateStr;
    cell2.feelingLbl.text = sessionModel.feelingStr;
    UIImage *feelingImage = [UIImage imageWithContentsOfFile:getFilePathByName(sessionModel.feelingImgPath.lastPathComponent)];
    if (feelingImage) cell2.feelingImg.image = feelingImage;
    return cell2;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataArray.count > 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SessionModel *sessionModel = [self.dataArray objectAtIndex:indexPath.row];
        NSMutableArray *sessions = self.userModel.sessionModels.mutableCopy;
        [sessions removeObject:sessionModel];
        self.userModel.sessionModels = sessions.copy;
        [UserModel archiverModel:self.userModel];
        self.dataArray = sessions;
        [self.tableView reloadData];
    }
}
@end
