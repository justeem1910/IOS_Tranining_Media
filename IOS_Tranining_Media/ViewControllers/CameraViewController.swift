//
//  CameraViewController.swift
//  IOS_Tranining_Media
//
//  Created by Hoang Long on 13/07/2022.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController{
    
    @IBOutlet weak var viewCamera:UIView!
    @IBOutlet weak var btnFlash: UIButton!
    let captureSession =  AVCaptureSession()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    var checkTakePhoto = false
    var usingFrontCamera = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCamera()
    }
    
    func prepareCamera(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        if let availableDecice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices as? [AVCaptureDevice] {
            captureDevice = availableDecice.first
            beginSession()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.viewCamera.frame
    }
    
    func beginSession(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) as? AVCaptureVideoPreviewLayer{
            
            previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer = previewLayer
            self.view.layer.addSublayer(self.previewLayer)
            captureSession.startRunning()
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            if captureSession.canAddOutput(dataOutput){
                captureSession.addOutput(dataOutput)
            }
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.brianadvent.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
        
    }
    
    //MARK: IBACTION
    @IBAction func tapOnTakePhoto(_ sender: Any) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied{
            showSettingAlert(message: "Xin cap quyen camera")
        } else {
            checkTakePhoto = true
        }
    }
    
    
    @IBAction func tapOnReverseButton(_ cameraButton: UIButton) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            showSettingAlert(message: "Xin cap quyen camera")
        } else {
            switchCamera()
        }
        
    }
    func switchCamera (){
        usingFrontCamera = !usingFrontCamera
            do{
                captureSession.removeInput(captureSession.inputs.first!)

                if(usingFrontCamera){
                    captureDevice = getFrontCamera()
                }else{
                    captureDevice = getBackCamera()
                }
                let captureDeviceInput1 = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(captureDeviceInput1)
            }catch{
                print(error.localizedDescription)
            }
    }
    
    func getFrontCamera() -> AVCaptureDevice?{
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first
    }

    func getBackCamera() -> AVCaptureDevice?{
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first
    }
    
    @IBAction func tapOnFlashButton(_ sender: Any) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
            guard device.hasTorch else { return }

            do {
                try device.lockForConfiguration()

                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    btnFlash.setImage(UIImage(named: "flashOff"), for: .normal)
                    device.torchMode = AVCaptureDevice.TorchMode.off
                    
                } else {
                    do {
                        try device.setTorchModeOn(level: 1.0)
                        btnFlash.setImage(UIImage(named: "flashOn"), for: .normal)
                        
                    } catch {
                        print(error)
                    }
                }

                device.unlockForConfiguration()
            } catch {
                print(error)
            }
    }
}

    //MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController : AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if checkTakePhoto {
            checkTakePhoto = false
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer){
                DispatchQueue.main.async {
                    self.showAccessToLibraryAlert(image: image, message: "Bạn có muốn lưu ảnh vào trong thư viện không")
                }
            }
        }
    }
    func getImageFromSampleBuffer (buffer : CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer){
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect){
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
}


extension CameraViewController {
    
    
    func showSettingAlert(title: String = "Thông báo", message: String, acceptTitle: String = "Cài đặt", cancelTitle: String = "Hủy") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: acceptTitle, style: UIAlertAction.Style.cancel, handler: { (sender) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        let cancel = UIAlertAction(title: cancelTitle, style: UIAlertAction.Style.default, handler: { (sender) in
        })
        
        alert.addAction(cancel)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showAccessToLibraryAlert(title: String = "Thông báo",image: UIImage ,message: String, acceptTitle: String = "Đồng ý", cancelTitle: String = "Hủy") {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: acceptTitle, style: UIAlertAction.Style.cancel, handler: { (sender) in
            if #available(iOS 14, *) {
                if PHPhotoLibrary.authorizationStatus(for: .addOnly) == .denied {
                    self.showSettingAlert(message: Constants.Camera.acceptMessageLibrary)
                } else {
                    UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil)
                }
            } else {
                // Fallback on earlier versions
            }
            
        })
        
        let cancel = UIAlertAction(title: cancelTitle, style: UIAlertAction.Style.default, handler: { (sender) in
        })
        
        alert.addAction(cancel)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}
