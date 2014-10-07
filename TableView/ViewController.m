//
//  ViewController.m
//  TableView
//
//  Created by lxl on 14-9-28.
//  Copyright (c) 2014年 lxl. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sectionName;
@property (nonatomic, strong) NSMutableArray *sectionData;
@property (nonatomic, strong) NSMutableArray *filteredData;
@property (nonatomic, strong) UISearchDisplayController *sdc;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //创建section数据
    _sectionName = [NSMutableArray new];
    _sectionData = [NSMutableArray new];
    
    for (char c = 'a'; c <= 'z'; c++) {
        _sectionName[c - 'a'] = [NSString stringWithFormat:@"%c", c];
        NSMutableArray *data = [NSMutableArray new];
        for (int i = 0; i < rand() % 50; i++) {
            data[i] = [NSString stringWithFormat:@"%c.%d", c, i];
        }
        [_sectionData addObject:data];
    }
    
    
    
    //设置index属性
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.sectionIndexColor = [UIColor greenColor];
    
    //注册cell
    [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"Header"];


    
    //search bar
    UISearchBar *searchBar = [UISearchBar new];
    [searchBar sizeToFit];
    //设置scope button，显示在navigation中时，不会出现
    searchBar.scopeButtonTitles = @[@"Starts With", @"Contains"];
    //如果显示在navigation中，这儿必须设置为YES
    searchBar.showsCancelButton = YES;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.delegate = self;
    [_tableView setTableHeaderView:searchBar];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    //search display
    UISearchDisplayController *sdc = [[UISearchDisplayController alloc]
                                      initWithSearchBar:searchBar contentsController:self];
    //将search display显示在navigation中
    //要显示navigation item必须在UISearchDisplayController中添加
//    sdc.displaysSearchBarInNavigationBar = YES;
//    sdc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:nil];

    _sdc = sdc;
    sdc.delegate = self;
    sdc.searchResultsDelegate = self;
    sdc.searchResultsDataSource = self;
    
    //添加编辑按钮
//    self.editButtonItem.target = self;
//    self.editButtonItem.action = @selector(doEdit:);
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSouce & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionName.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     NSArray *model = (tableView == _sdc.searchResultsTableView) ? _filteredData : _sectionData;
    return [model[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //这儿指定tableview，防止search时出错
    TableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSArray *model = (tableView == _sdc.searchResultsTableView) ? _filteredData : _sectionData;
    
    cell.textField.text = model[indexPath.section][indexPath.row];
    cell.textField.delegate = self;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sectionName[section];
}

// index 数组
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //在index的第一个元素中添加一个搜索图标，指示用户表格可以搜索
    if (tableView != _tableView) {
        return nil;
    }
    return [@[UITableViewIndexSearch] arrayByAddingObjectsFromArray:_sectionName];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //在index中加入搜索图标后，修正index跳转
    if (index == 0) {
        [tableView scrollRectToVisible:tableView.tableHeaderView.frame animated:YES];
    }
    return index - 1;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //单选模式下，可以取消选择
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.isSelected) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        cell.accessoryType =  UITableViewCellAccessoryNone;
        return nil;
    }
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    return indexPath;
}

//重写viewcontroller的setEditing方法，同时调用tableview的edit
//如果当前viewcontroller是UITableViewController系统会自动完成
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    _tableView.editing = editing;
}

- (void)setEditing:(BOOL)editing
{
    [super setEditing:editing];
    _tableView.editing = editing;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger num = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row == num - 1) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"你想删除我吗？";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_sectionData[indexPath.section] removeObjectAtIndex:indexPath.row];
        
        if ([_sectionData[indexPath.section] count] == 0) {
            
            [_sectionName removeObjectAtIndex:indexPath.section];
            [_sectionData removeObjectAtIndex:indexPath.section];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView reloadSectionIndexTitles];
        }
        else
        {
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{

}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UIView *v = textField;
    do {
        v = v.superview;
    } while (![v isKindOfClass:[UITableViewCell class]]);
    TableViewCell *cell = (TableViewCell *)v;
    NSIndexPath *p = [_tableView indexPathForCell:cell];
    _sectionData[p.section][p.row] = textField.text;
    [_tableView reloadRowsAtIndexPaths:@[p] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

#pragma mark - UISearchBar Delegate


- (void)filteredData:(UISearchBar *)sb
{
    NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *s = evaluatedObject;
        NSStringCompareOptions opts = NSCaseInsensitiveSearch;
        //判断scope button
        if (sb.selectedScopeButtonIndex == 0) {
            opts |= NSAnchoredSearch;   //以...开头搜索
        }
        return ([s rangeOfString:sb.text options:opts].location != NSNotFound);
    }];
    NSMutableArray *data = [NSMutableArray new];
    for (NSArray *array in self.sectionData) {
        [data addObject:[array filteredArrayUsingPredicate:p]];
    }
    _filteredData = data;

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filteredData:searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self filteredData:searchBar];
}

#pragma mark - UISearchBarDisplay Delegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    //搜索结果和原始数据在同一个表格中
    //搜索结果不显示section header
    tableView.sectionHeaderHeight = 0;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //搜索不到时，显示内容
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *v in controller.searchResultsTableView.subviews) {
            if ([v isKindOfClass:[UILabel class]] &&
                [((UILabel *)v).text isEqualToString:@"No Results"]) {
                ((UILabel *)v).text = @"骚年，没有任何东西";
            }
        }
    });
    return YES;
}

@end
