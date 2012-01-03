//
//  MyBrowserDelegate.m
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 18/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyBrowserDelegate.h"
#import "KeitaiDocument.h"
#import "FolderInfo.h"
#import "FolderInfoPanelController.h"

@implementation MyBrowserDelegate

#if 0

- (KTFolderCategory *)selectedCategoryInBrowser:(NSBrowser *)browser {
    if ([browser selectedColumn] < 0) return nil;
    NSInteger row = [browser selectedRowInColumn:0];
    return [self->doc.root.children objectAtIndex:row];
}

- (KTFolderInfo *)selectedFolderInBrowser:(NSBrowser *)browser {
    if ([browser selectedColumn] < 1) return nil;
    NSInteger row = [browser selectedRowInColumn:1];
    KTFolderCategory *cat = [self selectedCategoryInBrowser:browser];
    return [cat.children objectAtIndex:row];
}


- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column {
    if (column == 0) {
        KTFolderCategory *fi = [self->doc.root.children objectAtIndex:row];
        [cell setStringValue:fi.localizedName];
    } else if (column == 1) {
        KTFolderInfo *fi = [[self selectedCategoryInBrowser:sender].children objectAtIndex:row];
        //[cell setStringValue:[fi displayName]];
        [cell bind:@"stringValue" toObject:fi withKeyPath:@"displayName" options:[NSDictionary dictionary]];
    } else if (column == 2) {
        KTFileInfo *fi = [[self selectedFolderInBrowser:sender].children objectAtIndex:row];
        //[cell setStringValue:[fi displayName]];
        [cell bind:@"stringValue" toObject:fi withKeyPath:@"displayName" options:[NSDictionary dictionary]];
        [cell setLeaf:YES];
    }
    //NSLog(@"willDisplay...r:%d c:%d", row, column);
}
- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column {
    //NSLog(@"numberOf...%d", column);
    if (column == 0) {
        return [self->doc.root.children count];
    } else if (column == 1) {
        KTFolderCategory *cat = [self selectedCategoryInBrowser:sender];
        return cat ? [cat.children count] : 0;
    } else if (column == 2) {
        KTFolderInfo *f = [self selectedFolderInBrowser:sender];
        return f ? [f.children count] : 0;
    } else return 0;
}
- (BOOL)browser:(NSBrowser *)sender selectRow:(NSInteger)row inColumn:(NSInteger)column {
    NSLog(@"selectRow:%d inColumn:%d", row, column);
    NSLog(@"selection index path:%@", [controller selectedObjects]/*[[controller selectionIndexPaths] objectAtIndex:0]*/);
    if (column == 1) {
        KTFolderCategory *cat = [self selectedCategoryInBrowser:sender];
        [folderInfoPanel showFolderInfoPanel:[[cat children] objectAtIndex:row]];
    } else {
        [folderInfoPanel hideFolderInfoPanel];
    }
    if (column == 2) {
        KTFolderInfo *fi = [self selectedFolderInBrowser:sender];
        [fileInfoPanel showFileInfoPanel:[[fi children] objectAtIndex:row]];
    } else {
        [fileInfoPanel hideFileInfoPanel];
    }
    return YES;
}
- (IBAction)browserClick:(NSBrowser *)sender {
    NSInteger column = [sender selectedColumn];
    [self browser:sender selectRow:[sender selectedRowInColumn:column] inColumn:column];
}
#endif

- (void)awakeFromNib {
    [controller addObserver:self forKeyPath:@"selectedObjects" options:NSKeyValueObservingOptionInitial context:NULL];
}

- (void)dealloc {
    [controller removeObserver:self forKeyPath:@"selectedObjects"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectedObjects"]) {
        id selectedObjects = [object selectedObjects];
        if ([selectedObjects count] > 0) {
            id selectedObject = [selectedObjects objectAtIndex:0];
            [folderInfoPanel hideFolderInfoPanel];
            [fileInfoPanel hideFileInfoPanel];
            if ([selectedObject isKindOfClass:[KTFolderInfo class]]) {
                [folderInfoPanel showFolderInfoPanel:selectedObject];
            } else if ([selectedObject isKindOfClass:[KTFileInfo class]]) {
                [fileInfoPanel showFileInfoPanel:selectedObject];
            }
        }
    }
}

@end
