//
//  ValidatorViewController.m
//  AnimatedValidator
//
//  Created by Al Tyus on 5/12/14.
//  Copyright (c) 2014 al-tyus.com. All rights reserved.
//

#import "ValidatorViewController.h"
#import "Constants.h"

@interface ValidatorViewController ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailConfirmTextField;
@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *constraintShowSubmitButton;
@property (nonatomic, strong) NSMutableArray *blankTextFields;
@property (nonatomic, strong) NSMutableArray *invalidTextFields;
@property (nonatomic) BOOL animating;

@end

@implementation ValidatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.submitButton.accessibilityLabel = SUBMITBUTTON;
    self.emailTextField.accessibilityLabel = EMAILTEXTFIELD;
    self.emailConfirmTextField.accessibilityLabel = EMAILCONFIRMTEXTFIELD;
    self.phoneTextField.accessibilityLabel = PHONETEXTFIELD;
    self.passwordTextField.accessibilityLabel = PASSWORDTEXTFIELD;
    self.passwordConfirmTextField.accessibilityLabel = PASSWORDCONFIRMTEXTFIELD;
    
    [self setBlankTextFields:[NSMutableArray arrayWithArray:@[self.emailTextField, self.emailConfirmTextField, self.phoneTextField, self.passwordTextField, self.passwordConfirmTextField]]];
    
    [self.submitButton setUserInteractionEnabled:NO];
    [self.constraintShowSubmitButton setActive:NO];
    
    [self setInvalidTextFields:[NSMutableArray array]];
    [self setAnimating:NO];
    
}

- (IBAction)textFieldChanged:(UITextField *)sender {
    
    if ([self textFieldHasValidInput:sender] || !sender.text.length) {
        [self.invalidTextFields removeObject:sender];
        [sender.layer removeAllAnimations];
        [sender setBackgroundColor:[UIColor whiteColor]];
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [sender setTransform:transform];
        if (sender.text.length) {
            [self.blankTextFields removeObject:sender];
        }
        else {
            [self.blankTextFields addObject:sender];
        }
    }
    
    BOOL showSubmitButton = (!self.invalidTextFields.count && !self.blankTextFields.count && [self textFieldHasValidInput:sender]);
    [self.submitButton setUserInteractionEnabled:showSubmitButton];
    [self.constraintShowSubmitButton setActive:showSubmitButton];
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.5f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)validateTextField:(UITextField *)sender {
    
    if (![self textFieldHasValidInput:sender] && sender.text.length) {
        [self.invalidTextFields addObject:sender];
        [self animateTextFields];
    }
}

- (BOOL)textFieldHasValidInput:(UITextField *)textField {
    
    if ([textField isEqual:self.emailTextField]) {
        
        NSArray *emailComponents = [textField.text componentsSeparatedByString:@"@"];
        if (emailComponents.count != 2) return NO;
        
        NSString *local = emailComponents[0];
        NSString *domain = emailComponents[1];
        NSMutableCharacterSet *validLocalCharacters = [NSMutableCharacterSet alphanumericCharacterSet];
        [validLocalCharacters addCharactersInString:@".-_+"];
        NSMutableCharacterSet *validDomainCharacters = [NSMutableCharacterSet alphanumericCharacterSet];
        [validDomainCharacters addCharactersInString:@".-"];
        
        if ([local stringByTrimmingCharactersInSet:validLocalCharacters].length+[domain stringByTrimmingCharactersInSet:validDomainCharacters].length) return NO;
        
        if (![domain containsString:@"."]) return NO;
        
        return YES;
    }
    
    if ([textField isEqual:self.emailConfirmTextField]) {
        
        return [textField.text isEqualToString:self.emailTextField.text];
    }
    
    if ([textField isEqual:self.phoneTextField]) {
        
        if (textField.text.length < 7) return NO;
        
        NSCharacterSet *validPhoneCharacters = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
        if ([textField.text stringByTrimmingCharactersInSet:validPhoneCharacters].length) return NO;
        
        return YES;
    }
    
    if ([textField isEqual:self.passwordTextField]) {
        
        if (textField.text.length < 6) return NO;
        
        return YES;
    }
    
    if ([textField isEqual:self.passwordConfirmTextField]) {
        
        if (![textField.text isEqualToString:self.passwordTextField.text]) return NO;
        
        return YES;
    }
    
    return YES;
}

- (void)animateTextFields {
    
    if (!self.invalidTextFields.count) [self setAnimating:NO];
    if (self.animating) return;
    
    [self setAnimating:YES];
    NSTimeInterval animationDuration = 1.0f;
    CGFloat transformScale = 1.1f;
    
    [UIView animateWithDuration:animationDuration*0.5f animations:^{
        for (UITextField *textField in self.invalidTextFields) {
            [textField setBackgroundColor:[UIColor redColor]];
            CGAffineTransform transform = CGAffineTransformMakeScale(transformScale, transformScale);
            [textField setTransform:transform];
        }
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:animationDuration*0.5f animations:^{
            for (UITextField *textField in self.invalidTextFields) {
                [textField setBackgroundColor:[UIColor whiteColor]];
                CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                [textField setTransform:transform];
            }
        } completion:^(BOOL finished) {
            
            [self setAnimating:NO];
            [self animateTextFields];
        }];
    }];
}


@end
