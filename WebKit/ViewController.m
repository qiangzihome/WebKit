//
//  ViewController.m
//  WebKit
//
//  Created by liqiang on 5/19/15.
//  Copyright (c) 2015 liqiang. All rights reserved.
//

#import "ViewController.h"
@import WebKit;

@interface ViewController () <WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate>

@property (nonatomic, strong)WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    [self addUserScriptsToUserContentController:configuration.userContentController];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    
//    NSString *HTML = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
//    [self.webView loadHTMLString:HTML baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];

    NSURL *URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
    [self.view addSubview:self.webView];
    
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
}

#pragma make - WKScriptMessageHandler methods
#pragma make 接收JS
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    
}

#pragma make - WKUIDelegate methods
#pragma make web界面中有弹出确认框时调用
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    NSLog(@"%@", message);
}

#pragma make web界面中有弹出警告框时调用
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler
{
    NSLog(@"%@", message);
}

#pragma make web界面中有弹出输入框时调用
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *result))completionHandler
{
    NSLog(@"%@-----%@", prompt, defaultText);
}

#pragma mark - WKNavigationDelegate methods
#pragma mark 网页开始加载
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"didStartProvisionalNavigation");
}

#pragma mark 网页服务器响应后返回数据
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"didCommitNavigation");
}

#pragma mark 网页加载完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    // [self dismissViewControllerAnimated:YES completion:^{}];
    self.title = self.webView.title;
    NSLog(@"didFinishNavigation");
}

- (void)addUserScriptsToUserContentController:(WKUserContentController *)userContentController {
    WKUserScript *hideTableOfContentsScript = [[WKUserScript alloc] initWithSource:@"$.fn.fullpage.moveTo(3)" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [userContentController addUserScript:hideTableOfContentsScript];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
