//
//  DDAttachmentTextView.m
//

#import "DDAttachmentTextView.h"
#import "DDAttachmentReusableView.h"
#import "DDAttachmentLayoutManager.h"
#import "DDTextAttachment.h"

@interface DDAttachmentTextView () <DDAttachmentLayoutManagerDelegate>

@property (strong, nonatomic) NSMutableDictionary *registerViewDictionary;
@property (strong, nonatomic) NSMutableSet *attachmentViews;

@end

@implementation DDAttachmentTextView
@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    DDAttachmentLayoutManager *layoutManager = [[DDAttachmentLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(frame.size.width, CGFLOAT_MAX)];
    textContainer.widthTracksTextView = YES;
    [layoutManager addTextContainer:textContainer];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:@""];
    [textStorage addLayoutManager:layoutManager];
    
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        self.keyboardType = UIKeyboardTypeDefault;
        
        layoutManager.attachmentDelegate = self;
        _registerViewDictionary = [NSMutableDictionary dictionary];
        _attachmentViews = [NSMutableSet set];
    }
    return self;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedText.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[DDTextAttachment class]]) {
            [self _calculateAttachmentBounds:value];
        }
    }];
    
    [super setAttributedText:attributedText];
}

- (void)layoutSubviews {
    [self _calculateAttachmentsBounds];
    [super layoutSubviews];
}

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
    
    CGFloat visiblePadding = 10;    // 让他稍微大一点，可以早一点载入
    CGRect visibleRect = CGRectOffset((CGRect){0, -visiblePadding, self.frame.size.width, self.frame.size.height+2 * visiblePadding},
                                      self.contentOffset.x,
                                      self.contentOffset.y);
    for (DDAttachmentReusableView *view in _attachmentViews) {
        if (view.superview) {
            if (!CGRectIntersectsRect(visibleRect, view.frame)) {
                [view removeFromSuperview];
            }
        }
    }
    NSRange range = [self.layoutManager glyphRangeForBoundingRect:CGRectMake(0, visibleRect.origin.y+self.textContainerInset.top, visibleRect.size.width, visibleRect.size.height) inTextContainer:self.textContainer];
    NSRange charRage = [self.layoutManager characterRangeForGlyphRange:range actualGlyphRange:nil];
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:charRage options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[DDTextAttachment class]]) {
            for (DDAttachmentReusableView *view in _attachmentViews) {
                if (view.superview && view.attachment == value) {
                    return ;
                }
            }
            [self.layoutManager invalidateDisplayForCharacterRange:range];
        }
    }];
}

- (void)registerClass:(Class)cls forAttachmentViewWithReuseIdentifier:(NSString *)identifier {
    _registerViewDictionary[identifier] = [NSValue valueWithPointer:(const void *)cls];
}

- (DDAttachmentReusableView *)dequeueReusableAttachmentViewWithIdentifier:(NSString *)identifier {
    for (DDAttachmentReusableView *view in _attachmentViews) {
        if (view.superview == nil) {
            if ([view.identifier isEqualToString:identifier]) {
                return view;
            }
        }
    }
    Class cls = [_registerViewDictionary[identifier] pointerValue];
    if ([cls isSubclassOfClass:[DDAttachmentReusableView class]]) {
        DDAttachmentReusableView *instance = [[cls alloc] initWithIdentifier:identifier];
        return instance;
    }
    return nil;
}

#pragma mark - UITextInput

- (void)insertText:(NSString *)text {
    NSArray *attachmentList = nil;
    if ([self _shouldChangeTextInRange:self.selectedRange replacementText:text attachmentList:&attachmentList]) {
        if (attachmentList.count > 0) [self _willDeleteAttachments:attachmentList];
        [super insertText:text];
        if (attachmentList.count > 0) [self _didDeleteAttachments:attachmentList];
    }
}

