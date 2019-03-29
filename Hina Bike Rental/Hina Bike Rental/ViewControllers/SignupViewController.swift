//
//  SignupViewController.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 01/02/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confPasswordField: UITextField!
    
    private var datePicker: UIDatePicker?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        initFields()
        
    }
    
    func initFields() {
        
        self.nameField.delegate = self
        self.userNameField.delegate = self
        self.emailField.delegate = self
        self.phoneField.delegate = self
        self.dobField.delegate = self
        self.passwordField.delegate = self
        self.confPasswordField.delegate = self
        emailField.keyboardType = UIKeyboardType.emailAddress
        phoneField.keyboardType = UIKeyboardType.numberPad
        passwordField.isSecureTextEntry = true
        confPasswordField.isSecureTextEntry = true
        
        datePicker = UIDatePicker()
        let calendar = Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.year = -16
        let maxDate = calendar.date(byAdding: comps, to: Date())
        datePicker?.maximumDate = maxDate
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(SignupViewController.dateChanged(datePicker:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        dobField.inputView = datePicker
        
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        
        view.endEditing(true)
        
    }

    @objc func dateChanged(datePicker: UIDatePicker) {
        
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "dd/MM/yyyy"
        dobField.text = dateFomatter.string(from: datePicker.date)
        view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            
            nextResponder.becomeFirstResponder()
            
        } else {
            
            self.view.endEditing(true)
            signUp()
            
        }
        
        return true
        
    }
    
    func signUp () {
        
        
        
    }
    
}
