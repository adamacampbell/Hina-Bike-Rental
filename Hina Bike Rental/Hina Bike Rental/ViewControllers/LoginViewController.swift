//
//  LoginViewController.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 01/02/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        initFields()
        self.hideKeyboardWhenUserTaps()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        let alert = UIAlertController(title: "Hello There!", message: "Welcome to the test build of Hina Bike Rental.\n\nFor the best results, please run this app on an actual iOS Device and not on a virtual machine. Virtual machines may cause some unknown errors and crashes.\n\nSome features have been disabled to allow for better testing conditions. As a result, your location will not be checked when renting a bike.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Start", style: .default, handler:
        { (action) in
            alert.dismiss(animated: true, completion: nil)
            AccountDetails.loadDetails()
            if self.checkIfLoggedIn()
            {
                //print(AccountDetails.userDetails.token)
                //self.performSegue(withIdentifier: "loginSegue", sender: self)
                self.attemptLogin(username: AccountDetails.userDetails.username, password: AccountDetails.userDetails.password)
            }
        }))
        self.present(alert, animated: true)
    }
    
    func initFields()
    {
        self.userNameField.delegate = self
        self.passwordField.delegate = self
        passwordField.isSecureTextEntry = true
    }
    
    /// Checks if the user is already logged in
    ///
    /// - Returns: True or False.
    func checkIfLoggedIn() -> Bool
    {
        if AccountDetails.userDetails.username != "-1" &&
        AccountDetails.userDetails.password != "-1" &&
        AccountDetails.userDetails.token != "-1"
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    @IBAction func loginButton(_ sender: Any)
    {
        login()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any)
    {
        //Open url for support page.
        if let url = URL(string: "https://hinabikeshare.ddns.net/register")
        {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag)
        {
            nextResponder.becomeFirstResponder()
        }
        else
        {
            self.view.endEditing(true)
            login()
        }
        return true
    }
    
    func login()
    {
        let username: String = userNameField.text!
        let password: String = passwordField.text!
        if username.isEmpty || password.isEmpty
        {
            createAlert(title: "Invalid Details", message: "Please enter details")
            return
        }
        else
        {
            attemptLogin(username: username, password: password)
        }
    }
    
    func attemptLogin(username: String, password: String)
    {
        // Access web service url.
        let serviceURL = "https://hinabikeshare.ddns.net/app/login?email=\(username)&pwd=\(password)"
        // Download JSON data.
        let url = URL(string: serviceURL)
        if let url = url
        {
            // Create a URL Session
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler:
            {
                (data, response, error) in
                if error == nil
                {
                    // Succeeded.
                    self.parseData(data: data!, username: username, password: password)
                }
                else
                {
                    // Error ocurred.
                }
            })
            task.resume()
        }
    }
    
    // Parse JSON object into user struct.
    func parseData(data: Data, username: String, password: String)
    {
        do
        {
            let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            print(jsonDictionary)
            print("+++++++++++++++++++++++++++++++++++++++++++++++++++++")
            let status = jsonDictionary["status"] as! Int
            if status == 0
            {
                DispatchQueue.main.async
                { [weak self] in
                    self?.createAlert(title: "Invalid Details", message: "Please check your login details.")
                }
                return
            }
            else
            {
                let token = jsonDictionary["token"] as! String
                DispatchQueue.main.async
                { [weak self] in
                    self?.storeLoginDetails(username: username, password: password, token: token)
                    self?.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            }
        }
        catch
        {
            print("Error: Error retrieving JSON Data.")
            DispatchQueue.main.async
            { [weak self] in
                self?.createAlert(title: "Error", message: "Couldn't contact login server.")
            }
        }
    }

    // Store user's login details locally.
    func storeLoginDetails(username: String, password: String, token: String)
    {
        AccountDetails.userDetails.username = username
        AccountDetails.userDetails.password = password
        AccountDetails.userDetails.token = token
        AccountDetails.storeDetails()
    }
    
    /**
     *createAlert
     *Function for displaying an alert to the user (Only has OK button).
     *@param title - Used to set the title of the Alert.
     *@param message - Used to sett the message of the Alert.
     **/
    func createAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIViewController
{
    func hideKeyboardWhenUserTaps()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
