//
//  SignUpViewController.swift
//  WITConnectV3
//
//  Created by Zachary Gagnon on 6/29/18.
//  Copyright © 2018 Zachary Gagnon. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignUpViewController: UIViewController , UITextFieldDelegate {

    var ref: DatabaseReference!
    var defaults = UserDefaults.standard
    
    
    @IBOutlet weak var SignUpEmailTextField: UITextField!
    @IBOutlet weak var SignUpPasswordTextField: UITextField!
    @IBOutlet weak var SignFirstNameTextField: UITextField!
    @IBOutlet weak var SignUpLastNameTextField: UITextField!
    @IBOutlet weak var SignUpWITIDTextField: UITextField!
    @IBOutlet weak var SignUpConfirmPasswordTextField: UITextField!
    
    @IBAction func SignUpCancel(_ sender: Any) {
        let Viewcontroller = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        present(Viewcontroller, animated:  true, completion: nil)
        
    }
    @IBAction func signupPressed() {
        print("Sign-up Pressed")
        var a = false
        var b = false
        
        if (SignUpEmailTextField.text == "" ||
            SignUpPasswordTextField.text == "" ||
            SignFirstNameTextField.text == "" ||
            SignUpLastNameTextField.text == "" ||
            SignUpWITIDTextField.text == "" ||
                SignUpConfirmPasswordTextField.text == "") {
            let alertController = UIAlertController(title: "Error", message: "Please double check your credentials!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        }else{
            b = true
        }
            if(SignUpPasswordTextField.text == SignUpConfirmPasswordTextField.text) {
                    a = true
         }else{
                let alertController = UIAlertController(title: "Error", message: "Your passwords don't match!", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
        }
                if a == true && b == true {
            guard let email = SignUpEmailTextField.text else { return }
            guard let password = SignUpPasswordTextField.text else {return}
            guard let fname = SignFirstNameTextField.text else { return }
            guard let lname = SignUpLastNameTextField.text else {return}
            guard let witID = SignUpWITIDTextField.text else {return}
                    let blockChainID = ""
                    
            let userData: [String: Any] = [
                        "FirstName" : fname,
                        "Email" : email,
                        "LastName" : lname,
                        "WITNumeber" : witID,
                        "BlockChainAcc" : blockChainID
                        
                ]
            
            
            Auth.auth().createUserAndRetrieveData(withEmail: email, password: password) { (result, error) in if error == nil {
                guard let uid = result?.user.uid else { return }
                self.ref.child("users/\(uid)").setValue(userData)
                self.defaults.set(false, forKey: "UserIsLoggedIn")
                self.ref.child("users/\(uid)").setValue(userData)
                self.defaults.set(false, forKey: "UserIsLoggedIn")
                print("You have successfully signed up!")
                let Viewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                self.present(Viewcontroller, animated:  true, completion: nil)
                
                }
            }
        }
    }
override func viewDidLoad() {
    ref = Database.database().reference()
  super.viewDidLoad()
    SignUpEmailTextField.delegate = self
    SignFirstNameTextField.delegate = self
    SignUpLastNameTextField.delegate = self
    SignUpWITIDTextField.delegate = self
    SignUpPasswordTextField.delegate = self
    SignUpConfirmPasswordTextField.delegate = self
}
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    }

}
