//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import AVFoundation
import UIKit

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK: IBOutlets
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var topbar: UIView!
    
    //MARK: Properties
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    let supportedBarcodeTypes = [AVMetadataObjectTypeUPCECode,
                                 AVMetadataObjectTypeCode39Code,
                                 AVMetadataObjectTypeCode39Mod43Code,
                                 AVMetadataObjectTypeCode93Code,
                                 AVMetadataObjectTypeCode128Code,
                                 AVMetadataObjectTypeEAN8Code,
                                 AVMetadataObjectTypeEAN13Code,
                                 AVMetadataObjectTypeAztecCode,
                                 AVMetadataObjectTypePDF417Code,
                                 AVMetadataObjectTypeQRCode]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCaptureDeviceAndScan()
    }
    
    func createCaptureDeviceAndScan() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            captureMetadataOutput.metadataObjectTypes = supportedBarcodeTypes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            if let previewLayer = videoPreviewLayer {
                view.layer.addSublayer(previewLayer)
            }
            captureSession?.startRunning()
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: topbar)
            
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
        } catch {
            print(error)
            return
        }
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputMetadataObjects metadataObjects: [Any]!,
                       from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code or barcode detected"
            return
        }
        let metaDataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedBarcodeTypes.contains(metaDataObject.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metaDataObject)
            if let barCodeObjectBounds = barCodeObject?.bounds {
                qrCodeFrameView?.frame = barCodeObjectBounds
            }
            if metaDataObject.stringValue != nil {
                messageLabel.text = metaDataObject.stringValue
            }
        }
    }
}
