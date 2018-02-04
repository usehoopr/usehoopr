//
//  CustomCameraViewController.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/27/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import UIKit
import AVFoundation

@available(iOS 10.2, *)
class CustomCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    @IBOutlet weak var cameraBtn: UIButton!
    
    let captureSession = AVCaptureSession()
    
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    
    var stillImageOutput: AVCapturePhotoOutput?
    var stillImage: UIImage?
    
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    var toggleCameraGestureRecognizer = UISwipeGestureRecognizer()
    
    var zoomInGestureRecognizer = UISwipeGestureRecognizer()
    var zoomOutGestureRecognizer = UISwipeGestureRecognizer()
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        //   let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]
        if #available(iOS 10.2, *) {
            let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
        } else {
            // Fallback on earlier versions
        }
        
        let devices = videoDeviceDiscoverySession.devices
        // Get the front and back-facing camera for taking photos
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backFacingCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontFacingCamera = device
            }
        }
        currentDevice = backFacingCamera
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            
            // Configure the session with the output for capturing still images
            stillImageOutput = AVCapturePhotoOutput()
            
            // Configure the session with the input and the output devices
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(stillImageOutput!)
            
            // Provide a camera preview
            cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            view.layer.addSublayer(cameraPreviewLayer!)
            cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cameraPreviewLayer?.frame = view.layer.frame
            
            // Bring the camera button to front
            view.bringSubview(toFront: cameraBtn)
            captureSession.startRunning()
        } catch {
            print(error)
        }
        
        // Toggle Camera recognizer
        toggleCameraGestureRecognizer.direction = .up
        toggleCameraGestureRecognizer.addTarget(self, action: #selector(toggleCamera))
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
        
        // Zoom In recognizer
        zoomInGestureRecognizer.direction = .right
        zoomInGestureRecognizer.addTarget(self, action: #selector(zoomIn))
        view.addGestureRecognizer(zoomInGestureRecognizer)
        
        // Zoom Out recognizer
        zoomOutGestureRecognizer.direction = .left
        zoomOutGestureRecognizer.addTarget(self, action: #selector(zoomOut))
        view.addGestureRecognizer(zoomOutGestureRecognizer)
        
    }
    
    @objc func toggleCamera() {
        captureSession.beginConfiguration()
        
        // Change the device based on the current camera
        let newDevice = (currentDevice?.position == AVCaptureDevice.Position.back) ? frontFacingCamera : backFacingCamera
        
        // Remove all inputs from the session
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        // Change to the new input
        let cameraInput:AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch {
            print(error)
            return
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        currentDevice = newDevice
        captureSession.commitConfiguration()
    }
    
    @objc func zoomIn() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor < 5.0 {
                let newZoomFactor = min(zoomFactor + 1.0, 5.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @objc func zoomOut() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor > 1.0 {
                let newZoomFactor = max(zoomFactor - 1.0, 1.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showPhoto" {
            let previewViewController = segue.destination as! PreviewViewController
            previewViewController.image = stillImage
        }
    }
    
    @IBAction func cameraBtn_TouchUpInside(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        self.stillImageOutput?.capturePhoto(with: settings, delegate: self)
        
        //        let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo)
        //
        //        stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
        //
        //            if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) {
        //                self.stillImage = UIImage(data: imageData)
        //                self.performSegue(withIdentifier: "showPhoto", sender: self)
        //            }
        //        })
    }
    
    
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            self.stillImage = UIImage(data: dataImage)
            self.performSegue(withIdentifier: "showPhoto", sender: self)
            
        }
        
    }
}

