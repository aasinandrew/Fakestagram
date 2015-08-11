//
//  ViewController.m
//  Fakestagram
//
//  Created by Andrew  Nguyen on 8/10/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    PFUser *user = [PFUser currentUser];
    if ([user isAuthenticated]) {
        [self performSegueWithIdentifier:@"login" sender:self];
    }

}

-(void)viewDidAppear:(BOOL)animated {

    PFUser *user = [PFUser currentUser];
    if ([user isAuthenticated]) {
        [self performSegueWithIdentifier:@"login" sender:self];
    }

}

- (IBAction)loginButtonPressed:(UIButton *)sender {

    //PFUser *user = [PFUser currentUser];
    [PFUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passwordTextField.text];
    [self performSegueWithIdentifier:@"login" sender:self];


//    PFUser.logInWithUsernameInBackground(userTextField.text, password: passwordTextField.text) { user, error in
//        if user != nil {
//            self.performSegueWithIdentifier(self.tableViewWallSegue, sender: nil)
//        } else if let error = error {
//            self.showErrorView(error)
//        }
//    }

}


- (IBAction)signUpButtonPressed:(UIButton *)sender {

    PFUser *user = [PFUser new];

    user.username = self.userNameTextField.text;
    user.password = self.passwordTextField.text;

    [user signUpInBackground];
}

-(IBAction)unWindToLogin:(UIStoryboardSegue *)segue {
    // Logout user
    
}

@end
