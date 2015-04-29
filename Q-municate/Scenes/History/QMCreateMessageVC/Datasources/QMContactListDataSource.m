//
//  QMContactListDatasource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 03.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMContactListDatasource.h"
#import "QMContactCell.h"
#import "QMAlphabetizer.h"

@interface QMContactListDataSource()

@property (strong, nonatomic) NSDictionary *alphabetizedDictionary;
@property (strong, nonatomic) NSArray *sectionIndexTitles;
@property (strong, nonatomic) NSMutableArray *selectedData;

@end

@implementation QMContactListDataSource

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.selectedData = [NSMutableArray array];
    }
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *sectionIndexTitle = self.sectionIndexTitles[section];
    NSArray *contacts = self.alphabetizedDictionary[sectionIndexTitle];
 
    return contacts.count;
}

- (QBUUser *)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *sectionIndexTitle = self.sectionIndexTitles[indexPath.section];
    return self.alphabetizedDictionary[sectionIndexTitle][indexPath.row];
}

- (void)addObjects:(NSArray *)objects {
    
    self.alphabetizedDictionary = [QMAlphabetizer alphabetizedDictionaryFromObjects:objects usingKeyPath:@"fullName"];
    self.sectionIndexTitles = [QMAlphabetizer indexTitlesFromAlphabetizedDictionary:self.alphabetizedDictionary];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMContactCell" forIndexPath:indexPath];
    
    if (self.selectable) {
        
        cell.selectable = self.selectable;
        cell.check = [self isSelectedObjectAtIndedx:indexPath];
    }

    QBUUser *user = [self objectAtIndexPath:indexPath];
    
    [cell setTitle:user.fullName];
    [cell setSubTitle:[NSString stringWithFormat:@"last seen %@", @"1 hour ago"]];
    [cell setImageWithUrl:user.avatarUrl];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return self.sectionIndexTitles[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    return self.sectionIndexTitles.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return index;
}

#pragma mark - Public

- (NSArray *)selectedObjects {
    
    return self.selectedData.copy;
}

- (void)selectObjectAtIndexPath:(NSIndexPath *)indexPath {
    
    QBUUser *user = [self objectAtIndexPath:indexPath];
    NSAssert([self.selectedData indexOfObject:user] == NSNotFound, @"Contact selelected");
    NSAssert(self.selectable, @"This is not selectable datasource");
    
    [self.selectedData addObject:user];
    [self.handler didUpdateContactListDataSource:self];
}

- (void)deselectObjectAtIndexPath:(NSIndexPath *)indexPath {
    
    QBUUser *user = [self objectAtIndexPath:indexPath];
    NSAssert([self.selectedData indexOfObject:user] != NSNotFound, @"Contact not selected");
    NSAssert(self.selectable, @"This is not selectable datasource");
    
    [self.selectedData removeObject:user];
    
    [self.handler didUpdateContactListDataSource:self];
}

- (BOOL)isSelectedObjectAtIndedx:(NSIndexPath *)indexPath {
    
    QBUUser *user = [self objectAtIndexPath:indexPath];
    return [self.selectedData containsObject:user];
}

@end
