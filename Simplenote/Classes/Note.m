//
//  Note.m
//
//  Created by Michael Johnston on 01/07/08.
//  Copyright 2008 Simperium. All rights reserved.
//

#import "Note.h"
#import "NSString+Condensing.h"
#import "NSString+Metadata.h"
#import "JSONKit+Simplenote.h"


@interface Note (PrimitiveAccessors)
- (NSString *)primitiveContent;
- (void)setPrimitiveContent:(NSString *)newContent;
@end

@implementation Note

@synthesize creationDatePreview;
@synthesize modificationDatePreview;
@synthesize titlePreview;
@synthesize bodyPreview;
@synthesize tagsArray;
@synthesize emailTagsArray;
@dynamic content;
@dynamic creationDate;
@dynamic deleted;
@dynamic lastPosition;
@dynamic modificationDate;
@dynamic publishURL;
@dynamic shareURL;
@dynamic systemTags;
@dynamic tags;
@dynamic pinned;
@dynamic markdown;

static NSDateFormatter *dateFormatterTime = nil;
static NSDateFormatter *dateFormatterMonthDay = nil;
static NSDateFormatter *dateFormatterMonthYear = nil;
static NSDateFormatter *dateFormatterMonthDayYear = nil;
static NSDateFormatter *dateFormatterMonthDayTime = nil;
static NSDateFormatter *dateFormatterNumbers = nil;
static NSCalendar *gregorian = nil;
NSObject *notifyObject;
SEL notifySelector;


- (void) awakeFromFetch {
    [super awakeFromFetch];
    [self createPreview];
    [self updateTagsArray];
    [self updateEmailTagsArray];
    [self updateSystemTagsArray];
    [self updateSystemTagFlags];
}

- (void) awakeFromInsert {
    [super awakeFromInsert];
    
    self.content = @"";
    self.publishURL = @"";
    self.shareURL = @"";
    self.creationDate = [NSDate date];
    self.modificationDate = [NSDate date];
    self.tags = @"[]";
    self.systemTags = @"[]";
    [self updateSystemTagsArray];
    [self updateTagsArray];
    [self updateEmailTagsArray];

}

- (void)didTurnIntoFault {
    [super didTurnIntoFault];
}

#pragma mark Properties
// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

- (NSString *)localID {
    NSManagedObjectID *key = [self objectID];
    if ([key isTemporaryID])
        return nil;
    return [[key URIRepresentation] absoluteString];
}

- (NSComparisonResult)compareModificationDate:(Note *)note {
	if (pinned && !note.pinned)
        return NSOrderedAscending;
	else if (!pinned && note.pinned)
        return NSOrderedDescending;
	//else if (pinned < note.pinned) return NSOrderedDescending;
	return [note.modificationDate compare:self.modificationDate];
}
- (NSComparisonResult)compareModificationDateReverse:(Note *)note {
	if (pinned && !note.pinned)
        return NSOrderedAscending;
	else if (!pinned && note.pinned)
        return NSOrderedDescending;
	//else if (pinned < note.pinned) return NSOrderedDescending;
	return [self.modificationDate compare:note.modificationDate];
}

- (NSComparisonResult)compareCreationDate:(Note *)note {
	if (pinned && !note.pinned)
        return NSOrderedAscending;
	else if (!pinned && note.pinned) return NSOrderedDescending;
	//else if (pinned < note.pinned) return NSOrderedDescending;
	return [note.creationDate compare:self.creationDate];
}

- (NSComparisonResult)compareCreationDateReverse:(Note *)note {
	if (pinned && !note.pinned)
        return NSOrderedAscending;
	else if (!pinned && note.pinned)
        return NSOrderedDescending;
	//else if (pinned < note.pinned) return NSOrderedDescending;
	return [self.creationDate compare:note.creationDate];
}

- (NSComparisonResult)compareAlpha:(Note *)note {
	if (pinned && !note.pinned)
        return NSOrderedAscending;
	else if (!pinned && note.pinned)
        return NSOrderedDescending;
	//else if (pinned < note.pinned) return NSOrderedDescending;
	return [self.content caseInsensitiveCompare:note.content];
}

- (NSComparisonResult)compareAlphaReverse:(Note *)note {
	if (pinned && !note.pinned)
        return NSOrderedAscending;
	else if (!pinned && note.pinned)
        return NSOrderedDescending;
	//else if (pinned < note.pinned) return NSOrderedDescending;
	return [note.content caseInsensitiveCompare:self.content];
}


- (BOOL)deleted {
    BOOL b;
    [self willAccessValueForKey:@"deleted"];
    b = deleted;
    [self didAccessValueForKey:@"deleted"];
    
	return b;
}

