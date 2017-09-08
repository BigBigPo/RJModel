//
//  ViewController.m
//  RJModelHelper
//
//  Created by Po on 2017/8/28.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "ViewController.h"
#import "RJCellModel.h"
@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *add1Button;
@property (weak, nonatomic) IBOutlet UIButton *add10Button;

@property (strong, nonatomic) NSArray * allDatas;
@property (strong, nonatomic) NSArray * searchDatas;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_searchBar setDelegate:self];
    
    [self updateData];
//    [RJCellModel drapLocationTable];
}

- (void)updateData {
     _allDatas = [NSArray arrayWithArray:[RJCellModel getModelsWithOrder:@"number DESC"]];
    [_tableView reloadData];
}

#pragma mark - RJModel functions
- (void)addSingleData {
    RJCellModel * data = [self createModel];
    BOOL result = [data saveModel];
    if (result) {
        [self updateData];
    }
}

- (void)addDataWithCount:(NSInteger)count {
    NSMutableArray * temp = [NSMutableArray array];
    for (NSInteger i = 0 ; i < count; i ++) {
        RJCellModel * data = [self createModel];
        [temp addObject:data];
    }
    BOOL result = [RJCellModel saveModels:temp];
    if (result) {
        [self updateData];
    }
    
}
#pragma makr event
- (IBAction)pressAdd1Button:(UIButton *)sender {
    [self addSingleData];
}

- (IBAction)pressAdd10Button:(UIButton *)sender {
    [self addDataWithCount:10];
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tableView) {
        return _allDatas.count;
    }
    return _searchDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RJCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RJCell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    RJCellModel * model = nil;
    
    if (tableView != _tableView) {
        model = _searchDatas[indexPath.row];
    } else {
        model = _allDatas[indexPath.row];
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%ld",model.number]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"id: %ld", model.idNum]];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除模型
    RJCellModel * model = _allDatas[indexPath.row];
    BOOL result = [model deleteSelf];
    if (result) {
        // 刷新
        NSMutableArray * temp = [NSMutableArray arrayWithArray:_allDatas];
        [temp removeObjectAtIndex:indexPath.row];
        _allDatas = [temp copy];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        NSLog(@"删除成功");
    }
}

#pragma mark - UISearchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString * whereString = [NSString stringWithFormat:@"number like '%%%@%%'", searchText];
    //升序排列
    _searchDatas = [RJCellModel getModelsWithWhere:whereString order:@"number ASC"];
}

#pragma mark - get 1 data
- (RJCellModel *)createModel {
    RJCellModel * data = [[RJCellModel alloc] init];
    data.number = arc4random() % 100;
    return data;
}






@end
