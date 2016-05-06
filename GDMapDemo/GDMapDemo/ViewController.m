//
//  ViewController.m
//  GDMapDemo
//
//  Created by wanghao on 16/5/6.
//  Copyright © 2016年 wanghao. All rights reserved.
//

#import "ViewController.h"
#import "MapViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)jumpToMap:(id)sender {
    
    MapViewController *mapVC = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
    
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:mapVC];
    
    [self presentViewController:navC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
