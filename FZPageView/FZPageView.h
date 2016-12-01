//
//  FZPageView.h
//  scrollView3.0
//
//  Created by Finn Zhang on 2016/10/18.
//  Copyright © 2016年 Finn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZPageView : UIView



/** 滚动栏图片 */
@property(nonatomic,strong) NSArray *images;

- (void)startWithTimeInterval:(NSTimeInterval)timeInterval;
+ (instancetype)pageViewWithImages:(NSArray *)images;

- (instancetype)initWithImages:(NSArray *)images;

- (void)setPageCtrlWithCurrentPageImage:(UIImage *)CurrentPageImage otherPageImage:(UIImage *)otherPageImage;
@end