- (void)setDeleted:(BOOL) b {
	if (b == deleted) return;
    
    [self willChangeValueForKey:@"deleted"];
    deleted = b;
    [self didChangeValueForKey:@"deleted"];
}

- (BOOL)shared {
	return shared;//[self hasSystemTag:@"shared"];
}

- (void)setShared:(BOOL) bShared {
	if (bShared) [self addSystemTag:@"shared"]; else [self stripSystemTag:@"shared"];
	shared = bShared;
}

- (BOOL)published {
	return published;//[self hasSystemTag:@"published"];
}

- (void)setPublished:(BOOL) bPublished {
	if (bPublished) [self addSystemTag:@"published"]; else [self stripSystemTag:@"published"];
	published = bPublished;
}

- (BOOL)unread {
	return unread;// [self hasSystemTag:@"published"];
}

- (void)setUnread:(BOOL) bUnread {
	if (bUnread) [self addSystemTag:@"unread"]; else [self stripSystemTag:@"unread"];
	unread = bUnread;
}

- (void)setTags:(NSString *)newTags {
    if ((!tags && !newTags) || (tags && newTags && [tags isEqualToString:newTags])) return;
    
    [self willChangeValueForKey:@"tags"];
    NSString *newString = [newTags copy];
    [self setPrimitiveValue:newString forKey:@"tags"]; 
    [self updateTagsArray];
    [self updateEmailTagsArray];
    [self didChangeValueForKey:@"tags"];
}

// Maintain flags for performance purposes
- (void)updateSystemTagFlags {
	pinned = [self hasSystemTag:@"pinned"];
	shared = [self hasSystemTag:@"shared"];
	published = [self hasSystemTag:@"published"];
	unread = [self hasSystemTag:@"unread"];
    markdown = [self hasSystemTag:@"markdown"];
}

- (void)setSystemTags:(NSString *)newTags {
    if ((!systemTags && !newTags) || (systemTags && newTags && [systemTags isEqualToString:newTags])) return;
    
    [self willChangeValueForKey:@"systemTags"];
    NSString *newString = [newTags copy];
    [self setPrimitiveValue:newString forKey:@"systemTags"]; 
    [self updateSystemTagsArray];
	[self updateSystemTagFlags];
    [self didChangeValueForKey:@"systemTags"];    
}

- (void)ensurePreviewStringsAreAvailable
{
    if (self.titlePreview != nil) {
        return;
    }

    [self createPreview];
}

- (void)createPreview
{
    NSString *aString = self.content;
    if (aString.length > 500) {
        aString = [aString substringToIndex:500];
    }
    
    [aString generatePreviewStrings:^(NSString *title, NSString *body) {
        self.titlePreview = title;
        self.bodyPreview = body;
    }];

    if (self.titlePreview.length == 0) {
        self.titlePreview = NSLocalizedString(@"New note...", @"Empty Note Placeholder");
        self.bodyPreview = nil;
    }
    
    [self updateTagsArray];
    [self updateEmailTagsArray];
}

- (BOOL)pinned {
    BOOL b;
    [self willAccessValueForKey:@"pinned"];
    b = pinned;
    [self didAccessValueForKey:@"pinned"];
    
	return b;
}

- (void)setPinned:(BOOL) bPinned {
	if (bPinned) [self addSystemTag:@"pinned"]; else [self stripSystemTag:@"pinned"];
    [self willChangeValueForKey:@"pinned"];
	pinned = bPinned;
    [self didChangeValueForKey:@"pinned"];
}

- (BOOL)markdown {
    BOOL b;
    [self willAccessValueForKey:@"markdown"];
    b = markdown;
    [self didAccessValueForKey:@"markdown"];
    
	return b;
}

- (void)setMarkdown:(BOOL) bMarkdown {
	if (bMarkdown) [self addSystemTag:@"markdown"]; else [self stripSystemTag:@"markdown"];
    [self willChangeValueForKey:@"markdown"];
	markdown = bMarkdown;
    [self didChangeValueForKey:@"markdown"];
}

- (int)lastPosition {
    int i;
    [self willAccessValueForKey:@"lastPosition"];
    i = lastPosition;
    [self didAccessValueForKey:@"lastPosition"];
    
	return i;
}

- (void)setLastPosition:(int) newLastPosition {
	if (lastPosition == newLastPosition) return;
    
    [self willChangeValueForKey:@"lastPosition"];
	lastPosition = newLastPosition;
    [self didChangeValueForKey:@"lastPosition"];
}

- (void)setShareURL:(NSString *)url {
    if ((!shareURL && !url) || (shareURL && url && [shareURL isEqualToString:url])) return;
    
    [self willChangeValueForKey:@"shareURL"];
    NSString *newString = [url copy];
    [self setPrimitiveValue:newString forKey:@"shareURL"]; 
    [self didChangeValueForKey:@"shareURL"];
}

