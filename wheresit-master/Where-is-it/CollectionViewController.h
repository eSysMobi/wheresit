//
//  CollectionViewController.h
//  Where-is-it
//
//  Created by Mac on 06.09.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionView;
@property (strong, nonatomic) IBOutlet UICollectionViewCell *CollectionCell;

@end
