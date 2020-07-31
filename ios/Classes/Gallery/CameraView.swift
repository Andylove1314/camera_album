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
    /// 拍照后闪一下动画
    lazy var shutterOverlayView: UIView = self.makeShutterOverlayView()
    /// 切换前、后置摄像头动画
    lazy var rotateOverlayView: UIView = self.makeRotateOverlayView()
    /// 切换前、后置摄像头毛玻璃
    lazy var blurView: UIVisualEffectView = self.makeBlurView()

    var previewLayer: AVCaptureVideoPreviewLayer?
    var position: AVCaptureDevice.Position!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    convenience init(frame: CGRect, appBarHeight: CGFloat, position: AVCaptureDevice.Position) {
        self.init(frame: frame)

        self.appBarHeight = appBarHeight
        self.position = position
        
        check()
        
        addSubview(shutterOverlayView)
        shutterOverlayView.g_pinEdges()
        addSubview(rotateOverlayView)
        rotateOverlayView.g_pinEdges()
        rotateOverlayView.addSubview(blurView)
        blurView.g_pinEdges()
        
        NotificationCenter.default.addObserver(self, selector: #selector(startCamera), name: NSNotification.Name(rawValue:"startCamera"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchCamera), name: NSNotification.Name(rawValue:"switchCamera"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(takePhoto), name: NSNotification.Name(rawValue:"takePhoto"), object: nil)
    }
    
    @objc func startCamera(notification : Notification) {
        cameraMan.session.startRunning()
    }
    
    @objc func switchCamera(notification : Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.rotateOverlayView.alpha = 1
        }, completion: { _ in
          self.cameraMan.switchCamera {
            UIView.animate(withDuration: 0.7, animations: {
              self.rotateOverlayView.alpha = 0
            })
          }
        })
    }
    
    @objc func takePhoto(notification : Notification) {
        guard let previewLayer = previewLayer else { return }
        SwiftCameraAlbumPlugin.channel.invokeMethod("onTakeStart", arguments: nil)
        UIView.animate(withDuration: 0.1, animations: {
          self.shutterOverlayView.alpha = 1
        }, completion: { _ in
          UIView.animate(withDuration: 0.1, animations: {
            self.shutterOverlayView.alpha = 0
          })
        })
        cameraMan.takePhoto(previewLayer, location: nil) { [weak self] asset in
          guard let asset = asset else {
            return
          }
          SwiftCameraAlbumPlugin.channel.invokeMethod("onTakeDone", arguments: ["identifier": asset.localIdentifier])
            self?.cameraMan.stop()
        }
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

    func makeShutterOverlayView() -> UIView {
      let view = UIView()
      view.alpha = 0
      view.backgroundColor = UIColor.black

      return view
    }

    func makeRotateOverlayView() -> UIView {
      let view = UIView()
      view.alpha = 0

      return view
    }
    
    func makeBlurView() -> UIVisualEffectView {
      let effect = UIBlurEffect(style: .dark)
      let blurView = UIVisualEffectView(effect: effect)

      return blurView
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