- (void)setPublishURL:(NSString *)url {
    if ((!publishURL && !url) || (publishURL && url && [publishURL isEqualToString:url])) return;
    
    [self willChangeValueForKey:@"publishURL"];
    NSString *newString = [url copy];
    [self setPrimitiveValue:newString forKey:@"publishURL"]; 
    [self didChangeValueForKey:@"publishURL"];
}

- (NSString *)dateString:(NSDate *)date brief:(BOOL)brief {
	if (!gregorian) {
		gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
		dateFormatterTime = [NSDateFormatter new];
		[dateFormatterTime setTimeStyle: NSDateFormatterShortStyle];
		//[dateFormatterTime setDateFormat:@"h:mm a"];
		dateFormatterMonthDay = [NSDateFormatter new];
		[dateFormatterMonthDay setDateFormat:NSLocalizedString(@"MMM d", @"Month and day date formatter")];
//		[dateFormatterMonthDay setTimeStyle: kCFDateFormatterNoStyle];
//		[dateFormatterMonthDay setDateStyle: kCFDateFormatterMediumStyle];
		dateFormatterMonthYear = [NSDateFormatter new];
		[dateFormatterMonthYear setDateFormat:NSLocalizedString(@"MMM yyyy", @"Month and year date formatter")];
		//[dateFormatterMonthYear setDateStyle: kCFDateFormatterLongStyle];
		//[dateFormatterMonthYear setTimeStyle: kCFDateFormatterShortStyle];
		dateFormatterMonthDayYear = [NSDateFormatter new];
		[dateFormatterMonthDayYear setDateFormat:NSLocalizedString(@"MMM d, yyyy", @"Month, day, and year date formatter")];
		//[dateFormatterMonthDayYear setTimeStyle: kCFDateFormatterShortStyle];
		dateFormatterMonthDayTime = [NSDateFormatter new];
		[dateFormatterMonthDayTime setDateFormat:NSLocalizedString(@"MMM d, h:mm a", @"Month, day, and time date formatter")];
		//[dateFormatterMonthDayTime setTimeStyle: kCFDateFormatterShortStyle];
		dateFormatterNumbers = [NSDateFormatter new];
		[dateFormatterNumbers setDateStyle: NSDateFormatterShortStyle];
		//[dateFormatterMonthDayTime setTimeStyle: kCFDateFormatterShortStyle];
	}
	
	//NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSDate *now = [NSDate date];
	NSDateComponents *nowComponents = [gregorian components: NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: now];
	nowComponents.hour = 0;
	NSDate *nowMidnight = [gregorian dateFromComponents: nowComponents];
	
	// Note: NSDateFormatter will convert the date to our local TZ. Issue #72
	NSDate *then = date;
	NSDateComponents *deltaComponents = [gregorian components:NSCalendarUnitMinute | NSCalendarUnitYear fromDate: then toDate: nowMidnight options:NSCalendarWrapComponents];
	
	nowComponents.day = 31;
	nowComponents.month = 12;
	NSDate *nowNewYear = [gregorian dateFromComponents: nowComponents];
	NSDateComponents *deltaComponentsYear = [gregorian components: NSCalendarUnitDay | NSCalendarUnitYear fromDate: then toDate: nowNewYear options:0];
	//NSLog(@"Comparing %@ to %@: %d", [then description], [nowMidnight description], deltaComponentsYear.year);
	NSString *dateString;
	
	if (deltaComponents.minute <= 0) {
		//[dateFormatter setDateFormat:@"h:mm a"];
		NSString *todayStr = NSLocalizedString(@"Today", @"Displayed as a date in the case where a note was modified today, for example");
		dateString = brief ? @"" : [todayStr stringByAppendingString:@", "];
		dateString = [dateString stringByAppendingString: [dateFormatterTime stringFromDate:then]];
	} else if (deltaComponents.minute < 60*24) {
		//[dateFormatter setDateFormat:@"h:mm a"];
		NSString *yesterdayStr = NSLocalizedString(@"Yesterday",
												   @"Displayed as a date in the case where a note was modified yesterday, for example");
		if (brief)
			dateString = yesterdayStr;
		else {
			dateString = [yesterdayStr stringByAppendingString:@", "];
			dateString = [dateString stringByAppendingString: [dateFormatterTime stringFromDate:then]];	
		}
	} else {
		if (deltaComponentsYear.year <= 0) {
			// This year
			if (!brief) {
				dateString = [dateFormatterMonthDay stringFromDate:then];
				dateString = [dateString stringByAppendingFormat:@", %@", [dateFormatterTime stringFromDate:then]];
			} else
				dateString = [dateFormatterMonthDay stringFromDate: then];
		} else {
			// Previous years
			if (brief)
				dateString = [dateFormatterNumbers stringFromDate: then];
			else
				dateString = [dateFormatterMonthDayYear stringFromDate: then];
		}
	}	
	
	return dateString;
}

