//
//  QRScannerController.swift
//  WITConnectV3
//
//  Created by Zachary Gagnon on 6/29/18.
//  Copyright © 2018 Zachary Gagnon. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    var ref: DatabaseReference!
    @IBAction func QRCodeScanHome(_ sender: Any) {
        let QRGenViewController = storyboard?.instantiateViewController(withIdentifier: "QRGenViewController") as! QRGenViewController
        present(QRGenViewController, animated:  true, completion: nil)
    }
        var captureSession = AVCaptureSession()
        var videoPreviewLayer: AVCaptureVideoPreviewLayer?
        var initialized = false
        
        let barCodeTypes = [AVMetadataObject.ObjectType.upce,
                            AVMetadataObject.ObjectType.code39,
                            AVMetadataObject.ObjectType.code39Mod43,
                            AVMetadataObject.ObjectType.code93,
                            AVMetadataObject.ObjectType.code128,
                            AVMetadataObject.ObjectType.ean8,
                            AVMetadataObject.ObjectType.ean13,
                            AVMetadataObject.ObjectType.aztec,
                            AVMetadataObject.ObjectType.pdf417,
                            AVMetadataObject.ObjectType.itf14,
                            AVMetadataObject.ObjectType.dataMatrix,
                            AVMetadataObject.ObjectType.interleaved2of5,
                            AVMetadataObject.ObjectType.qr]
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.title = "Bar Code Scanner"
            ref = Database.database().reference()
            
    }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            setupCapture()
            // set observer for UIApplicationWillEnterForeground, so we know when to start the capture session again
            // if the user switches to another app (e.g. Safari) then comes back
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        }
        
        // This is called when we return from Safari or another app to the scanner view
        @objc func willEnterForeground() {
            setupCapture()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            // this view is no longer topmost in the app, so we don't need a callback if we return to the app.
            NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        }
        
        func setupCapture() {
            var success = false
            var accessDenied = false
            var accessRequested = false
            
            
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if authorizationStatus == .notDetermined {
                // permission dialog not yet presented, request authorization
                accessRequested = true
                AVCaptureDevice.requestAccess(for: .video,
                                              completionHandler: { (granted:Bool) -> Void in
                                                self.setupCapture();
                })
                return
            }
            if authorizationStatus == .restricted || authorizationStatus == .denied {
                accessDenied = true
            }
            
            if initialized {
                success = true
            }
            else {
                let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
                
                if let captureDevice = deviceDiscoverySession.devices.first {
                    do {
                        let videoInput = try AVCaptureDeviceInput(device: captureDevice)
                        captureSession.addInput(videoInput)
                        success = true
                    } catch {
                        NSLog("Cannot construct capture device input")
                    }
                }
                else {
                    NSLog("Cannot get capture device")
                }
                
                if success {
                    let captureMetadataOutput = AVCaptureMetadataOutput()
                    captureSession.addOutput(captureMetadataOutput)
                    let newSerialQueue = DispatchQueue(label: "barCodeScannerQueue") // in iOS 11 you can use main queue
                    captureMetadataOutput.setMetadataObjectsDelegate(self, queue: newSerialQueue)
                    captureMetadataOutput.metadataObjectTypes = barCodeTypes
                    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    videoPreviewLayer?.videoGravity = .resizeAspectFill
                    videoPreviewLayer?.frame = view.layer.bounds
                    view.layer.addSublayer(videoPreviewLayer!)
                    initialized = true
                }
            }
            if success {
                captureSession.startRunning()
            }
            
            if !success {
                
                if !accessRequested {
                    // Generic message if we cannot figure out why we cannot establish a camera session
                    var message = "Cannot access camera to scan bar codes"
                    #if (arch(i386) || arch(x86_64)) && (!os(macOS))
                        message = "You are running on the simulator, which does not have a camera device.  Try this on a real iOS device."
                    #endif
                    if accessDenied {
                        message = "You have denied this app permission to access to the camera.  Please go to settings and enable camera access permission to be able to scan bar codes"
                    }
                    let alertPrompt = UIAlertController(title: "Cannot access camera", message: message, preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alertPrompt.addAction(confirmAction)
                    self.present(alertPrompt, animated: true, completion: {
                    })
                }
            }
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            processBarCodeData(metadataObjects: metadataObjects)
        }
        func processBarCodeData(metadataObjects: [AVMetadataObject]) {
            
            
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                if barCodeTypes.contains(metadataObject.type) {
                    if metadataObject.stringValue != nil {
                        captureSession.stopRunning()
                        displayBarCodeResult(code: metadataObject.stringValue!)
                        return
                    }
                }
            }
        }
        func displayBarCodeResult(code: String) {
            let alertPrompt = UIAlertController(title: "QR code detected", message: code, preferredStyle: .alert)
            
            alertPrompt.addTextField { (textField) in
                textField.placeholder = "Transfer WITCoin"
                textField.keyboardType = .numberPad
                let values = ["transferAmount": textField.text ?? "10"]
                let userId = Auth.auth().currentUser?.uid
                self.ref.child("users").child(userId!).updateChildValues(["TransferAmount": values])
                self.ref.updateChildValues(values)
            }
        
            let unlock = UIAlertAction(title: "Unlock Door", style: .default) { (action) in
                print("Attempting to Unlock")
                let qrdataunlock = ["qrCodeMetaData": code]
                let userId = Auth.auth().currentUser?.uid
                
                self.ref.child("users").child(userId!).updateChildValues(["QRCodeMetaData": qrdataunlock])
//Send qr code of door to firebase
                self.ref.updateChildValues(qrdataunlock)
//retrieve DoorStatus
                let userID = Auth.auth().currentUser?.uid
                self.ref.child("users").child(userID!).observeSingleEvent(of: .value) {(snapshot) in
                    let data = snapshot.value as? NSDictionary
                    let doorStatus = data?["DoorStatus"] as? String
                    let DoorStatusAlert =  DoorStat(DoorStatus: doorStatus)
                    print(DoorStatusAlert)
                    let alertPrompt = UIAlertController(title: "Unlocking door", message: DoorStatusAlert as Any as? String, preferredStyle: .alert)
                        self.present(alertPrompt, animated: true, completion: {
                        self.setupCapture()
                            })
                    
            }
        }
            let transfer = UIAlertAction(title: "Transfer", style: .default) { (action) in
                let qrdatatransfer = ["qrCodeMetaData": code]
                let userId = Auth.auth().currentUser?.uid
                self.ref.child("users").child(userId!).updateChildValues(["QRCodeMetaData": qrdatatransfer])
                self.ref.updateChildValues(qrdatatransfer)
                self.setupCapture()
                print("Transfering Currency")
                print(alertPrompt.textFields?.first?.text! ?? 0)
                let values = ["transferAmount": alertPrompt.textFields?.first?.text! ?? "100"]
                self.ref.child("users").child(userId!).updateChildValues(["TransferAmount": values])
                self.ref.updateChildValues(values)
                self.setupCapture()
                //take entered amount and send to firebase
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.setupCapture()
                print("Cancelled")
            }
           alertPrompt.addAction(unlock)
           alertPrompt.addAction(transfer)
           alertPrompt.addAction(cancel)
           present(alertPrompt, animated: true, completion: nil)
    }
}
