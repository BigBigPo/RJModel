//
//  RJCellModel.h
//  RJModelHelper
//
//  Created by Po on 2017/9/5.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "RJModel.h"
#import "RJCellSubModel.h"
@interface RJCellModel : RJModel

@property (assign, nonatomic) NSInteger number;
@property (strong, nonatomic) RJCellSubModel * subModel;

@end
