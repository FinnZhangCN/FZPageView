//
//  FZPageView.m
//  scrollView3.0
//
//  Created by Finn Zhang on 2016/10/18.
//  Copyright © 2016年 Finn. All rights reserved.
//

/** 无限循环图片轮播器,含自动播放 */


#import "FZPageView.h"

@interface FZPageView ()<UIScrollViewDelegate>
/** 图片轮播器 */
@property(nonatomic,weak) UIScrollView *scrollView;

/** 分页标签 */
@property(nonatomic,weak) UIPageControl *pageCtrl;

/** 计时器 */
@property(nonatomic,weak) NSTimer *timer;

/** 轮播时间 */
@property(nonatomic,assign) NSTimeInterval timeInterval;
@end

@implementation FZPageView

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        /** 创建子控件scrollView以及pageControl */
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        UIPageControl *pageCtrl = [[UIPageControl alloc] init];
        /** 自动以可视界面分页 */
        scrollView.pagingEnabled = YES;
        /** 取消导航栏 */
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        /** 不可点击分页标签 */
        pageCtrl.enabled = NO;
        [self addSubview:scrollView];
        [self addSubview:pageCtrl];
        self.scrollView = scrollView;
        self.pageCtrl = pageCtrl;
        /** 分页栏标签 */
        self.pageCtrl.currentPageIndicatorTintColor = [UIColor redColor];
        self.pageCtrl.pageIndicatorTintColor = [UIColor colorWithWhite:0 alpha:0.5];
        // 单页不显示分页栏
        self.pageCtrl.hidesForSinglePage = YES;
        /** 当前控制器成为代理 */
        self.scrollView.delegate = self;
    }
    return self;
}

/** 初始化的同时设置滚动图片 */
- (instancetype)initWithImages:(NSArray<__kindof UIImage *> *)images {
    if (self = [super init]) {
        self.images = images;
    }
    return self;
}

+ (instancetype)pageViewWithImages:(NSArray<__kindof UIImage *> *)images {
    return [[self alloc] initWithImages:images];
}

#pragma mark - 设置分页标签图片
- (void)setPageCtrlWithCurrentPageImage:(UIImage *)CurrentPageImage otherPageImage:(UIImage *)otherPageImage {
    [self.pageCtrl setValue:CurrentPageImage forKeyPath:@"_currentPageImage"];
    [self.pageCtrl setValue:otherPageImage forKeyPath:@"_pageImage"];

}

#pragma mark - 设置数据
- (void)setImages:(NSArray *)images {
    _images = images;
    /** 当需要更换显示图片时,清空历史图片 */
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    /** 强制布局,若不做此操作,self.scrollView.frame.size.width将会没有值 */
    [self layoutIfNeeded];
    /** 图片轮播器占据整个控件 */
    CGFloat scrollW = self.scrollView.frame.size.width;
    CGFloat scrollH = self.scrollView.frame.size.height;
    /** 设置可拖拽最大范围,每张图片占据一整个可视界面,并额外增加两个界面的范围 */
    self.scrollView.contentSize = CGSizeMake((images.count + 2) * scrollW, scrollH);
    /** 分页标签数目与图片数目保持一致 */
    self.pageCtrl.numberOfPages = images.count;
    /** 利用循环一次将图片(imageView)作为子控件添加至图片轮播器中 */
    for (int i = 0; i < images.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:images[i]];
        /** 图片占据contentSize中间部分,首尾位置保留 */
        imageView.frame = CGRectMake((i + 1) *  scrollW, 0, scrollW, scrollH);
        [self.scrollView addSubview:imageView];
    }
    /** 单独添加最后一张图片并放置在首位 */
    UIImageView *firstImage = [[UIImageView alloc] initWithImage:images.lastObject];
    firstImage.frame = CGRectMake(0, 0, scrollW, scrollH);
    [self.scrollView addSubview:firstImage];
    /** 单独添加第一张图片并放置在末尾 */
    UIImageView *lastImage = [[UIImageView alloc] initWithImage:images.firstObject];
    lastImage.frame = CGRectMake(scrollW * (images.count + 1), 0, scrollW, scrollH);
    [self.scrollView addSubview:lastImage];
}

