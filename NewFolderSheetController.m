//
//  NewFolderSheetController.m
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 12/01/03.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewFolderSheetController.h"

@implementation NewFolderSheetController

- (IBAction)createNewFolder:(id)sender {
    [NSApp endSheet:newFolderSheet returnCode:NSAlertDefaultReturn];
}
- (IBAction)closeSheet:(id)sender {
    [NSApp endSheet:newFolderSheet returnCode:NSAlertOtherReturn];
}

@end
