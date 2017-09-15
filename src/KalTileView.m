/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalTileView.h"
#import "KalDate.h"
#import "KalPrivate.h"

@implementation KalTileView

@synthesize date;

- (id)initWithFrame:(CGRect)frame tileSize:(CGSize)tileSize
{
  if ((self = [super initWithFrame:frame])) {
      _tileSize = tileSize;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    origin = frame.origin;
    [self resetState];
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
  CGFloat fontSize = 24.f;
  UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
  UIColor *textColor = nil;
  UIImage *markerImage = nil;

  
  if ([self isToday] && self.selected) {
    [[[UIImage imageNamed:@"Kal.bundle/kal_tile_today_selected.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, self.tileSize.width+1, self.tileSize.height+1)];
    textColor = [UIColor whiteColor];
    markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker_today.png"];
  } else if ([self isToday] && !self.selected) {
    [[[UIImage imageNamed:@"Kal.bundle/kal_tile_today.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, self.tileSize.width+1, self.tileSize.height+1)];
    textColor = [UIColor whiteColor];
    markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker_today.png"];
  } else if (self.selected) {
    [[[UIImage imageNamed:@"Kal.bundle/kal_tile_selected.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0] drawInRect:CGRectMake(0, -1, self.tileSize.width+1, self.tileSize.height+1)];
    textColor = [UIColor whiteColor];
    markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker_selected.png"];
  } else if (self.belongsToAdjacentMonth) {
    textColor = [UIColor grayColor];
    markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker_dim.png"];
  } else {
    textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Kal.bundle/kal_tile_text_fill.png"]];
    markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker.png"];
  }
  
  if (flags.marked)
    [markerImage drawInRect:CGRectMake((self.frame.size.width / 2) - 1, 35.f, 4.f, 5.f)];
  
  NSUInteger n = [self.date day];
  NSString *dayText = [NSString stringWithFormat:@"%lu", (unsigned long)n];
  
    NSDictionary *attributes = @{NSFontAttributeName: font};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    CGRect arect = [dayText boundingRectWithSize:CGSizeMake(44, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    CGSize textSize = arect.size;

    
  CGFloat textX, textY;
  textX = roundf(0.5f * (self.tileSize.width - textSize.width));
  textY = roundf(0.5f * (self.tileSize.height - textSize.height)) - 2.f;
  [dayText drawAtPoint:CGPointMake(textX, textY) withAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: textColor}];
    
}

- (void)resetState
{
  // realign to the grid
  CGRect frame = self.frame;
  frame.origin = origin;
  frame.size = self.tileSize;
  self.frame = frame;
  
  [date release];
  date = nil;
  flags.type = KalTileTypeRegular;
  flags.highlighted = NO;
  flags.selected = NO;
  flags.marked = NO;
}

- (void)setDate:(KalDate *)aDate
{
  if (date == aDate)
    return;

  [date release];
  date = [aDate retain];

  [self setNeedsDisplay];
}

- (BOOL)isSelected { return flags.selected; }

- (void)setSelected:(BOOL)selected
{
  if (flags.selected == selected)
    return;

  // workaround since I cannot draw outside of the frame in drawRect:
  if (![self isToday]) {
    CGRect rect = self.frame;
    if (selected) {
      rect.origin.x--;
      rect.size.width++;
      rect.size.height++;
    } else {
      rect.origin.x++;
      rect.size.width--;
      rect.size.height--;
    }
    self.frame = rect;
  }
  
  flags.selected = selected;
  [self setNeedsDisplay];
}

- (BOOL)isHighlighted { return flags.highlighted; }

- (void)setHighlighted:(BOOL)highlighted
{
  if (flags.highlighted == highlighted)
    return;
  
  flags.highlighted = highlighted;
  [self setNeedsDisplay];
}

- (BOOL)isMarked { return flags.marked; }

- (void)setMarked:(BOOL)marked
{
  if (flags.marked == marked)
    return;
  
  flags.marked = marked;
  [self setNeedsDisplay];
}

- (KalTileType)type { return flags.type; }

- (void)setType:(KalTileType)tileType
{
  if (flags.type == tileType)
    return;
  
  // workaround since I cannot draw outside of the frame in drawRect:
  CGRect rect = self.frame;
  if (tileType == KalTileTypeToday) {
    rect.origin.x--;
    rect.size.width++;
    rect.size.height++;
  } else if (flags.type == KalTileTypeToday) {
    rect.origin.x++;
    rect.size.width--;
    rect.size.height--;
  }
  self.frame = rect;
  
  flags.type = tileType;
  [self setNeedsDisplay];
}

- (BOOL)isToday { return flags.type == KalTileTypeToday; }

- (BOOL)belongsToAdjacentMonth { return flags.type == KalTileTypeAdjacent; }

- (void)dealloc
{
  [date release];
  [super dealloc];
}

@end
