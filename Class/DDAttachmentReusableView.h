//
//  DDAttachmentReusableView.h
//

#import <UIKit/UIKit.h>

@class DDTextAttachment;
@interface DDAttachmentReusableView : UIView

@property (copy, readonly, nonatomic) NSString *identifier;
@property (strong, nonatomic) DDTextAttachment *attachment;

- (instancetype)initWithIdentifier:(NSString *)identifier;

@end
