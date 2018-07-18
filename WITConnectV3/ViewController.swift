//
//  ViewController.swift
//  WITConnectV3
//
//  Created by Zachary Gagnon on 6/29/18.
//  Copyright © 2018 Zachary Gagnon. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController , UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginPressed() {
        print("Login Pressed")
        if (emailTextField.text == "" || passwordTextField.text == "") {
            let alertController = UIAlertController(title: "Error", message: "Please double check your credentials", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        }else {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in if error == nil {
                print("You have successfully Logged in!")
                self.performSegue(withIdentifier: "toHome", sender: nil)
                }
            }
        }
        
    }
    
    @IBAction func LoginSignUpPressed(_ sender: Any) {
        let SignUpViewController = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        present(SignUpViewController, animated:  true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
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
        // Dispose of any resources that can be recreated.
    }
}

