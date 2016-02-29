//
//  ViewController.m
//  GCHTTPServerDemo
//
//  Created by 小疯子 on 16/2/25.
//  Copyright © 2016年 GC. All rights reserved.
//

#import "ViewController.h"
#import <GCHTTPServer/GCHTTPServer.h>

@interface ViewController () {
    GCHTTPSocket *httpSocket;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    httpSocket = [[GCHTTPSocket alloc] init];
    [httpSocket startServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
