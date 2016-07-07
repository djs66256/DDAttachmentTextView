//
//  DDTextAttachment.m
//

#import "DDTextAttachment.h"

@implementation DDTextAttachment

- (instancetype)init
{
    self = [super initWithData:[NSData data] ofType:@"application:x-data"];
    if (self) {
        
    }
    return self;
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    return nil;
}

@end
