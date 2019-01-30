//
//  EditVC.m
//  MuseDemo
//
//  Created by Kevin Tian on 2018/7/17.
//  Copyright © 2018 MD. All rights reserved.
//

#import "EditVC.h"
#import "UserModel.h"
#import <CommonCrypto/CommonCrypto.h>

@interface EditVC () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextFd;
@property (weak, nonatomic) IBOutlet UITextField *sexTextFd;
@property (weak, nonatomic) IBOutlet UITextField *birthDayTextFd;
@property (copy, nonatomic) NSString *md5Str;

@end

@implementation EditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UserModel *usermodel = [UserModel unarchiver];
    self.nickNameTextFd.text = usermodel.userName;
    self.sexTextFd.text = usermodel.userSex;
    self.birthDayTextFd.text = usermodel.userBirthDay;
    NSData *imageData = [NSData dataWithContentsOfFile:getFilePathByName(usermodel.userAvatarPath.lastPathComponent)];
    UIImage *image = [UIImage imageWithData:imageData];
    if (image) {
        self.avatarImgView.image = image;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeAvatarAction:(id)sender {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    pickerController.delegate = self;
    [self.navigationController presentViewController:pickerController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"%@",info);
    NSString *imgURL = [info objectForKey:@"UIImagePickerControllerImageURL"];
    if (!imgURL) {
        imgURL = ((NSURL *)[info objectForKey:@"UIImagePickerControllerReferenceURL"]).absoluteString;
    }
    UIImage *resultImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgURL]];
    if (!resultImage) {
        resultImage = info[UIImagePickerControllerOriginalImage];
    }
    NSData *data = UIImageJPEGRepresentation(resultImage, 0.02);
    resultImage = [UIImage imageWithData:data];
    if (!imgURL) {
        self.md5Str = [self getParametersWithURL:imgURL][@"id"];

    }
        self.avatarImgView.image = resultImage;
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)savedAction:(id)sender {
    if (!self.nickNameTextFd.text.length || !self.sexTextFd.text.length || !self.birthDayTextFd.text.length) {
        return;
    }
    UserModel *userModel = [UserModel unarchiver];
    userModel.userName = self.nickNameTextFd.text;
    userModel.userSex = self.sexTextFd.text;
    userModel.userBirthDay = self.birthDayTextFd.text;
    NSData *avatarData = UIImageJPEGRepresentation(self.avatarImgView.image, 1);
    NSString *avatarPath = getFilePathByName([NSString stringWithFormat:@"%@.jpg",self.md5Str]);
    if (![avatarData writeToFile:avatarPath atomically:YES]) {
        NSLog(@"Failed to save avatar to local!");
    }
    userModel.userAvatarPath = avatarPath;
    [UserModel archiverModel:userModel];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableDictionary *)getParametersWithURL:(NSString *)URL {
    
    // 查找参数
    NSRange range = [URL rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [URL substringFromIndex:range.location + 1];
    
    if ([parametersString containsString:@"&"]) {
     
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
   
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
        if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
           
                if ([existValue isKindOfClass:[NSArray class]]) {
                
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
    
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                [params setValue:value forKey:key];
            }
        }
    } else {
       
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        if (pairComponents.count == 1) {
            return nil;
        }
      
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        if (key == nil || value == nil) {
            return nil;
        }
    
        [params setValue:value forKey:key];
    }
    
    return params;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.nickNameTextFd resignFirstResponder];
    [self.sexTextFd resignFirstResponder];
    [self.birthDayTextFd resignFirstResponder];
}

@end
