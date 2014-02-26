//
//  CollectionViewController.m
//  Where-is-it
//
//  Created by Mac on 06.09.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//

#import "CollectionViewController.h"
#import "SinglePhotoViewController.h"
@interface CollectionViewController (){
    NSMutableArray *photos;
    
}
@end

@implementation CollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *cellNib = [UINib nibWithNibName:@"CollectionCell" bundle:nil];
    [self.CollectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvcell"];
    
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    [flowLayout setItemSize:CGSizeMake(150, 150)];
//    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
//    [self.CollectionView setCollectionViewLayout:flowLayout];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSLog(@"filelist count %i",[filelist count]);
    
    photos = [[NSMutableArray alloc] init];
    int x = 0;
    int y = 0;
    for(int i = 0; i < [filelist count]/2; i++){
        if(x == 3){
            y++;
            x = 0;
        }
        NSString *pathstr = [NSString stringWithFormat:@"imageName%i.png",i+1];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:pathstr];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        [photos addObject:image];
        x++;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return photos.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIdentifier = @"cvcell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    UIImageView *recipeImageView = (UIImageView *)[ cell viewWithTag:100];
    recipeImageView.image = (UIImage*) [photos objectAtIndex:indexPath.row];
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.navigationController.navigationBarHidden = NO;
    SinglePhotoViewController *singlePhoto = [[SinglePhotoViewController alloc] initWithNibName:@"SinglePhotoViewController" bundle:nil];
    singlePhoto.detailItem = indexPath.row;
    singlePhoto.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:singlePhoto animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCollectionCell:nil];
    [self setCollectionView:nil];
    [super viewDidUnload];
}
@end
