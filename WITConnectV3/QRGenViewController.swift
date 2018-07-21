//
//  QRGenViewController.swift
//  WITConnectV3
//
//  Created by Zachary Gagnon on 6/29/18.
//  Copyright © 2018 Zachary Gagnon. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class QRGenViewController: UIViewController {
    var appUser: AppUser? {
        didSet {
            print("value set")
            guard let userFName = appUser?.FirstName else { return }
            guard let userLName = appUser?.LastName else { return }
            print(userFName)
            print(userLName)
            self.SignUpuserNameTextField.text = userFName
            let image = self.generateQRCode(from: userLName)
            self.imageView.image = image
        }
    }
    var ref: DatabaseReference!
    @IBOutlet var SignUpuserNameTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBAction func QRGenLogout(_ sender: Any) {
        let Viewcontroller = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        present(Viewcontroller, animated:  true, completion: nil)
        
    }
    @IBAction func QRScanner(_ sender: Any) {
        let QRCodeViewController = storyboard?.instantiateViewController(withIdentifier: "QRCodeViewController") as! QRCodeViewController
        present(QRCodeViewController, animated:  true, completion: nil)
    }
    override func viewDidLoad() {
        ref = Database.database().reference()
        fetchUserInfo()
        //let image = self.generateQRCode(from: message)
        //self.imageView.image = image
        super.viewDidLoad()
        }
    
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.isoLatin1)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator"){
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX:3, y:3)
            
            if let output = filter.outputImage?.transformed(by: transform){
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    func fetchUserInfo() {
        let userId = Auth.auth().currentUser?.uid
        ref.child("users").child(userId!).observeSingleEvent(of: .value) {(snapshot) in
            let data = snapshot.value as? NSDictionary
            let email = data?["Email"] as? String
            let fname = data?["FirstName"] as? String
            let lname = data?["LastName"] as? String
            let witID = data?["WITNumber"] as? String
            let blockChainID = data?["BlockChainAcc"] as? String
            let transferAmount = data?["TransferAmount"] as? String
            let doorStatus = data?["DoorStatus"] as? String
            let qrCodeMetaData = data?["QRCodeMetaData"] as? String
            self.appUser = AppUser(Email: email, FirstName: fname, LastName: lname, uid: userId, WitNumber: witID, BlockChainAcc: blockChainID, TransferAmount: transferAmount, DoorStatus: doorStatus, QRCodeMetaData: qrCodeMetaData)
        }
    }
}
