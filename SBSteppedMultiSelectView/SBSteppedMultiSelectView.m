//
//  SBSteppedMultiSelectView.m
//  Parkr
//
//  Created by Sam Broe on 10/13/12.
//  Copyright (c) 2012 Sam Broe. All rights reserved.
//

#import "SBSteppedMultiSelectView.h"

@interface SBSteppedMultiSelectView ()

@property (nonatomic, retain) UIView *stepsContainerView;
@property (nonatomic, retain) UIView *selectorContainerView;
@property (nonatomic, retain) UIView *handlesContainerView;
@property (nonatomic, retain) UIView *firstHandleView;
@property (nonatomic, retain) UIView *lastHandleView;
@property (nonatomic, retain) UIView *selectorView;
@property (nonatomic, assign) BOOL isTrackingFirstHandle;
@property (nonatomic, assign) BOOL isTrackingLastHandle;
@property (nonatomic, assign) BOOL isTrackingSelector;
@property (nonatomic, assign) NSUInteger indexForFirstHandle;
@property (nonatomic, assign) NSUInteger indexForLastHandle;
@property (nonatomic, readonly) CGPoint centerPointForFirstHandle;
@property (nonatomic, readonly) CGPoint centerPointForLastHandle;

-(void)setup;
-(CGRect)frameForStepAtIndex:(NSUInteger)index;
-(CGRect)frameForSelector;
-(NSUInteger)indexForPoint:(CGPoint)point;
-(void)selectRange:(NSRange)range animated:(BOOL)animated;
-(void)evalutateSelectionForPoint:(CGPoint)point directon:(CGPoint)direction;

@end

@implementation SBSteppedMultiSelectView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.stepsContainerView = [[[UIView alloc] initWithFrame:frame] autorelease];
        [self addSubview:_stepsContainerView];
        
        self.selectorContainerView = [[[UIView alloc] initWithFrame:frame] autorelease];
        [self addSubview:_selectorContainerView];
        
        self.handlesContainerView = [[[UIView alloc] initWithFrame:frame] autorelease];
        [self addSubview:_handlesContainerView];

        _direction = SBSteppedMultiSelectViewVertical;
        _steps = 10;
        _selectedRange = NSMakeRange(0, _steps-1);
        
        [self setClipsToBounds:NO];
        [_handlesContainerView setClipsToBounds:NO];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame direction:(SBSteppedMultiSelectViewDirection)direction steps:(NSUInteger)steps
{
    if (self = [self initWithFrame:frame])
    {
        self.direction = direction;
        self.steps = steps;
    }
    
    return self;
}

-(void)dealloc
{
    self.stepsContainerView = nil;
    self.selectorContainerView = nil;
    self.handlesContainerView = nil;
    self.firstHandleView = nil;
    self.lastHandleView = nil;
    self.selectorView = nil;
    
    [super dealloc];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [_stepsContainerView setFrame:self.bounds];
    [_selectorContainerView setFrame:self.bounds];
    [_handlesContainerView setFrame:self.bounds];
    
    [_stepsContainerView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        
        [view setFrame:[self frameForStepAtIndex:idx]];
        
    }];
    
    [self selectRange:_selectedRange animated:NO];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return _handlesContainerView;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (!_firstHandleView || !_lastHandleView) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_handlesContainerView];
    
    self.isTrackingFirstHandle = NO;
    self.isTrackingLastHandle = NO;
    self.isTrackingSelector = NO;
    
    if (CGRectContainsPoint(_firstHandleView.frame, point))
    {
        self.isTrackingFirstHandle = YES;
    }
    else if (CGRectContainsPoint(_lastHandleView.frame, point))
    {
        self.isTrackingLastHandle = YES;
    }
    else if (_selectorView && CGRectContainsPoint(_selectorView.frame, point))
    {
        self.isTrackingSelector = YES;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    self.isTrackingFirstHandle = NO;
    self.isTrackingLastHandle = NO;
    self.isTrackingSelector = NO;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    NSUInteger startIndex = [self indexForPoint:self.centerPointForFirstHandle];
    NSUInteger length = [self indexForPoint:self.centerPointForLastHandle] - [self indexForPoint:self.centerPointForFirstHandle];
    
    [self selectRange:NSMakeRange(startIndex, length) animated:YES];
    
    self.isTrackingFirstHandle = NO;
    self.isTrackingLastHandle = NO;
    self.isTrackingSelector = NO;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isTrackingFirstHandle || _isTrackingLastHandle || _isTrackingSelector)
        [super touchesMoved:touches withEvent:event];
}

