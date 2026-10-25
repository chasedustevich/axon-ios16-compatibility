#import "AXNRequestWrapper.h"

@implementation AXNRequestWrapper

+(AXNRequestWrapper *)wrapRequest:(NCNotificationRequest *)request {
    if (!request || ![request notificationIdentifier]) return nil;
    AXNRequestWrapper *wrapped = [[AXNRequestWrapper alloc] init];
    wrapped.request = [request copy];
    wrapped.notificationIdentifier = [[wrapped.request notificationIdentifier] copy];
    return wrapped;
}

@end