- (NSString *)creationDateString:(BOOL)brief {
	return [self dateString:creationDate brief:brief];
}

- (NSString *)modificationDateString:(BOOL)brief {
	return [self dateString:modificationDate brief:brief];
}

- (void)setTagsFromList:(NSArray *)tagList {
    [self setTags: [tagList JSONString]];
}

- (void)updateTagsArray {
    tagsArray = tags.length > 0 ? [[tags objectFromJSONString] mutableCopy] : [NSMutableArray arrayWithCapacity:2];
}

- (void)updateEmailTagsArray {

    emailTagsArray = [NSMutableArray arrayWithCapacity:2];
    for (NSString *tag in tagsArray) {
        if ([tag containsEmailAddress])
            [emailTagsArray addObject:tag];
    }
}

- (BOOL)hasTags {
    if (tags == nil || tags.length == 0)
        return NO;
    
    return [tagsArray count] > 0;
}

- (BOOL)hasTag:(NSString *)tag {
    if (tags == nil || tags.length == 0)
        return NO;
    
    for (NSString *tagCheck in tagsArray) {
        if ([tagCheck compare:tag] == NSOrderedSame)
            return YES;
    }
    return NO;
}

- (void)addTag:(NSString *)tag {
	if (![self hasTag: tag]) {
        NSString *newTag = [tag copy];
        [tagsArray addObject:newTag];
        self.tags = [tagsArray JSONString];
    }
}

- (void)updateSystemTagsArray {
    systemTagsArray = systemTags.length > 0 ? [[systemTags objectFromJSONString] mutableCopy] : [NSMutableArray arrayWithCapacity:2];
}

- (void)addSystemTag:(NSString *)tag {
	if (![self hasSystemTag: tag]) {
        NSString *newTag = [tag copy];
        [systemTagsArray addObject:newTag];
        self.systemTags = [systemTagsArray JSONString];
    }
}

- (BOOL)hasSystemTag:(NSString *)tag {
    if (systemTags == nil || systemTags.length == 0)
        return NO;
    
    for (NSString *tagCheck in systemTagsArray) {
        if ([tagCheck compare:tag] == NSOrderedSame)
            return YES;
    }
    return NO;
}

- (void)stripTag:(NSString *)tag {
    if (tags.length == 0)
        return;
    
    NSMutableArray *tagsArrayCopy = [tagsArray copy];
    for (NSString *tagCheck in tagsArrayCopy) {
        if ([tagCheck compare:tag] == NSOrderedSame) {
            [tagsArray removeObject:tagCheck];
            continue;
        }
    }

	self.tags = [tagsArray JSONString];
}

- (void)setSystemTagsFromList:(NSArray *)tagList {
    [self setSystemTags: [tagList JSONString]];
}

- (void)stripSystemTag:(NSString *)tag {
    if (systemTags.length == 0)
        return;
    
    NSMutableArray *systemTagsArrayCopy = [systemTagsArray copy];
    for (NSString *tagCheck in systemTagsArrayCopy) {
        if ([tagCheck compare:tag] == NSOrderedSame) {
            [systemTagsArray removeObject:tagCheck];
            continue;
        }
    }
    
	self.systemTags = [systemTagsArray JSONString];
}

- (NSDictionary *)noteDictionaryWithContent:(BOOL)include {
	NSMutableDictionary *note = [[NSMutableDictionary alloc] init];

	if (remoteId != nil && [remoteId length] > 1)
        [note setObject:remoteId forKey:@"key"];

	[note setObject:deleted ? @"1" : @"0" forKey:@"deleted"];
	[note setObject:[tags stringArray] forKey:@"tags"];
	[note setObject:[systemTags stringArray] forKey:@"systemtags"];
	[note setObject:[NSNumber numberWithDouble:[modificationDate timeIntervalSince1970]] forKey:@"modifydate"];
	[note setObject:[NSNumber numberWithDouble:[creationDate timeIntervalSince1970]] forKey:@"createdate"];
	
	if (include) {
		[note setObject:content forKey:@"content"];
	}
	return note;
}

- (BOOL)isList {
	// Quick and dirty for now to avoid having to upgrade the database again with another flag
	NSRange newlineRange = [content rangeOfString:@"\n"];
	if (newlineRange.location == NSNotFound || newlineRange.location+newlineRange.length+2 > content.length)
		return NO;
	
	return [content compare:@"- " options:0
									range:NSMakeRange(newlineRange.location+newlineRange.length, 2)] == NSOrderedSame;
}

@end
