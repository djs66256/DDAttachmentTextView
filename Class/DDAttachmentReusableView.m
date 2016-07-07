//
//  DDAttachmentReusableView.m
//

#import "DDAttachmentReusableView.h"

@implementation DDAttachmentReusableView

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40)];
    if (self) {
        _identifier = identifier;
    }
    return self;
}

@end
