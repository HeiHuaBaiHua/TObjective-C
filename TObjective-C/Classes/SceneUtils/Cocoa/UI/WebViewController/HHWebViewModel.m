//
//  HHWebViewModel.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/10/23.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"
#import "HHWebViewModel.h"

#import "NSUserDefaults+Extension.h"
@interface HHWebViewModel ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSMutableArray *jsFuncNames;

@property (nonatomic, copy) NSString *javaScript;
@property (nonatomic, strong) NSMutableArray<NSString *(^)(NSDictionary *json)> *javaScriptBuilders;
@end

@implementation HHWebViewModel

- (instancetype)initWithURL:(NSString *)url {
    if (self = [super init]) {
        
        self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        self.jsFuncNames = @[@"getToken",
                             @"copyToClipboard"].mutableCopy;
        self.javaScriptBuilders = [NSMutableArray array];
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![self.jsFuncNames containsObject:message.name] ||
        ![message.body isKindOfClass:[NSDictionary class]]) { return; }
    
    NSString *callbackName = message.body[@"callback"];
    NSString *javeScript;
    if ([message.name isEqualToString:@"getToken"]) {
        
        NSString *token = SharedUserDefaults.token ?: @"";
        NSString *jsonString = [@{@"result": token} javascriptEncodedString];
        javeScript = [NSString stringWithFormat:@"%@(%@)",callbackName, jsonString];
    } else if ([message.name isEqualToString:@"copyToClipboard"]) {
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = message.body[@"body"];
        NSString *jsonString = [@{@"result": @"1"} javascriptEncodedString];
        javeScript = [NSString stringWithFormat:@"%@(%@)",callbackName, jsonString];
    }
    if (javeScript.length == 0) {
        for (NSString *(^builder)(NSDictionary *) in self.javaScriptBuilders) {
            javeScript = builder(message.body);
            if (javeScript.length > 0) { break; }
        }
    }
    self.javaScript = javeScript;
}

- (void)addJavaScriptBuilder:(NSString *(^)(NSDictionary *json))builder {
    if (builder == nil) { return; }
    [self.javaScriptBuilders addObject:builder];
}

@end
