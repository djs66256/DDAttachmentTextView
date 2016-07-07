//
//  DDAttachmentTextView.h
//

#import <UIKit/UIKit.h>

@class DDTextAttachment, DDAttachmentReusableView;
@protocol DDAttachmentTextViewDelegate;
@interface DDAttachmentTextView : UITextView

@property (weak, nonatomic) id<UITextViewDelegate, DDAttachmentTextViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (NSArray<DDTextAttachment *> *)attachmentsInRange:(NSRange)range;
- (void)insertAttachment:(DDTextAttachment *)attachment;
- (void)replaceTextInRange:(NSRange)range withText:(NSString *)text;
- (void)replaceTextInRange:(NSRange)range withAttributeText:(NSAttributedString *)text;

- (void)registerClass:(Class)cls forAttachmentViewWithReuseIdentifier:(NSString *)identifier;
- (__kindof DDAttachmentReusableView *)dequeueReusableAttachmentViewWithIdentifier:(NSString *)identifier;

@end

@protocol DDAttachmentTextViewDelegate <UITextViewDelegate>

- (DDAttachmentReusableView *)textView:(DDAttachmentTextView *)textView attachmentViewWithAttachment:(DDTextAttachment *)attachment;

@optional
- (BOOL)textView:(DDAttachmentTextView *)textView shouldChangeAttachments:(NSArray<DDTextAttachment *> *)attachments andTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textView:(DDAttachmentTextView *)textView willDeleteAttachments:(NSArray<DDTextAttachment *> *)attachments;
- (void)textView:(DDAttachmentTextView *)textView didDeleteAttachments:(NSArray<DDTextAttachment *> *)attachments;

@end
