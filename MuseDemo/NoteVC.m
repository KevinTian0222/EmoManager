//
//  NoteVC.m
//  MuseDemo
//
//  Created by Mercedes on 2018/7/17.
//  Copyright © 2018 MD. All rights reserved.
//

#import "NoteVC.h"
#import "UserModel.h"
#import <CommonCrypto/CommonCrypto.h>

@interface NoteVC () <UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;
@property (copy, nonatomic) NSString *md5Str;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addLeftCons;

@end

@implementation NoteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.addLeftCons.constant = 16.f;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publishAction:(id)sender {
    if (self.textView.text.length == 0 || !self.photoImgView.image) {
        return;
    }
    SessionModel *sessionModel = [SessionModel new];
    NSDateFormatter *format = [NSDateFormatter new];
    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    sessionModel.dateStr = [format stringFromDate:[NSDate date]];
    sessionModel.feelingStr = self.textView.text;
    sessionModel.sessionType = @"0";
    NSData *imageData = UIImageJPEGRepresentation(self.photoImgView.image, 1);
    NSString *imagePath = getFilePathByName([NSString stringWithFormat:@"%@.jpg",self.md5Str]);
    if(![imageData writeToFile:imagePath atomically:YES]){
        NSLog(@"Failed to save photo to local!");
    };
    sessionModel.feelingImgPath = imagePath;
    UserModel *userModel = [UserModel unarchiver];
    NSMutableArray *sessions = userModel.sessionModels.mutableCopy;
    if (!sessions) {
        sessions = @[].mutableCopy;
    }
    [sessions addObject:sessionModel];
    userModel.sessionModels = sessions.copy;
    [UserModel archiverModel:userModel];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addPhotoAction:(id)sender {
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
    if (resultImage) {
        self.photoImgView.image = resultImage;
        self.addLeftCons.constant = 136.f;
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableDictionary *)getParametersWithURL:(NSString *)URL {
    
    // 查找参数
    NSRange range = [URL rangeOfString:@""];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // Take the parameter
    NSString *parametersString = [URL substringFromIndex:range.location + 1];
    
    // Check whether single or multiple parameter(s)
    if ([parametersString containsString:@"&"]) {
        
        // If multiple, seperate them
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // generate Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key cannot be nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // value already existed, generate arrays
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // generate arrays with values
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // not arrays
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // set value
                [params setValue:value forKey:key];
            }
        }
    } else {
        // single parameter
        
        // generate Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // one parameter, no value
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // seperate values
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key cannot be nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // set value
        [params setValue:value forKey:key];
    }
    
    return params;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    textView.text = @"";
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = @"How do you feeling now...";
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textView resignFirstResponder];
}

@end
