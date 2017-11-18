//
//  HHWebViewBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/10/23.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#define Debug 0

#if Debug
# define WebLog(...) NSLog(__VA_ARGS__)
#else
# define WebLog(...) {}
#endif

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HHFoundation.h"
#import "HHWebViewBinder.h"

@interface HHWebViewBinder ()<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *backItem;

@property (nonatomic, strong) id<HHWebViewModelProtocol> viewModel;

@end

@implementation HHWebViewBinder

- (void)dealloc {
    
    for (NSString *jsFuncName in self.viewModel.jsFuncNames) {
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:jsFuncName];
    }
}

- (void)bindViewModel:(id<HHWebViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
    
    ((UIButton *)self.backItem.customView).rac_command = [self backCommand];
    
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    for (NSString *jsFuncName in viewModel.jsFuncNames) {
        [self.webView.configuration.userContentController addScriptMessageHandler:self.viewModel name:jsFuncName];
    }
    
    @weakify(self);
    [[RACObserve(self.viewModel, javaScript) ignore:nil] subscribeNext:^(NSString *javaScript) {
        @strongify(self);
        [self executeJavaScript:javaScript];
    }];
    [self refreshData];
}

- (void)executeJavaScript:(NSString *)javaScript {
    
    [self.webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        WebLog(@"xxx: %@----%@",result, error);
    }];
}

- (RACCommand *)backCommand {
    @weakify(self);
    return [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        if (self.webView.canGoBack) {
            [self.webView goBack];
        } else {
            [self.webView.navigationController popViewControllerAnimated:YES];
        }
        return [RACSignal empty];
    }];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    WebLog(@"---------网页准备加载----------");
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    WebLog(@"---------网页loading----------");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    WebLog(@"---------网页加载完成----------");
    if (webView.title.length == 0) {/** 大内存网页存在单次加载白屏的问题 */
        dispatch_async(dispatch_get_main_queue(), ^{
            [webView reload];
        });
    }
    [self.webView hideHUD];
}

- (void)webView:(WKWebView *)webView didFailLoadWithError:(nonnull NSError *)error{
    WebLog(@"---------网页加载失败---------- %@", error);
    [self.webView hideHUD];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    WebLog(@"---------网页加载失败---------- %@", error);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    WebLog(@"---------网页加载失败---------- %@", error);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];/** 大内存网页存在单次加载白屏的问题 */
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *scheme = [navigationAction.request.URL absoluteString];
    if ([scheme isEqualToString:@"haleyaction"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    [webView showAlertWithTitle:nil message:message confirmHandler:^(UIAlertAction *confirmAction) {
        completionHandler();
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:0 handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:0 handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [webView showAlertWithTitle:nil message:message cancelAction:cancelAction confirmAction:confirmAction];
}

#pragma mark - Utils

- (void)refreshData {
    
    [self.webView showHUD];
    [self.webView loadRequest:self.viewModel.request];
}

#pragma mark - Getter

- (WKWebView *)webView {
    if (!_webView) {
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [WKUserContentController new];
        configuration.preferences = preferences;
        
        _webView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:configuration];
        _webView.opaque = NO;
        _webView.backgroundColor = [UIColor clearColor];
    }
    return _webView;
}

- (UIBarButtonItem *)backItem {
    if (!_backItem) {
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 44, 44);
        backButton.backgroundColor = [UIColor clearColor];
        backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        backButton.image = @"UI_backIcon".image;
        _backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _backItem;
}

@end
