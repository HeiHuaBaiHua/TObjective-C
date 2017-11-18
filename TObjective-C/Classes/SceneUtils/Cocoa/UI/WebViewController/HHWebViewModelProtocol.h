//
//  HHWebViewModelProtocol.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/10/23.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <Foundation/Foundation.h>

@protocol HHWebViewModelProtocol <WKScriptMessageHandler>

- (NSURLRequest *)request;
- (NSMutableArray *)jsFuncNames;

- (NSString *)javaScript;
- (void)addJavaScriptBuilder:(NSString *(^)(NSDictionary *json))javaScriptBuilder;
@end
