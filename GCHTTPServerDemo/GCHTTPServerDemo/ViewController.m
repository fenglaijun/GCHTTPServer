//
//  ViewController.m
//  GCHTTPServerDemo
//
//  Created by 小疯子 on 16/2/25.
//  Copyright © 2016年 GC. All rights reserved.
//

#import "ViewController.h"
#import <GCHTTPServer/GCHTTPServer.h>

@interface ViewController () <UIAlertViewDelegate> {
    GCHTTPSocket *httpSocket;
    int setup;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;

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
}

- (void)loadWebView {
    __weak typeof(self) self_weak = self;
    __block NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8888/index.html"];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        html = [html stringByReplacingOccurrencesOfString:@"</html>" withString:@"</html>\n<script src=\"/localscript.js\"></script>"];
        [self_weak.webView loadHTMLString:html baseURL:url];
    }] resume];
}

@end
