//
//  ScreenshotCell.h
//  Yoosee
//
//  Created by guojunyi on 14-4-3.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScreenshotCell;
@protocol ScreenshotCellDelegate <NSObject>

@optional
-(void)onItemPress:(ScreenshotCell*)screenshotCell row:(NSInteger)row index:(NSInteger)index;
@end

@interface ScreenshotCell : UITableViewCell
@property (assign) NSInteger row;
@property (strong, nonatomic) NSString *filePath1;
@property (strong, nonatomic) NSString *filePath2;
@property (strong, nonatomic) NSString *filePath3;
@property (strong, nonatomic) UIImageView *backImgView1;
@property (strong, nonatomic) UIImageView *backImgView2;
@property (strong, nonatomic) UIImageView *backImgView3;
@property (retain, nonatomic) UIButton *backButton1;
@property (retain, nonatomic) UIButton *backButton2;
@property (retain, nonatomic) UIButton *backButton3;

@property (nonatomic, assign) id<ScreenshotCellDelegate> delegate;

@property (nonatomic) BOOL isLoading1;
@property (nonatomic) BOOL isLoading2;
@property (nonatomic) BOOL isLoading3;
@end
