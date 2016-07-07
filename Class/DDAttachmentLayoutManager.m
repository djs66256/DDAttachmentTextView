//
//  DDAttachmentLayoutManager.m
//

#import "DDAttachmentLayoutManager.h"
#import "DDTextAttachment.h"

@implementation DDAttachmentLayoutManager

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow
                        atPoint:(CGPoint)origin
{
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
    
    NSUInteger start = [self characterIndexForGlyphAtIndex:glyphsToShow.location];
    NSUInteger end = [self characterIndexForGlyphAtIndex:glyphsToShow.location + glyphsToShow.length];
    
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:NSMakeRange(start, end - start)
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired | NSAttributedStringEnumerationReverse
                              usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                                  DDTextAttachment *attachment = (DDTextAttachment *)value;
                                  if ([attachment isKindOfClass:[DDTextAttachment class]]) {
                                      NSUInteger glyphIndex = [self glyphIndexForCharacterAtIndex:range.location];
                                      CGRect rect = [self boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1)
                                                                    inTextContainer:[self textContainerForGlyphAtIndex:glyphIndex
                                                                                                        effectiveRange:NULL]];
                                      UIView *attachmentView = [self.attachmentDelegate attachmentLayoutManager:self viewForAttachment:attachment];
                                      attachmentView.frame = CGRectMake(origin.x + rect.origin.x + attachment.contentInset.left,
                                                                        origin.y + rect.origin.y + attachment.contentInset.top,
                                                                        rect.size.width - attachment.contentInset.left - attachment.contentInset.right,
                                                                        attachment.size.height);
                                      attachmentView.hidden = NO;
                                  }
                              }];
}

@end
