//
//  AppDelegate.m
//  CODemoMacOS
//
//  Created by vmpc on 16/11/3.
//  Copyright © 2016年 maintoco. All rights reserved.
//

#import "AppDelegate.h"
#import <COAsyncSocket/COAsyncSocket.h>

@interface AppDelegate () {
    GCHTTPSocket *httpSocket;
}

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *txtPort;
@property (weak) IBOutlet NSButton *btnApply;
@property (weak) IBOutlet NSButton *btnStart;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    httpSocket = [[GCHTTPSocket alloc] init];
    httpSocket.port = 28000;
    //NSArray<NSString *> *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, NO);
    httpSocket.rootPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/COHTTPServer"];
    [httpSocket startServer];
    _txtPort.intValue = httpSocket.port;
    
    NSString *serverURL = [NSString stringWithFormat:@"http://192.168.0.102:%d",httpSocket.port];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:serverURL]];
    
    self.window.title = [@"running " stringByAppendingString:serverURL];
}


/**
 重启HTTP服务

 @param sender NSButton
 */
- (IBAction)resetServer:(id)sender {
    [httpSocket stop];
    httpSocket.port = _txtPort.intValue;
    [httpSocket startServer];
}
- (IBAction)startServer:(id)sender {
    if ([_btnStart.title isEqualToString:@"启动"]) {
        _btnStart.title = @"停止";
        [httpSocket startServer];
    }else {
        _btnStart.title = @"启动";
        [httpSocket stop];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
