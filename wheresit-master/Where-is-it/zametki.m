
//пост на стену в альбом другу

/*
NSLog(@"sending post");
    for(id<FBGraphUser> user in self.selectedFriends)
    {
        NSString* userID = user.id;
        NSLog(@"Попытка постинга фото %@, %@", userID, user.name);
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:UIImagePNGRepresentation(self.selectedPhoto) forKey:@"picture"];
        
        ////        userID = @"me";
        //    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/photos",userID] parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        //        if(!error){
        //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Sharing succesfull" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        //            [alert show];
        //        }else{
        //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        //            [alert show];
        //        }
        //    }];
        
        
    }
*/
//Цикл по всем выбраным друзьям - пост каждому 
/*
    for(id<FBGraphUser> user in self.selectedFriends)
    {
        NSString* userID = user.id;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:@"http://fbrell.com/f8.jpg" forKey:@"picture"];
        [params setObject:@"feed" forKey:@"method"];
        [params setObject:userID forKey:@"to"];
        [params setObject:@"look" forKey:@"caption"];
        [params setObject:@"Where is it link" forKey:@"name"];
        [params setObject:@"Посмотри где я!!!" forKey:@"description"];
        [params setObject:self.selectedPlace.id forKey:@"place"];
        [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
            if(error){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
            else{
                if(result == FBWebDialogResultDialogNotCompleted){
                    NSLog(@"PUBLISH CANCELED");
                }
                else{
                    NSLog(@"H Z");
                    
                }
            }
        }];
    }
*/    

