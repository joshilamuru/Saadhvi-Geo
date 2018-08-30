//
//  DualCameraViewController.swift
//  GeoTenX
//
//  Created by saadhvi on 8/27/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Eureka


class DualCameraViewController: UIViewController {
   
   
    @IBOutlet weak var camBtn: RoundButton!
    
    @IBOutlet weak var ContainerUIView: UIView!
    
    @IBOutlet weak var backImageView: UIImageView!
    
    @IBOutlet weak var frontImageView: UIImageView!
    var captureSession = AVCaptureSession()
    
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var cameraFrontPreviewLayer: AVCaptureVideoPreviewLayer?
    var image, backImg, frontImg, mergedImage: UIImage?
    
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    @IBAction func camBtnPressed(_ sender: Any) {
        (sender as? UIButton)?.isEnabled = false
        (sender as? UIButton)?.isHidden = true
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        
       
        
    }
    func setupCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        
        let devices = self.discoverySession.devices
        for device in devices{
            if device.position == .back {
                backFacingCamera = device
            }else if device.position == .front {
                frontFacingCamera = device
            }
        }
        //default device
        currentDevice = backFacingCamera
    }
    
    
    
    func  setupInputOutput(){
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
        photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            if (captureSession.canAddOutput(photoOutput!)) {
                captureSession.addOutput(photoOutput!)
            } else {
                print("cannot add output")
            }
            
        }catch{
            print(error)
        }
        
        
    }
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
       // cameraPreviewLayer?.frame = backImageView.bounds
        
       /// backImageView.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        cameraPreviewLayer?.frame = self.view.bounds
        ContainerUIView.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      
    //  cameraPreviewLayer?.frame = self.view.frame
        cameraPreviewLayer?.frame = self.view.bounds
    }
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    func image(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoSegue"{
            let previewVC = segue.destination as! PreviewViewController
            mergedImage = ContainerUIView.capture()
            //mergedImage = image(view: ContainerUIView)
            previewVC.mergeImage = mergedImage
            navigationItem.title = " "
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if captureSession.isRunning {
            DispatchQueue.global().async {
                if let inputs = self.captureSession.inputs as? [AVCaptureDeviceInput] {
                    for input in inputs {
                        self.captureSession.removeInput(input)
                    }
                }
              
                
                self.captureSession.stopRunning()
            }
        }
    }
}

extension DualCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            print(imageData)
            image = UIImage(data: imageData)
            if(currentDevice == backFacingCamera){
                backImageView.image = image
              
                backImg = image
                
                getFrontCameraImage()
            }else {
                
                frontImageView.image = image
              
                frontImg = image
               captureSession.stopRunning()
               
                sleep(2)
               // mergedImage = ContainerUIView.capture()
          
                performSegue(withIdentifier: "showPhotoSegue", sender: nil)
                
                
               
            }
            
            
        //
        }
        
    }
    
    func getFrontCameraImage(){
        captureSession.beginConfiguration()
        
        let newDevice = (currentDevice?.position == .back) ?
            frontFacingCamera : backFacingCamera
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        let cameraInput: AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice!)
            
        }catch let error {
            print(error)
            return
        }
       
        
//        if captureSession.canAddInput(cameraInput){
//            captureSession.addInput(cameraInput)
//        }
        if captureSession.inputs.isEmpty {
            self.captureSession.addInput(cameraInput)
        }
        
        currentDevice = newDevice
//        
       let replicateLayer = CAReplicatorLayer()
        
        replicateLayer.frame = ContainerUIView.frame
        //replicateLayer.addSublayer(cameraPreviewLayer!)
        ContainerUIView.layer.addSublayer(replicateLayer)
        //ContainerUIView.layer.insertSublayer(replicateLayer, at: 0)
        
        
        captureSession.commitConfiguration()
       
        let settings = AVCapturePhotoSettings()
        sleep(1)
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
}
