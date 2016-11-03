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
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    httpSocket = [[GCHTTPSocket alloc] init];
    httpSocket.port = 8888;
    //NSArray<NSString *> *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, NO);
    httpSocket.rootPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/COHTTPServer"];
    [httpSocket startServer];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