#pragma mark - Private Methods

-(void)setup
{
    if (!_dataSource
        || ![_dataSource respondsToSelector:@selector(steppedMultiSelectView:viewForLastHandleWithIndex:)]
        || ![_dataSource respondsToSelector:@selector(steppedMultiSelectView:viewForStepAtIndex:)]
        || ![_dataSource respondsToSelector:@selector(steppedMultiSelectView:viewForFirstHandleWithIndex:)]
        || ![_dataSource respondsToSelector:@selector(viewForSelectorInSteppedMultiSelectView:)]
        || _steps == 0
    ) return;
    
    UIView *viewForIndex = nil;
    
    [_stepsContainerView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    
    for (NSUInteger i = 0; i < _steps; i++)
    {
        viewForIndex = [_dataSource steppedMultiSelectView:self viewForStepAtIndex:i];
        
        [_stepsContainerView addSubview:viewForIndex];
    }
    
    _selectedRange = NSMakeRange(0, 4);
    
    [self setNeedsLayout];
}

-(NSUInteger)indexForPoint:(CGPoint)point
{
    if (_direction == SBSteppedMultiSelectViewHorizontal)
    {
        //
    }
    else
    {
        NSUInteger index = roundf(point.y / floorf(CGRectGetHeight(self.frame)/_steps));
        index = MIN(_steps - 1, MAX(0, index));
        return index;
    }
    
    return 0;
}

-(CGRect)frameForStepAtIndex:(NSUInteger)index
{
    if (_stepsContainerView.subviews.count)
    {
        CGFloat x = 0.0;
        CGFloat y = 0.0;
        CGFloat width = 0.0;
        CGFloat height = 0.0;
        
        if (_direction == SBSteppedMultiSelectViewHorizontal)
        {
            x = (index * floorf(CGRectGetWidth(self.frame)/_steps)) - (CGRectGetWidth([_stepsContainerView.subviews[index] frame]) * 0.5);
            y = 0.0;
            width = CGRectGetWidth([_stepsContainerView.subviews[index] frame]);
            height = CGRectGetHeight(self.frame);
        }
        else
        {
            x = 0.0;
            y = (index * floorf(CGRectGetHeight(self.frame)/_steps)) - (CGRectGetHeight([_stepsContainerView.subviews[index] frame]) * 0.5);
            width = CGRectGetWidth(self.frame);
            height = CGRectGetHeight([_stepsContainerView.subviews[index] frame]);
        }
        
        return CGRectMake(x, y, width, height);
    }
    
    return CGRectZero;
}

-(void)selectRange:(NSRange)range animated:(BOOL)animated
{
    NSUInteger startIndex = range.location;
    NSUInteger endIndex = range.location + range.length;
    
    if (!_firstHandleView || _indexForFirstHandle != startIndex)
    {
        if (_firstHandleView)
            [_firstHandleView removeFromSuperview];
        
        self.firstHandleView = [_dataSource steppedMultiSelectView:self viewForFirstHandleWithIndex:startIndex];
        [_handlesContainerView addSubview:_firstHandleView];
    }
    
    if (!_lastHandleView || _indexForLastHandle != endIndex)
    {
        if (_lastHandleView)
            [_lastHandleView removeFromSuperview];
        
        self.lastHandleView = [_dataSource steppedMultiSelectView:self viewForLastHandleWithIndex:endIndex];
        [_handlesContainerView addSubview:_lastHandleView];
    }
    
    if (!_firstHandleView || !_lastHandleView) return;
    
    if (!_selectorView && [_dataSource respondsToSelector:@selector(viewForSelectorInSteppedMultiSelectView:)])
    {
        self.selectorView = [_dataSource viewForSelectorInSteppedMultiSelectView:self];
        [_selectorContainerView addSubview:_selectorView];
    }
    
    CGFloat topX = 0.0;
    CGFloat topY = 0.0;
    CGFloat botX = 0.0;
    CGFloat botY = 0.0;
    
    if (_direction == SBSteppedMultiSelectViewHorizontal)
    {
        topX = CGRectGetMidX([self frameForStepAtIndex:startIndex]);
        topY = CGRectGetMidY([self frameForStepAtIndex:startIndex]);
        
        botX = CGRectGetMidX([self frameForStepAtIndex:endIndex]);
        botY = CGRectGetMidY([self frameForStepAtIndex:endIndex]);
    }
    else
    {
        topX = CGRectGetMidX([self frameForStepAtIndex:startIndex]);
        topY = CGRectGetMidY([self frameForStepAtIndex:startIndex]);
        
        botX = CGRectGetMidX([self frameForStepAtIndex:endIndex]);
        botY = CGRectGetMidY([self frameForStepAtIndex:endIndex]);
    }
    
    [UIView animateWithDuration:(animated) ? 0.1 : 0.0 animations:^{
        
        [_firstHandleView setCenter:CGPointMake(topX, topY)];
        [_lastHandleView setCenter:CGPointMake(botX, botY)];
        
        if (_selectorView)
            [_selectorView setFrame:self.frameForSelector];
        
    }];
    
    _indexForFirstHandle = [self indexForPoint:self.centerPointForFirstHandle];
    _indexForLastHandle = [self indexForPoint:self.centerPointForLastHandle];
    
    _selectedRange = range;
}

-(void)evalutateSelectionForPoint:(CGPoint)point directon:(CGPoint)direction
{
    [super evalutateSelectionForPoint:point directon:direction];
    
    if (_handlesContainerView.subviews.count == 2)
    {
        CGPoint handlePoint = CGPointZero;
        NSInteger index = -1;
        CGRect frame = CGRectZero;

        if (_direction == SBSteppedMultiSelectViewHorizontal && direction.x != 0)
        {
            NSLog(@"TRACKING HORIZ");
        }
        else if (_direction == SBSteppedMultiSelectViewVertical && direction.y != 0)
        {
            point.y = fmaxf(0, point.y);
            point.y = fminf([self frameForStepAtIndex:_steps-1].origin.y, point.y);
            
            if (_isTrackingFirstHandle)
            {
                handlePoint.x = CGRectGetMinX(_firstHandleView.frame);
                handlePoint.y = point.y - floorf(CGRectGetHeight(_firstHandleView.frame) * 0.5);
                
                if ((handlePoint.y + CGRectGetHeight(_firstHandleView.frame)) > CGRectGetMinY(_lastHandleView.frame))
                {
                    handlePoint.y = CGRectGetMinY(_lastHandleView.frame) - CGRectGetHeight(_firstHandleView.frame);
                }
                
                frame = CGRectMake(handlePoint.x, handlePoint.y, CGRectGetWidth(_firstHandleView.frame), CGRectGetHeight(_firstHandleView.frame));
                index = [self indexForPoint:CGPointMake(roundf(CGRectGetMidX(frame)), roundf(CGRectGetMidY(frame)))];
                
                [_firstHandleView setFrame:frame];
                
                
                if (index != _indexForFirstHandle)
                {
                    [_firstHandleView removeFromSuperview];
                    self.firstHandleView = [_dataSource steppedMultiSelectView:self viewForFirstHandleWithIndex:index];
                    [_firstHandleView setFrame:frame];
                    [_handlesContainerView insertSubview:_firstHandleView atIndex:0];
                    
                    _indexForFirstHandle = index;
                }
            }
            else if (_isTrackingLastHandle)
            {
                handlePoint.x = CGRectGetMinX(_lastHandleView.frame);
                handlePoint.y = point.y - floorf(CGRectGetHeight(_lastHandleView.frame) * 0.5);
                
                if (handlePoint.y <= CGRectGetMaxY(_firstHandleView.frame))
                {
                    handlePoint.y = CGRectGetMaxY(_firstHandleView.frame);
                }
                
                frame = CGRectMake(handlePoint.x, handlePoint.y, CGRectGetWidth(_lastHandleView.frame), CGRectGetHeight(_lastHandleView.frame));
                index = [self indexForPoint:CGPointMake(roundf(CGRectGetMidX(frame)), roundf(CGRectGetMidY(frame)))];
                
                [_lastHandleView setFrame:frame];
                
                if (index != _indexForLastHandle)
                {
                    [_lastHandleView removeFromSuperview];
                    self.lastHandleView = [_dataSource steppedMultiSelectView:self viewForLastHandleWithIndex:index];
                    [_lastHandleView setFrame:frame];
                    [_handlesContainerView insertSubview:_lastHandleView atIndex:1];
                    
                    _indexForLastHandle = index;
                }
            }
            else if (_isTrackingSelector)
            {
//                CGFloat firstHandleYOffset = self.centerPointForFirstHandle.y - point.y;
//                CGFloat lastHandleYOffset = self.centerPointForLastHandle.y - point.y;
//                
//                [_firstHandleView setCenter:CGPointMake(self.centerPointForFirstHandle.x, point.y + firstHandleYOffset)];
//                [_lastHandleView setCenter:CGPointMake(self.centerPointForLastHandle.x, point.y + lastHandleYOffset)];
            }
            
            if (_selectorContainerView.subviews.count)
                [_selectorContainerView.subviews[0] setFrame:self.frameForSelector];
        }
    }
    
}

#pragma mark - Public Methods



#pragma mark - Getters/Setters

-(UIView *)viewForPointLocation
{
    return _handlesContainerView;
}

-(void)setDirection:(SBSteppedMultiSelectViewDirection)direction
{
    if (_direction == direction) return;
    
    _direction = direction;
    
    [self setNeedsLayout];
}

-(void)setSteps:(NSUInteger)steps
{
    if (_steps == steps) return;
    
    _steps = steps;
    
    [self setNeedsLayout];
}

-(void)setDataSource:(id<SBSteppedMultiSelectViewDataSource>)dataSource
{
    if (_dataSource != dataSource)
    {
        _dataSource = dataSource;

        [self setup];
    }
}

-(CGRect)frameForSelector
{
    if (!_firstHandleView || !_lastHandleView) return CGRectZero;
    
    if (_direction == SBSteppedMultiSelectViewHorizontal)
    {
//        return CGRectMake(floorf(CGRectGetMidY(_firstHandleView.frame)), 0.0, floorf(CGRectGetMidX(_lastHandleView.frame) - CGRectGetMidX(_firstHandleView.frame)), CGRectGetHeight(self.frame));
        return CGRectMake(self.centerPointForFirstHandle.x, 0.0, self.centerPointForLastHandle.x - self.centerPointForFirstHandle.x, CGRectGetHeight(self.frame));
    }
    else
    {
//        return CGRectMake(0.0, floorf(CGRectGetMidY(_firstHandleView.frame)), CGRectGetWidth(self.frame), floorf(CGRectGetMidY(_lastHandleView.frame) - CGRectGetMidY(_firstHandleView.frame)));
        return CGRectMake(0.0, self.centerPointForFirstHandle.y, CGRectGetWidth(self.frame), self.centerPointForLastHandle.y - self.centerPointForFirstHandle.y);
    }
}

-(CGPoint)centerPointForFirstHandle
{
    UIView *firstHandleView = (_handlesContainerView.subviews.count > 0) ? _handlesContainerView.subviews[0] : nil;
    
    if (!firstHandleView) return CGPointZero;

    return CGPointMake(roundf(CGRectGetMidX(firstHandleView.frame)), roundf(CGRectGetMidY(firstHandleView.frame)));
}

-(CGPoint)centerPointForLastHandle
{
    UIView *lastHandleView = (_handlesContainerView.subviews.count > 1) ? _handlesContainerView.subviews[1] : nil;
    
    if (!lastHandleView) return CGPointZero;
    
    return CGPointMake(roundf(CGRectGetMidX(lastHandleView.frame)), roundf(CGRectGetMidY(lastHandleView.frame)));
}

-(void)setSelectedRange:(NSRange)selectedRange
{
    _selectedRange = selectedRange;
    
    [self selectRange:_selectedRange animated:YES];
}

@end
