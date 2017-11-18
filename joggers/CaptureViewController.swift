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
    
    fileprivate lazy var captureSession = AVCaptureSession()
    
    fileprivate var backFacingCamera: AVCaptureDevice?
    fileprivate var frontFacingCamera: AVCaptureDevice?
    fileprivate var currentDevice: AVCaptureDevice?

    fileprivate var stillImageOutput: AVCaptureStillImageOutput?
    fileprivate var stillImage: UIImage?

    fileprivate var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //And Gestures
    fileprivate lazy var toggleCameraGestureRecognizer = UISwipeGestureRecognizer()
    fileprivate lazy var zoomInGestureRecognizer = UISwipeGestureRecognizer()
    fileprivate lazy var zoomOutGestureRecognizer = UISwipeGestureRecognizer()
  
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置拍照按钮为圆形
        captureButton.layer.cornerRadius = captureButton.layer.bounds.width/2
        //在收到选择好照片的通知后关闭视图
        NotificationCenter.default.addObserver(self, selector: #selector(dismissViewConroller), name: NSNotification.Name(rawValue: PhotoCaptureNotification.photoChoosedNotificationName), object: nil)
        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        //获取前置和后置摄像头用于拍照
        for device in devices{
            if device.position == .front{
                frontFacingCamera = device
            }else if device.position == .back{
                backFacingCamera = device
            }
        }
        
        currentDevice = backFacingCamera
        
        //将数据流输出放置到桌面上
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings[AVVideoCodecJPEG]
        
        //从摄像头获取数据输入
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(stillImageOutput!)
            
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        
        //提供一个摄像头预览
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity =  AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        //把被预览图层掩盖的按钮放置到前面
        view.bringSubview(toFront: cancelButton)
        view.bringSubview(toFront: captureButton)
        
        captureSession.startRunning()
        
        //Toggle camera recognizer
        toggleCameraGestureRecognizer.direction = .up
        toggleCameraGestureRecognizer.addTarget(self, action: #selector(self.toggleCamera))
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
        
        //Zoom in recognizer
        zoomInGestureRecognizer.direction = .right
        zoomInGestureRecognizer.addTarget(self, action: #selector(self.zoomIn))
        view.addGestureRecognizer(zoomInGestureRecognizer)
        
        //Zoom out recogizer
        zoomOutGestureRecognizer.direction = .left
        zoomOutGestureRecognizer.addTarget(self, action: #selector(self.zoomOut))
        view.addGestureRecognizer(zoomOutGestureRecognizer)

        
    }

    
    @objc func toggleCamera(){
        
        captureSession.beginConfiguration()
        
        //Change the device base the current camera
        let newDevice = (currentDevice?.position == AVCaptureDevice.Position.back) ? frontFacingCamera : backFacingCamera
        
        //Remove all inputs from the session
        for input in captureSession.inputs{
            captureSession.removeInput(input )
        }
        
        //Change to the new input
        let cameraInput:AVCaptureDeviceInput
        do{
            cameraInput = try AVCaptureDeviceInput(device: newDevice!)
            
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
    
    @objc func zoomIn(){
        if let zoomFactor = currentDevice?.videoZoomFactor{
            if zoomFactor < 5.0 {
                let newZoomFactor = min(zoomFactor + 1.0, 5.0)
                
                do{
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                }catch let error as NSError{
                    print(error.localizedDescription)
                }
            }
            
            
        }
    }
    
    @objc func zoomOut(){
        if let zoomFactor = currentDevice?.videoZoomFactor{
            if zoomFactor > 1.0{
                let newZoomFactor = max(zoomFactor - 1.0, 1.0)
                do{
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                }catch let error as NSError{
                    print(error.localizedDescription)
                }
            }
        }
    }

    
    @IBAction func capturePressed() {
        let videoConnection = stillImageOutput?.connection(with: AVMediaType.video)
        
        stillImageOutput?.captureStillImageAsynchronously(from: videoConnection!, completionHandler: { (imageDataSampleBuffer, error) -> Void in
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
            self.stillImage = UIImage(data: imageData!)
            self.performSegue(withIdentifier: ShowPhotoSegueIdentifier, sender: self)
        })

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowPhotoSegueIdentifier {
            let showViewController = segue.destination as! ShowViewController
            showViewController.image = stillImage
        }
    }
    
    @IBAction func CancelPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissViewConroller(){
        dismiss(animated: false, completion: nil)
    }
   
}
