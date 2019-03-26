//
//  BarcodeController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 12/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import AVFoundation
import UIKit

class BarcodeController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    private var repository: MovementArticleProtocol
    private var service: ServiceProtocol
    
    required init?(coder aDecoder: NSCoder) {
        repository = IoCContainer.shared.resolve() as MovementArticleProtocol
        service = IoCContainer.shared.resolve() as ServiceProtocol
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        if videoCaptureDevice == nil {
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.pdf417]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        previewLayer.frame = view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        view.layer.addSublayer(previewLayer);
        
        captureSession.startRunning();
    }
    
    func failed() {
        self.navigationController?.alert(title: "NoScanning".locale, message: "UseDeviceWithCamera".locale)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        read()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: readableObject.stringValue!);
        }
        
        dismiss(animated: true)
    }
    
    func read() {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if (self.captureSession?.isRunning == false) {
                self.captureSession.startRunning();
            }
        }
    }
    
    func found(code: String) {
        do {
            if try repository.add(barcode: code, movementId: Synchronizer.shared.movement.movementId) == false {
                service.push(title: "Attention".locale, message: "Barcode".locale + " " +  code + " " + "NotFound".locale)
            }
        } catch {
            service.push(title: "Error".locale, message: error.localizedDescription)
        }
        
        read()
    }
}