- (void)deleteBackward {
    if (self.selectedRange.location > 0 || self.selectedRange.length > 0) {
        NSArray *attachmentList = nil;
        NSRange range = self.selectedRange;
        if (self.selectedRange.length == 0) {
            range = NSMakeRange(self.selectedRange.location - 1, 1);
        }
        if ([self _shouldChangeTextInRange:range replacementText:@"" attachmentList:&attachmentList]) {
            if (attachmentList.count > 0) [self _willDeleteAttachments:attachmentList];
            if (attachmentList.count > 0) [self _invalidateAttachmentsInRange:range];
            [super deleteBackward];
            if (attachmentList.count > 0) [self _didDeleteAttachments:attachmentList];
        }
    }
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange {
    NSArray *attachmentList = nil;
    if ([self _shouldChangeTextInRange:self.selectedRange replacementText:markedText attachmentList:&attachmentList]) {
        if (attachmentList.count > 0) [self _willDeleteAttachments:attachmentList];
        if (attachmentList.count > 0) [self _invalidateAttachmentsInRange:self.selectedRange];
        [super setMarkedText:markedText selectedRange:selectedRange];
        if (attachmentList.count > 0) [self _didDeleteAttachments:attachmentList];
    }
}

// to fix ios8's bug
- (BOOL)keyboardInputShouldDelete:(UITextView *)textView {
    BOOL shouldDelete = YES;
    
    if ([UITextView instancesRespondToSelector:_cmd]) {
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextView *) = (BOOL (*)(id, SEL, UITextView *))[UITextView instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete) {
            BOOL isIos8 = ([[[UIDevice currentDevice] systemVersion] intValue] == 8);
            BOOL isLessThanIos8_3 = ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.3f);
            
            if (isIos8 && isLessThanIos8_3) {
                if (self.selectedRange.location > 0 || self.selectedRange.length > 0) {
                    NSArray *attachmentList = nil;
                    NSRange range = self.selectedRange;
                    if (self.selectedRange.length == 0) {
                        range = NSMakeRange(self.selectedRange.location - 1, 1);
                    }
                    shouldDelete = [self _shouldChangeTextInRange:range replacementText:@"" attachmentList:&attachmentList];
                }
            }
            
            if (shouldDelete) {
                shouldDelete = keyboardInputShouldDelete(self, _cmd, textView);
            }
        }
    }
    
    return shouldDelete;
}

#pragma mark - Action

- (void)paste:(id)sender {
    NSArray *attachmentList = nil;
    NSString *text = [UIPasteboard generalPasteboard].string;
    if ([self _shouldChangeTextInRange:self.selectedRange replacementText:text attachmentList:&attachmentList]) {
        if (attachmentList.count > 0) [self _willDeleteAttachments:attachmentList];
        [self replaceTextInRange:self.selectedRange withText:text];
        if (attachmentList.count > 0) [self _didDeleteAttachments:attachmentList];
    }
}

- (void)cut:(id)sender {
    // TODO:
}

//- (void)delete:(id)sender {
//
//}

- (void)setContentSize:(CGSize)contentSize {
    if (!CGSizeEqualToSize(self.contentSize, contentSize)) {
        [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.textStorage.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if ([value isKindOfClass:[DDTextAttachment class]]) {
                [self.layoutManager invalidateDisplayForCharacterRange:range];
            }
        }];
    }
    [super setContentSize:contentSize];
}

- (void)replaceTextInRange:(NSRange)range withText:(NSString *)text {
    [self _invalidateAttachmentsInRange:range];
    [self.textStorage beginEditing];
    [self.textStorage replaceCharactersInRange:range withString:text];
    self.selectedRange = NSMakeRange(self.textStorage.editedRange.location + self.textStorage.editedRange.length, 0);
    [self.textStorage endEditing];
}

- (void)replaceTextInRange:(NSRange)range withAttributeText:(NSAttributedString *)text {
    [self _invalidateAttachmentsInRange:range];
    [self.textStorage beginEditing];
    [self.textStorage replaceCharactersInRange:range withAttributedString:text];
    self.selectedRange = NSMakeRange(self.textStorage.editedRange.location + self.textStorage.editedRange.length, 0);
    [self.textStorage endEditing];
}

- (void)replaceStringInRange:(NSRange)range
              withAttachment:(DDTextAttachment *)attachment
{
    [self _invalidateAttachmentsInRange:range];
    [self.textStorage beginEditing];
    [self.textStorage replaceCharactersInRange:range
                          withAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    NSRange selectedRange = NSMakeRange(self.textStorage.editedRange.location + self.textStorage.editedRange.length, 0);
    [self.textStorage endEditing];
    self.selectedRange = selectedRange;
}

- (NSArray<DDTextAttachment *> *)attachmentsInRange:(NSRange)range {
    NSMutableArray<DDTextAttachment *> *attachmentList = [NSMutableArray new];
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:range options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[DDTextAttachment class]]) {
            [attachmentList addObject:value];
        }
    }];
    return attachmentList;
}

