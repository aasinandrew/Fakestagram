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

@interface LoginViewController () <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;


@end


@implementation LoginViewController


#pragma mark - VC and LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self authenticateUser];
    [self buttonSetup];

}


-(void)viewDidAppear:(BOOL)animated {

    [self authenticateUser];
}


-(void)authenticateUser {
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


#pragma mark - Helper Method 

-(void)showErrorMessage:(NSError *) error {
    
    NSString *errorMessage = error.userInfo[@"error"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Failed" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Button methods 

- (IBAction)loginButtonPressed:(UIButton *)sender {

    [PFUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {

        if (user != nil) {
            [self performSegueWithIdentifier:@"login" sender:self];
        } else {
            [self showErrorMessage:error];

        }
    }];

}


- (IBAction)signUpButtonPressed:(UIButton *)sender {

    PFUser *user = [PFUser new];

    user.username = self.userNameTextField.text;
    user.password = self.passwordTextField.text;

    [user signUpInBackground];
}



#pragma mark - textField Delegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [PFUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        
        if (user != nil) {
            [self performSegueWithIdentifier:@"login" sender:self];
        } else {
            [self showErrorMessage:error];
            
        }
    }];
    
    return NO;
}

#pragma mark - Segue 

-(IBAction)unWindToLogin:(UIStoryboardSegue *)segue {
    [PFUser logOut];

    self.userNameTextField.text = @"";
    self.passwordTextField.text = @"";
}


@end
