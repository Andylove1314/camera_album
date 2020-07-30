//
//  CameraView.swift
//  camera_album
//
//  Created by OctMon on 2020/7/29.
//

import UIKit
import AVFoundation

class CameraView: UIView {
    
    var appBarHeight: CGFloat = 0
    
    lazy var cameraMan: CameraMan = self.makeCameraMan()

    var previewLayer: AVCaptureVideoPreviewLayer?
    var position: AVCaptureDevice.Position!
    
    convenience init(frame: CGRect, appBarHeight: CGFloat, position: AVCaptureDevice.Position) {
        self.init(frame: frame)

        self.appBarHeight = appBarHeight
        self.position = position
        
        check()
    }
    
    func setupPreviewLayer(_ session: AVCaptureSession) {
      guard previewLayer == nil else { return }

      let layer = AVCaptureVideoPreviewLayer(session: session)
      layer.autoreverses = true
      layer.videoGravity = .resizeAspectFill
      layer.connection?.videoOrientation = Utils.videoOrientation()
      
      self.layer.insertSublayer(layer, at: 0)
      layer.frame = self.layer.bounds

      previewLayer = layer
    }

    override func layoutSubviews() {
      super.layoutSubviews()

      previewLayer?.frame = self.layer.bounds
    }
    
    // MARK: - Logic

    func check() {
      if Permission.Camera.status == .notDetermined {
        Permission.Camera.request { [weak self] in
          self?.check()
        }

        return
      }
    
        DispatchQueue.main.async { [weak self] in
            guard Permission.Camera.status == .authorized else {
                let permissionView = PermissionView(needsPermission: true)
                self?.addSubview(permissionView)
                permissionView.g_pinEdges()
                return
            }
            self?.cameraMan.setup()
            if self?.position == .back {
                self?.cameraMan.switchCamera()
            }
        }
    }

    // MARK: - Controls

    func makeCameraMan() -> CameraMan {
      let man = CameraMan()
      man.delegate = self

      return man
    }

}

extension CameraView: CameraManDelegate {

  func cameraManDidStart(_ cameraMan: CameraMan) {
    setupPreviewLayer(cameraMan.session)
  }

  func cameraManNotAvailable(_ cameraMan: CameraMan) {
//    cameraView.focusImageView.isHidden = true
  }

  func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput) {
//    cameraView.flashButton.isHidden = !input.device.hasFlash
  }

}
