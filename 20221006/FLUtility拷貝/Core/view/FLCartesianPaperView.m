//
// Created by Eric Chen on 2019-09-23.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import "FLCartesianPaperView.h"
#import "FLUtil.h"
#import "FLStringKit.h"
#import "FLDrawPen.h"

@implementation FLCartesianPaperView {}

#pragma mark - View Initialization

//- (instancetype) init {
//    self = [super init];
//    return self;
//}

// [FLCartesianPaperView new] = alloc + init = initWithFrame(CGRectZero)
// So no need to setup in [-init]
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (void) setup {
    _origin = CGPointZero;
    _tile = CGSizeMake(20, 20);
    _tileCentered = false;

    // Setup draw pens
    FLDrawPen *b;

    // border
    b = [FLDrawPen new];
    b.width = 5;
    b.color = UIColor.darkGrayColor;
    _border = b;

    // vertical
    b = [FLDrawPen new];
    b.color = UIColor.grayColor;
    _vertical = b;

    // horizontal
    b = [FLDrawPen new];
    b.color = UIColor.lightGrayColor;
    _horizontal = b;
}

- (void) layoutSubviews {
    if (_tileCentered) {
        [self centerTile];
    }
}

#pragma mark - Public Methods

- (void) centerTile {
    if (isNonPositiveSize(_tile)) {
        return; // illegal size
    }

    // Make Paper Tile be centered at
    CGSize z = self.frame.size;
    int w = (int) round(z.width);
    int h = (int) round(z.height);
    int tw = (int) round(_tile.width);
    int th = (int) round(_tile.height);

    double x = (w % tw) / 2;
    double y = (h % th) / 2;
    _origin = CGPointMake(x, y);
    [self setNeedsDisplay];
}

#pragma mark - View Drawing

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Start drawing
    CGContextSaveGState(ctx);
    if (isNonPositiveSize(_tile)) {
        // No grid to draw
    } else {
        [self drawVerticalLines:ctx];
        [self drawHorizontalLines:ctx];
    }
    [self drawBorder:ctx];
    CGContextRestoreGState(ctx);
}

- (void) drawBorder:(CGContextRef)ctx {
    FLDrawPen *pen = _border;
    if (!pen.enable) {
        return;
    }

    CGSize z = self.frame.size;
    // Start drawing
    CGContextSaveGState(ctx);
    // Set border color and rect
    CGContextSetStrokeColorWithColor(ctx, pen.color.CGColor);
    CGContextSetLineWidth(ctx, 2 * pen.width);
    CGRect r = CGRectMake(0, 0, z.width, z.height);
    CGContextStrokeRect(ctx, r);

    // Draw end
    CGContextRestoreGState(ctx);
}

- (void) drawHorizontalLines:(CGContextRef)ctx {
    FLDrawPen *pen = _horizontal;
    if (!pen.enable) {
        return;
    }

    const CGAffineTransform m = CGAffineTransformIdentity;
    CGSize size = self.frame.size;
    double dh = _tile.height;
    double h = size.height;
    double w = size.width;
    if (dh <= 0) {
        return;
    }

    CGMutablePathRef path = CGPathCreateMutable();
    // Start drawing
    CGContextSaveGState(ctx);
    // Set stroke color and lines
    CGContextSetStrokeColorWithColor(ctx, pen.color.CGColor);
    CGContextSetLineWidth(ctx, pen.width);
    for (double y = _origin.y; y < h; y += dh) {
        CGPathMoveToPoint(path, &m, 0, y);
        CGPathAddLineToPoint(path, &m, w, y);
    }

    // Draw lines
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);

    // Draw end
    CGPathRelease(path);
    CGContextRestoreGState(ctx);
}

- (void) drawVerticalLines:(CGContextRef)ctx {
    FLDrawPen *pen = _vertical;
    if (!pen.enable) {
        return;
    }

    const CGAffineTransform m = CGAffineTransformIdentity;
    CGSize size = self.frame.size;
    double dw = _tile.width;
    double h = size.height;
    double w = size.width;
    if (dw <= 0) {
        return;
    }

    CGMutablePathRef path = CGPathCreateMutable();
    // Start drawing
    CGContextSaveGState(ctx);
    // Set stroke color and lines
    CGContextSetStrokeColorWithColor(ctx, pen.color.CGColor);
    CGContextSetLineWidth(ctx, pen.width);
    for (double x = _origin.x; x < w; x += dw) {
        CGPathMoveToPoint(path, &m, x, 0);
        CGPathAddLineToPoint(path, &m, x, h);
    }

    // Draw lines
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);

    // Draw end
    CGPathRelease(path);
    CGContextRestoreGState(ctx);
}

@end

