//
//  SBSteppedMultiSelectView.h
//  Parkr
//
//  Created by Sam Broe on 10/13/12.
//  Copyright (c) 2012 Sam Broe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDraggableSelectionView.h"

typedef enum
{
    SBSteppedMultiSelectViewVertical = 0,
    SBSteppedMultiSelectViewHorizontal
}
SBSteppedMultiSelectViewDirection;

@class SBSteppedMultiSelectView;

@protocol SBSteppedMultiSelectViewDataSource <NSObject>

-(UIView *)steppedMultiSelectView:(SBSteppedMultiSelectView *)steppedMultiSelectView viewForStepAtIndex:(NSUInteger)index;
-(UIView *)steppedMultiSelectView:(SBSteppedMultiSelectView *)steppedMultiSelectView viewForFirstHandleWithIndex:(NSUInteger)index;
-(UIView *)steppedMultiSelectView:(SBSteppedMultiSelectView *)steppedMultiSelectView viewForLastHandleWithIndex:(NSUInteger)index;

@optional
-(UIView *)viewForSelectorInSteppedMultiSelectView:(SBSteppedMultiSelectView *)steppedMultiSelectView;

@end

@protocol SBSteppedMultiSelectViewDelegate <NSObject>

-(void)steppedMultiSelectView:(SBSteppedMultiSelectView *)steppedMultiSelectView didSelectRange:(NSRange)range;

@end

@interface SBSteppedMultiSelectView : SBDraggableSelectionView

@property (nonatomic, assign) NSUInteger steps;
@property (nonatomic, assign) id<SBSteppedMultiSelectViewDataSource> dataSource;
@property (nonatomic, assign) id<SBSteppedMultiSelectViewDelegate> delegate;
@property (nonatomic, assign) SBSteppedMultiSelectViewDirection direction;
@property (nonatomic, assign) NSRange selectedRange;

-(id)initWithFrame:(CGRect)frame direction:(SBSteppedMultiSelectViewDirection)direction steps:(NSUInteger)steps;

@end
