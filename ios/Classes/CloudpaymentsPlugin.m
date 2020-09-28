#import "CloudpaymentsPlugin.h"
#if __has_include(<cloudpayments/cloudpayments-Swift.h>)
#import <cloudpayments/cloudpayments-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "cloudpayments-Swift.h"
#endif

@implementation CloudpaymentsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCloudpaymentsPlugin registerWithRegistrar:registrar];
}
@end
