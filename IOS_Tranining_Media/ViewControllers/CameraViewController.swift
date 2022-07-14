//
//  CameraViewController.swift
//  IOS_Tranining_Media
//
//  Created by Hoang Long on 13/07/2022.
//

import UIKit
import AVFoundation
class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var viewCamera:UIView!
    
    let captureSession =  AVCaptureSession()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    var checkTakePhoto = false

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
        
        self.view.layer.addSublayer(self.previewLayer)
//        self.view.layer.aD(self.previewLayer)
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
//            self.previewLayer.frame = self.viewCamera.frame
            
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
    
    
    @IBAction func tapOnTakePhoto(_ sender: Any) {
        checkTakePhoto = true
    }
    
    
    @IBAction func tapOnReverseButton(_ sender: Any) {
    }
    
    @IBAction func tapOnFlashButton(_ sender: Any) {
    }
//}
//extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if checkTakePhoto {
            checkTakePhoto = false
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer){
                DispatchQueue.main.async {
                    UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil)
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

