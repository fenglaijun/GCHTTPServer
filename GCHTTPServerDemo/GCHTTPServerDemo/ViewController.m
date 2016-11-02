//
//  ViewController.m
//  GCHTTPServerDemo
//
//  Created by 小疯子 on 16/2/25.
//  Copyright © 2016年 GC. All rights reserved.
//

#import "ViewController.h"
#import <GCHTTPServer/GCHTTPServer.h>
#import "GCObject.h"

@interface ViewController () <UIAlertViewDelegate> {
    GCHTTPSocket *httpSocket;
    int setup;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic,retain) GCObject *gcobj;
@property (nonatomic,retain) GCObject *newobj;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    httpSocket = [[GCHTTPSocket alloc] init];
    httpSocket.rootPath = [[NSBundle mainBundle] pathForResource:@"WebResource.bundle" ofType:nil];
    [httpSocket startServer];
    [self performSelector:@selector(loadWebView) withObject:nil afterDelay:5];
    [self.view bringSubviewToFront:self.webView];
    [self groupQueue];
}

- (void)groupQueue {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:3];
        DLogWarn(@"queue1");
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:2];
        DLogWarn(@"queue2");
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:1];
        DLogWarn(@"queue3");
    });
    dispatch_group_notify(group, queue, ^{
        DLogWarn(@"group success.");
    });
}

- (void)loadWebView {
    __weak typeof(self) self_weak = self;
    __block NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8888/index.html"];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self_weak.webView loadHTMLString:html baseURL:url];
    }] resume];
}

- (IBAction)setObjectNil:(id)sender {
    _gcobj = nil;
}
@end
