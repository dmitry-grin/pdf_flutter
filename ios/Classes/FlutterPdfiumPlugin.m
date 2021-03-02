#import "FlutterPdfiumPlugin.h"
#if __has_include(<flutter_pdfium/flutter_pdfium-Swift.h>)
#import <flutter_pdfium/flutter_pdfium-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_pdfium-Swift.h"
#endif

@implementation FlutterPdfiumPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPdfiumPlugin registerWithRegistrar:registrar];
}
@end
