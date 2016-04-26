//
//  CaptureViewController.swift
//  joggers
//
//  Created by Long Baolin on 16/4/18.
//  Copyright © 2016年 Lintasty. All rights reserved.
//

import UIKit
import AVFoundation

private let ShowPhotoSegueIdentifier = "showPhoto"

class CaptureViewController: UIViewController {

    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private lazy var captureSession = AVCaptureSession()
    
    private var backFacingCamera: AVCaptureDevice?
    private var frontFacingCamera: AVCaptureDevice?
    private var currentDevice: AVCaptureDevice?

    private var stillImageOutput: AVCaptureStillImageOutput?
    private var stillImage: UIImage?

    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //And Gestures
    private lazy var toggleCameraGestureRecognizer = UISwipeGestureRecognizer()
    private lazy var zoomInGestureRecognizer = UISwipeGestureRecognizer()
    private lazy var zoomOutGestureRecognizer = UISwipeGestureRecognizer()
  
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置拍照按钮为圆形
        captureButton.layer.cornerRadius = captureButton.layer.bounds.width/2
        //在收到选择好照片的通知后关闭视图
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(dismissViewConroller), name: PhotoCaptureNotification.photoChoosedNotificationName, object: nil)
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        //获取前置和后置摄像头用于拍照
        for device in devices{
            if device.position == .Front{
                frontFacingCamera = device
            }else if device.position == .Back{
                backFacingCamera = device
            }
        }
        
        currentDevice = backFacingCamera
        
        //将数据流输出放置到桌面上
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings[AVVideoCodecJPEG]
        
        //从摄像头获取数据输入
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice)
            
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(stillImageOutput)
            
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        
        //提供一个摄像头预览
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity =  AVLayerVideoGravityResizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        //把被预览图层掩盖的按钮放置到前面
        view.bringSubviewToFront(cancelButton)
        view.bringSubviewToFront(captureButton)
        
        captureSession.startRunning()
        
        //Toggle camera recognizer
        toggleCameraGestureRecognizer.direction = .Up
        toggleCameraGestureRecognizer.addTarget(self, action: #selector(self.toggleCamera))
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
        
        //Zoom in recognizer
        zoomInGestureRecognizer.direction = .Right
        zoomInGestureRecognizer.addTarget(self, action: #selector(self.zoomIn))
        view.addGestureRecognizer(zoomInGestureRecognizer)
        
        //Zoom out recogizer
        zoomOutGestureRecognizer.direction = .Left
        zoomOutGestureRecognizer.addTarget(self, action: #selector(self.zoomOut))
        view.addGestureRecognizer(zoomOutGestureRecognizer)

        
    }

    
    func toggleCamera(){
        
        captureSession.beginConfiguration()
        
        //Change the device base the current camera
        let newDevice = (currentDevice?.position == AVCaptureDevicePosition.Back) ? frontFacingCamera : backFacingCamera
        
        //Remove all inputs from the session
        for input in captureSession.inputs{
            captureSession.removeInput(input as! AVCaptureInput)
        }
        
        //Change to the new input
        let cameraInput:AVCaptureDeviceInput
        do{
            cameraInput = try AVCaptureDeviceInput(device: newDevice)
            
        }catch let error as NSError{
            print(error)
            return
        }
        
        if captureSession.canAddInput(cameraInput){
            captureSession.addInput(cameraInput)
        }
        
        currentDevice = newDevice
        captureSession.commitConfiguration()
    }
    
    func zoomIn(){
        if let zoomFactor = currentDevice?.videoZoomFactor{
            if zoomFactor < 5.0 {
                let newZoomFactor = min(zoomFactor + 1.0, 5.0)
                
                do{
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.rampToVideoZoomFactor(newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                }catch let error as NSError{
                    print(error.localizedDescription)
                }
            }
            
            
        }
    }
    
    func zoomOut(){
        if let zoomFactor = currentDevice?.videoZoomFactor{
            if zoomFactor > 1.0{
                let newZoomFactor = max(zoomFactor - 1.0, 1.0)
                do{
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.rampToVideoZoomFactor(newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                }catch let error as NSError{
                    print(error.localizedDescription)
                }
            }
        }
    }

    
    @IBAction func capturePressed() {
        let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo)
        
        stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
            self.stillImage = UIImage(data: imageData)
            self.performSegueWithIdentifier(ShowPhotoSegueIdentifier, sender: self)
        })

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ShowPhotoSegueIdentifier {
            let showViewController = segue.destinationViewController as! ShowViewController
            showViewController.image = stillImage
        }
    }
    
    @IBAction func CancelPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissViewConroller(){
        dismissViewControllerAnimated(false, completion: nil)
    }
   
}
