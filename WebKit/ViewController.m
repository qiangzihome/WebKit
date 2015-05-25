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

//    NSURL *URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]];
//    NSURL *toURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@index.html", NSTemporaryDirectory()]];

//    NSFileManager *fileManager = [NSFileManager defaultManager];
////    BOOL isTrue = [fileManager copyItemAtURL:URL toURL:toURL error:nil]; // 拷贝文件
//    
//    NSURL *URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"www" ofType:@""]];
//    NSURL *toURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@www/", NSTemporaryDirectory()]];
//    
//    if(![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@www/index.html", NSTemporaryDirectory()]]) {
//        [fileManager moveItemAtURL:URL toURL:toURL error:nil]; // 拷贝目录
//    }
    
    [self copyFrom:[[NSBundle mainBundle] pathForResource:@"www" ofType:@""] to:[NSString stringWithFormat:@"%@www/", NSTemporaryDirectory()] error:nil];
    

    NSURL *HTMLURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@www/index.html", NSTemporaryDirectory()]];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:HTMLURL]];
    [self.view addSubview:self.webView];
    [self.view sendSubviewToBack:self.webView];

    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    
}


- (BOOL)copyFrom:(NSString*)src to:(NSString*)dest error:(NSError* __autoreleasing*)error
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:src]) {
        NSString* errorString = [NSString stringWithFormat:@"%@ file does not exist.", src];
        if (error != NULL) {
            (*error) = [NSError errorWithDomain:@"TestDomainTODO"
                                           code:1
                                       userInfo:[NSDictionary dictionaryWithObject:errorString
                                                                            forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }
    
    // generate unique filepath in temp directory
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    NSString* tempBackup = [[NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString*)uuidString] stringByAppendingPathExtension:@"bak"];
    CFRelease(uuidString);
    CFRelease(uuidRef);
    
    BOOL destExists = [fileManager fileExistsAtPath:dest];
    
    // backup the dest
    if (destExists && ![fileManager copyItemAtPath:dest toPath:tempBackup error:error]) {
        return NO;
    }
    
    // remove the dest
    if (destExists && ![fileManager removeItemAtPath:dest error:error]) {
        return NO;
    }
    
    // create path to dest
    if (!destExists && ![fileManager createDirectoryAtPath:[dest stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:error]) {
        return NO;
    }
    
    // copy src to dest
    if ([fileManager copyItemAtPath:src toPath:dest error:error]) {
        // success - cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup]) {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return YES;
    } else {
        // failure - we restore the temp backup file to dest
        [fileManager copyItemAtPath:tempBackup toPath:dest error:error];
        // cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup]) {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return NO;
    }
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

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
//decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
//{
//    NSLog(@"decidePolicyForNavigationAction");
//}

- (void)addUserScriptsToUserContentController:(WKUserContentController *)userContentController {
    WKUserScript *hideTableOfContentsScript = [[WKUserScript alloc] initWithSource:@"$.fn.fullpage.moveTo(3)" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [userContentController addUserScript:hideTableOfContentsScript];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
