//
//  QRCodeViewController.swift
//  WITConnectV3
//
//  Created by Zachary Gagnon on 6/29/18.
//  Copyright © 2018 Zachary Gagnon. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func QRScannerHome(_ sender: Any) {
        let QRGenViewController = storyboard?.instantiateViewController(withIdentifier: "QRGenViewController") as! QRGenViewController
        present(QRGenViewController, animated:  true, completion: nil)
        
    }
    @IBAction func QRCodeScan(_ sender: Any) {
        let QRScannerController = storyboard?.instantiateViewController(withIdentifier: "QRScannerController") as! QRScannerController
        present(QRScannerController, animated:  true, completion: nil)
        
    }
    
}
