//
//  UserModel.m
//  MuseDemo
//
//  Created by Kevin Tian on 2018/7/23.
//  Copyright © 2018 MD. All rights reserved.
//

#import "UserModel.h"

NSString * getFilePathByName(NSString *name) {
    NSString *filePath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        filePath = paths.firstObject;
        
        // if the content does not exist, create one.
        if (! [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error;
            // create content
            if(! [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error])
            {
                NSLog(@"Failed to create directory. error: %@",error);
            }
        }
    }
    return [filePath stringByAppendingPathComponent:name];
};

@implementation UserModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.userSex forKey:@"userSex"];
    [aCoder encodeObject:self.userBirthDay forKey:@"userBirthDay"];
    [aCoder encodeObject:self.userAvatarPath forKey:@"userAvatarPath"];
    [aCoder encodeObject:self.sessionModels forKey:@"sessionModels"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.userSex = [aDecoder decodeObjectForKey:@"userSex"];
        self.userBirthDay = [aDecoder decodeObjectForKey:@"userBirthDay"];
        self.userAvatarPath = [aDecoder decodeObjectForKey:@"userAvatarPath"];
        self.sessionModels = [aDecoder decodeObjectForKey:@"sessionModels"];
    }
    return self;
}

+ (NSString *)filePath {
    NSString *filePath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        filePath = paths.firstObject;
        
        if (! [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error;
            if(! [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error])
            {
                NSLog(@"Failed to create directory. error: %@",error);
            }
        }
    }
    return [filePath stringByAppendingPathComponent:@"MuseUserData.archiver"];
}

+ (void)archiverModel:(UserModel *)model {
    NSMutableData *mutData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mutData];
    [archiver encodeObject:model forKey:@"MuseUserModel"];
    [archiver finishEncoding];
    if (![mutData writeToFile:[UserModel filePath] atomically:YES]) {
        NSLog(@"Failed to write file to filePath");
    }
}

+ (UserModel *)unarchiver {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[UserModel filePath]]) {
        NSData *data = [NSData dataWithContentsOfFile:[UserModel filePath]];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        UserModel *model = [unarchiver decodeObjectForKey:@"MuseUserModel"];
        [unarchiver finishDecoding];
        return model;
    }
    return [UserModel new];
}

@end

@implementation SessionModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        self.dateStr = [aDecoder decodeObjectForKey:@"dateStr"];
        self.stateStr = [aDecoder decodeObjectForKey:@"stateStr"];
        self.feelingStr = [aDecoder decodeObjectForKey:@"feelingStr"];
        self.feelingImgPath = [aDecoder decodeObjectForKey:@"feelingImgPath"];
        self.sessionType = [aDecoder decodeObjectForKey:@"sessionType"];
        self.musePacket = [aDecoder decodeObjectForKey:@"musePacket"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.dateStr forKey:@"dateStr"];
    [aCoder encodeObject:self.stateStr forKey:@"stateStr"];
    [aCoder encodeObject:self.feelingStr forKey:@"feelingStr"];
    [aCoder encodeObject:self.feelingImgPath forKey:@"feelingImgPath"];
    [aCoder encodeObject:self.sessionType forKey:@"sessionType"];
    [aCoder encodeObject:self.musePacket forKey:@"musePacket"];
}


- (id)copyWithZone:(NSZone *)zone{
    SessionModel *copy = [[[self class] allocWithZone:zone] init];
    copy.dateStr = [self.dateStr copyWithZone:zone];
    copy.stateStr = [self.stateStr copyWithZone:zone];
    copy.feelingStr = [self.feelingStr copyWithZone:zone];
    copy.feelingImgPath = [self.feelingImgPath copyWithZone:zone];
    copy.sessionType = [self.sessionType copyWithZone:zone];
    copy.musePacket = [self.musePacket copyWithZone:zone];
    return copy;
}

+ (NSString *)filePath {
    NSString *filePath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        filePath = paths.firstObject;
        
        if (! [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error;
            if(! [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error])
            {
                NSLog(@"Failed to create directory. error: %@",error);
            }
        }
    }
    return [filePath stringByAppendingPathComponent:@"MuseSessionData.archiver"];
}

+ (void)archiverModel:(SessionModel *)model {
    NSMutableData *mutData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mutData];
    [archiver encodeObject:model forKey:@"MuseSessionModel"];
    [archiver finishEncoding];
    if (![mutData writeToFile:[SessionModel filePath] atomically:YES]) {
        NSLog(@"Failed to write file to filePath");
    }
}

+ (SessionModel *)unarchiver {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[SessionModel filePath]]) {
        NSData *data = [NSData dataWithContentsOfFile:[SessionModel filePath]];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        SessionModel *model = [unarchiver decodeObjectForKey:@"MuseSessionModel"];
        [unarchiver finishDecoding];
        return model;
    }
    return [SessionModel new];
}

@end
