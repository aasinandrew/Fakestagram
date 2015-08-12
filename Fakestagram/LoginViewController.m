//
//  ViewController.m
//  Fakestagram
//
//  Created by Andrew  Nguyen on 8/10/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@end

@implementation LoginViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    PFUser *user = [PFUser currentUser];
    if ([user isAuthenticated]) {
        [self performSegueWithIdentifier:@"login" sender:self];
    }

    [self buttonSetup];

}

-(void)viewDidAppear:(BOOL)animated {

    PFUser *user = [PFUser currentUser];
    if ([user isAuthenticated]) {
        [self performSegueWithIdentifier:@"login" sender:self];
    }

}

- (void)buttonSetup {
    self.loginButton.layer.borderWidth = 1.0;
    self.loginButton.layer.borderColor = [UIColor whiteColor].CGColor;

    self.signupButton.layer.borderWidth = 1.0;
    self.signupButton.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (IBAction)loginButtonPressed:(UIButton *)sender {

    //PFUser *user = [PFUser currentUser];

    [PFUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {

        if (user != nil) {
            [self performSegueWithIdentifier:@"login" sender:self];
        } else {
            // Someone does AlertController like ray

        }
    }];



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
    [PFUser logOut];

    self.userNameTextField.text = @"";
    self.passwordTextField.text = @"";
}

@end