- (void)insertAttachment:(DDTextAttachment *)attachment {
    [self _calculateAttachmentBounds:attachment];
    
    NSMutableAttributedString *string = [NSAttributedString attributedStringWithAttachment:attachment].mutableCopy;
    UITextPosition *position = [self positionFromPosition:self.beginningOfDocument offset:self.selectedRange.location];
    NSDictionary *attr = [self textStylingAtPosition:position inDirection:UITextStorageDirectionBackward];
    [string addAttributes:attr range:NSMakeRange(0, string.length)];
    
    [self.textStorage beginEditing];
    [self.textStorage replaceCharactersInRange:self.selectedRange withAttributedString:string];
    NSRange range = NSMakeRange(self.textStorage.editedRange.location+self.textStorage.editedRange.length, 0);
    [self.textStorage endEditing];
    self.selectedRange = range;
}

#pragma mark - Private

- (void)_willDeleteAttachments:(NSArray<DDTextAttachment *> *)attachments {
    if ([self.delegate respondsToSelector:@selector(textView:willDeleteAttachments:)]) {
        [self.delegate textView:self willDeleteAttachments:attachments];
    }
}

- (void)_didDeleteAttachments:(NSArray<DDTextAttachment *> *)attachments {
    if ([self.delegate respondsToSelector:@selector(textView:didDeleteAttachments:)]) {
        [self.delegate textView:self didDeleteAttachments:attachments];
    }
}

- (BOOL)_shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text attachmentList:(NSArray * __autoreleasing *)attachments {
    if (range.length > 0) {
        NSArray<DDTextAttachment *> *attachmentList = [self attachmentsInRange:range];
        *attachments = attachmentList;
        
        if (attachmentList.count > 0 && [self.delegate respondsToSelector:@selector(textView:shouldChangeAttachments:andTextInRange:replacementText:)]) {
            return [self.delegate textView:self
                   shouldChangeAttachments:attachmentList
                            andTextInRange:range
                           replacementText:text];
        }
    }
    return YES;
}

- (void)_invalidateAttachmentsInRange:(NSRange)range {
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:range options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[DDTextAttachment class]]) {
            DDAttachmentReusableView *view = [self _reusableAttachmentViewForAttachment:value];
            if (view) {
                [self.layoutManager invalidateDisplayForCharacterRange:range];
                [view removeFromSuperview];
            }
        }
    }];
}

- (DDAttachmentReusableView *)_reusableAttachmentViewForAttachment:(DDTextAttachment *)attachment {
    for (DDAttachmentReusableView *view in _attachmentViews) {
        if (view.attachment == attachment && view.superview) {
            return view;
        }
    }
    return nil;
}

- (void)_calculateAttachmentsBounds {
    if (self.textStorage.length > 0) {
        NSArray *attachments = [self attachmentsInRange:NSMakeRange(0, self.textStorage.length)];
        for (DDTextAttachment *attachment in attachments) {
            [self _calculateAttachmentBounds:attachment];
        }
    }
}

- (void)_calculateAttachmentBounds:(DDTextAttachment *)attachment {
    if (attachment.fillWidth) {
        attachment.bounds = CGRectMake(0,
                                       0,
                                       self.textContainer.size.width - 2 * self.textContainer.lineFragmentPadding,
                                       attachment.size.height + attachment.contentInset.bottom + attachment.contentInset.top);
    }
    else {
        attachment.bounds = CGRectMake(0,
                                       0,
                                       attachment.size.width + attachment.contentInset.left + attachment.contentInset.right,
                                       attachment.size.height+ attachment.contentInset.bottom + attachment.contentInset.top);
    }
}

#pragma mark - DDAttachmentLayoutManagerDelegate
- (UIView *)attachmentLayoutManager:(DDAttachmentLayoutManager *)manager viewForAttachment:(DDTextAttachment *)attachment {
    for (DDAttachmentReusableView *view in _attachmentViews) {
        if (view.superview && view.attachment == attachment) {
            return view;
        }
    }
    
    DDAttachmentReusableView *view = [self.delegate textView:self attachmentViewWithAttachment:attachment];
    NSAssert(view, @"attachment view can not be nil value");
    
    view.attachment = attachment;
    [_attachmentViews addObject:view];
    [self addSubview:view];
    return view;
}

@end
