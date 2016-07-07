//
//  DDImageAttachmentView.m
//

#import "DDImageAttachmentView.h"

@implementation DDImageAttachmentView

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super initWithIdentifier:identifier];
    if (self) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.frame = self.bounds;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView];
    }
    return self;
}

@end