#pragma mark - 布局子控件
- (void)layoutSubviews {
    [super layoutSubviews];
    
    /** 图片轮播器占据整个控件 */
    CGFloat pageViewW = self.frame.size.width;
    CGFloat pageViewH = self.frame.size.height;
    self.scrollView.frame = CGRectMake(0, 0, pageViewW, pageViewH);
    /** 分页标签位于右下角 */
    self.pageCtrl.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *trailingLC = [NSLayoutConstraint constraintWithItem:self.pageCtrl attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
    NSLayoutConstraint *bottomLC = [NSLayoutConstraint constraintWithItem:self.pageCtrl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
    [self addConstraint:trailingLC];
    [self addConstraint:bottomLC];
}


#pragma mark - 代理方法
/** 当界面经过操作并停止减速后,根据当前的偏移量求出图片的索引,判断后使其偏移,达到循环效果 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    /** 根据偏移量得出当前界面显示的图片实际位置所对应的角标 */
    NSUInteger page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    if (self.timeInterval == 0) {
        return;
    } else {
        /** 当界面停止减速后,如果当前显示的图片为第0个元素(内容等同于第5个元素)的位置,则立即偏移至第5个元素的位置无动画效果 */
        if (page == 0) {
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width - self.scrollView.frame.size.width, 0)];
            /** 当界面停止减速后,如果当前显示的图片为第6个元素(内容等同于第1个元素),则立即偏移至第1个元素的位置,无动画效果 */
        } else if (page == self.images.count+ 1) {
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0)];
        }
    }
}
/** 根据当前界面的偏移位置修改pageCtrl的序号 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /** 根据偏移量求出序号 */
    int page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width + 0.5;
    /** 如果序号为第5个元素的图片(内容等同于第0个元素)时,序号为0 */
    if (page == self.images.count) {
        self.pageCtrl.currentPage = 0;
        /** 如果序号为第6个元素的图片时(等同于第1个元素),序号显示为1 */
    } else if (page == self.images.count + 1){
        self.pageCtrl.currentPage = 1;
        /** 正常情况下,序号等于当前的偏移量的x值/可视范围的宽度 */
    } else {
        self.pageCtrl.currentPage = page;
    }
}

/** 用户开始拖拽,停止计时器自动滚动 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

/** 用户停止拖拽,开启计时器自动滚动 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startWithTimeInterval:self.timeInterval];
}


#pragma mark - 计时器方法
/** 开启计时器--页面自动切换 */
- (void)startWithTimeInterval:(NSTimeInterval)timeInterval {
    self.timeInterval = timeInterval;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(changeToNextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/** 停止计时器--停止切换 */
- (void)stopTimer {
    [self.timer invalidate];
}

/** 切换至下一界面 */
- (void)changeToNextPage {
    /** 当可视界面展示的图片为传入进去的最后一张图时,更新计时器 */
    if ( self.scrollView.contentOffset.x / self.scrollView.frame.size.width == self.images.count) {
        [self updateTimer];
    }
    /** 切换至下一张图 */
    NSUInteger page = self.pageCtrl.currentPage + 1;
    [self.scrollView setContentOffset:CGPointMake(page * self.scrollView.frame.size.width, 0) animated:YES];
}

/** 更新计时器和使其无动画效果的偏移至第0个元素,并继续开启计时器 */
- (void)updateTimer {
    [self.timer invalidate];
    /** 进入此方法表示当前界面显示的图片为第5个元素(内容等同于第0个元素),故使其偏移至原点,无动画效果 */
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    /** 再次开启计时器,正常切换 */
    [self startWithTimeInterval:self.timeInterval];
}


@end
