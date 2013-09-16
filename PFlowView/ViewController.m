//
//  ViewController.m
//  PFlowView
//
//  Created by JK.Peng on 13-9-12.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "ViewController.h"
#import "PFlowView.h"
#import "CustomPFlowViewCell.h"

@interface ViewController ()<PFlowViewDataSource,PFlowViewDelegate>

@property (nonatomic, retain) PFlowView   *flowView;

@property (nonatomic, retain) NSMutableArray    *dataArray;
@end

@implementation ViewController
@synthesize flowView = _flowView;
@synthesize dataArray = _dataArray;

- (void)dealloc{
    self.flowView.delegate = nil;
    self.flowView.dataSource = nil;
    self.flowView = nil;
    self.dataArray = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:243.0f/255.0f
                                                green:243.0f/255.0f
                                                 blue:243.0f/255.0f
                                                alpha:1.0f];
    self.navigationItem.title = @"图片浏览";
    
    self.dataArray = [NSMutableArray arrayWithCapacity:5];
    [self.dataArray addObject:@"http://e.hiphotos.baidu.com/pic/w%3D230/sign=8eb4edf74afbfbeddc59317c48f1f78e/e824b899a9014c08ba1d546d0b7b02087af4f4d0.jpg"];
    [self.dataArray addObject:@"http://g.hiphotos.baidu.com/pic/w%3D230/sign=c22f159835a85edffa8cf920795509d8/cc11728b4710b912b6e28a36c2fdfc03934522d2.jpg"];
    [self.dataArray addObject:@"http://b.hiphotos.baidu.com/pic/w%3D230/sign=248a1d03b3fb43161a1f7d7910a64642/342ac65c10385343e215fae99213b07ecb80881b.jpg"];
    [self.dataArray addObject:@"http://h.hiphotos.baidu.com/pic/w%3D230/sign=fb5edd16f11f3a295ac8d2cda924bce3/c83d70cf3bc79f3d8fd698f8bba1cd11738b29c6.jpg"];
    [self.dataArray addObject:@"http://h.hiphotos.baidu.com/pic/w%3D230/sign=5c1b42bef31fbe091c5ec4175b620c30/ac345982b2b7d0a22b247955caef76094a369a0c.jpg"];
    [self.dataArray addObject:@"http://a.hiphotos.baidu.com/pic/w%3D230/sign=84fa9faf96dda144da096bb182b6d009/95eef01f3a292df568d397a9bd315c6034a8737d.jpg"];
    [self.dataArray addObject:@"http://e.hiphotos.baidu.com/pic/w%3D230/sign=bb24c7b171cf3bc7e800caefe101babd/43a7d933c895d1437166df9f72f082025aaf077d.jpg"];
    [self.dataArray addObject:@"http://b.hiphotos.baidu.com/pic/w%3D230/sign=9d073c21caef76093c0b9e9c1edca301/35a85edf8db1cb13d8a704afdc54564e93584bbb.jpg"];
    

    [self.view addSubview:self.flowView];
    
    [self.flowView reloadData];
}

#pragma mark - PFlowViewDataSource
- (NSInteger)numberOfItemsInPFlowView:(PFlowView *)pFlowView
{
    return [self.dataArray count];
}
- (PFlowViewCell *)pFlowView:(PFlowView *)pFlowView cellForItemAtIndex:(NSInteger)index
{
    CustomPFlowViewCell  *cell = (CustomPFlowViewCell *)[pFlowView dequeueReusableCell];
    if (!cell) {
        cell = [[CustomPFlowViewCell alloc] initWithFrame:CGRectMake(0, 0, 250, 340)];
    }

    cell.urlStr = [self.dataArray objectAtIndex:index];
    
    return cell;
}

#pragma mark - PFlowViewDelegate
- (void)pFlowView:(PFlowView *)pFlowView didSelectItemAtIndex:(NSInteger)index
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:[NSString stringWithFormat:@"您当前点击的为第　%d　号图片",index]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    [alert show];
}


#pragma mark - getter
- (PFlowView *)flowView{
    if (!_flowView) {
        _flowView = [[PFlowView alloc] initWithFrame:CGRectMake(20, 40, 250, 340)];
        _flowView.dataSource = self;
        _flowView.delegate = self;
    }
    return _flowView;
}


@end
