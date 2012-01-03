//
//  NewFolderSheetController.h
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 12/01/03.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewFolderSheetController : NSObject {
    IBOutlet NSTextField *folderName;
    IBOutlet NSWindow *newFolderSheet;
}

- (IBAction)createNewFolder:(id)sender;
- (IBAction)closeSheet:(id)sender;

@end
