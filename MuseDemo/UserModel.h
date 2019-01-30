//
//  UserModel.h
//  MuseDemo
//
//  Created by Kevin Tian on 2018/7/23.
//  Copyright © 2018 MD. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * getFilePathByName(NSString *name);

@class SessionModel;
@interface UserModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userSex;
@property (nonatomic, copy) NSString *userBirthDay;
@property (nonatomic, copy) NSString *userAvatarPath;
@property (nonatomic, copy) NSArray <SessionModel *>* sessionModels;

+ (void)archiverModel:(UserModel *)model;
+ (UserModel *)unarchiver;

@end

@interface SessionModel : NSObject <NSCoding,NSCopying>

@property (nonatomic, copy) NSString *dateStr;
@property (nonatomic, copy) NSString *stateStr;
@property (nonatomic, copy) NSString *feelingStr;
@property (nonatomic, copy) NSString *feelingImgPath;
@property (nonatomic, copy) NSString *sessionType;// 1正常 0带图
@property (nonatomic, copy) NSArray <NSNumber *>* musePacket;

+ (void)archiverModel:(SessionModel *)model;
+ (SessionModel *)unarchiver;

@end
