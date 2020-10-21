#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

extern NSString * const  POST_BACK_URL;

@protocol D3DSDelegate
@required
-(void) authorizationCompletedWithMD: (NSString *) md andPares: (NSString *) paRes;
-(void) authorizationFailedWithHtml: (NSString *) html;
@end

@interface D3DS : NSObject <WKNavigationDelegate>
{
    UIViewController *controller;
    id <D3DSDelegate> delegate;
    WKWebView *webView;
}
-(void) make3DSPaymentWithUIViewController: (UIViewController *) viewController andD3DSDelegate:(id <D3DSDelegate>) d3dsDelegate andAcsURLString: (NSString *) acsUrlString andPaReqString: (NSString *) paReqString andTransactionIdString: (NSString *) transactionIdString;

@end
