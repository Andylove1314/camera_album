import Foundation
import AVFoundation
import PhotosUI
import Photos

protocol CameraManDelegate: class {
  func cameraManNotAvailable(_ cameraMan: CameraMan)
  func cameraManDidStart(_ cameraMan: CameraMan)
  func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput)
}

class CameraMan {
  weak var delegate: CameraManDelegate?
  
  var isRecordVideo: Bool = false
  var isFrontCamera: Bool = true

  var lastFlashMode: AVCaptureDevice.FlashMode = .off

  let session = AVCaptureSession()
  let queue = DispatchQueue(label: "no.hyper.Gallery.Camera.SessionQueue", qos: .background)
  let savingQueue = DispatchQueue(label: "no.hyper.Gallery.Camera.SavingQueue", qos: .background)

  var camera: AVCaptureDevice?
  var stillImageOutput: AVCaptureStillImageOutput?
  var movieFileOut: AVCaptureMovieFileOutput?

  deinit {
    stop()
  }

  // MARK: - Setup

  func setup() {
    if Permission.Camera.status == .authorized {
        self.start()
    } else {
      self.delegate?.cameraManNotAvailable(self)
    }
  }
    /// 选择摄像头
    private func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for item in devices {
            if item.position == position {
                return item
            }
        }
        return nil
    }
  func setupDevices() {
    // Input
    isFrontCamera = true
    camera = cameraWithPosition(position: AVCaptureDevice.Position.front)

    if isRecordVideo {
        movieFileOut = AVCaptureMovieFileOutput()
    } else {
        // Output
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
    }
  }

  func addInput(_ input: AVCaptureDeviceInput) {
    configurePreset(input)

    if session.canAddInput(input) {
      session.addInput(input)

      DispatchQueue.main.async {
        self.delegate?.cameraMan(self, didChangeInput: input)
      }
    }
  }

  // MARK: - Session

  fileprivate func start() {
    // Devices
    setupDevices()

    guard let camera = camera, let input = try? AVCaptureDeviceInput(device: camera), let output = (isRecordVideo ? movieFileOut : stillImageOutput) else { return }

    addInput(input)

    if session.canAddOutput(output) {
      session.addOutput(output)
    }

    queue.async {
      self.session.startRunning()

      DispatchQueue.main.async {
        self.delegate?.cameraManDidStart(self)
      }
    }
  }

  func stop() {
    self.session.stopRunning()
  }

  func switchCamera(_ completion: (() -> Void)? = nil) {
    queue.async {
      self.configure {
        //  首先移除所有的 input
        if let allInputs = self.session.inputs as? [AVCaptureDeviceInput] {
            for input in allInputs {
                self.session.removeInput(input)

            }
        }
        if self.isRecordVideo {
            self.session.sessionPreset = AVCaptureSession.Preset.vga640x480
            if let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio) {
                if let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
                    if self.session.canAddInput(audioInput) {
                        self.session.addInput(audioInput)
                    }
                }
            }
        }
        self.camera = self.cameraWithPosition(position: self.isFrontCamera ? .back : .front)
        if let camera = self.camera  {
            if let input = try? AVCaptureDeviceInput(device: camera) {
                self.addInput(input)
                self.isFrontCamera.toggle()
                if !self.isRecordVideo {
                    self.flash(self.lastFlashMode)
                }
            }
        }
      }

      DispatchQueue.main.async {
        completion?()
      }
    }
  }

  func takePhoto(_ previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?, completion: @escaping ((PHAsset?) -> Void)) {
    guard let connection = stillImageOutput?.connection(with: .video) else { return }

    if connection.isVideoOrientationSupported {
        connection.videoOrientation = Utils.videoOrientation()
    }
    
    // 解决前置摄像头镜像问题
    if (isFrontCamera && connection.isVideoMirroringSupported) {
        // 镜像设置
        connection.isVideoMirrored = true
    }

    queue.async {
      self.stillImageOutput?.captureStillImageAsynchronously(from: connection) {
        buffer, error in

        guard error == nil, let buffer = buffer, CMSampleBufferIsValid(buffer),
          let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
          let image = UIImage(data: imageData)
          else {
            DispatchQueue.main.async {
              completion(nil)
            }
            return
        }

        self.savePhoto(image, location: location, completion: completion)
      }
    }
  }

    /// 图片保存到相册
  func savePhoto(_ image: UIImage, location: CLLocation?, completion: @escaping ((PHAsset?) -> Void)) {
    var localIdentifier: String?

    savingQueue.async {
      do {
        try PHPhotoLibrary.shared().performChangesAndWait {
          let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
          localIdentifier = request.placeholderForCreatedAsset?.localIdentifier

          request.creationDate = Date()
          request.location = location
        }

        DispatchQueue.main.async {
          if let localIdentifier = localIdentifier {
            completion(Utils.phAssetWith(identifier: localIdentifier))
          } else {
            completion(nil)
          }
        }
      } catch {
        DispatchQueue.main.async {
          completion(nil)
        }
      }
    }
  }
    
    /**
     将视频保存到相册
     
     - parameter videoUrl: 保存链接
     */
    func saveVideoToAlbum(videoUrl: URL, completion: @escaping ((PHAsset?) -> Void)) {
        var localIdentifier: String?
        
        savingQueue.async {
          do {
            try PHPhotoLibrary.shared().performChangesAndWait {
              let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
              localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier

              request?.creationDate = Date()
            }

            DispatchQueue.main.async {
              if let localIdentifier = localIdentifier {
                completion(Utils.phAssetWith(identifier: localIdentifier))
              } else {
                completion(nil)
              }
            }
          } catch {
            DispatchQueue.main.async {
              completion(nil)
            }
          }
        }
    }
    

  func flash(_ mode: AVCaptureDevice.FlashMode) {
    guard let device = camera, device.isFlashModeSupported(mode) else { return }

    queue.async {
      self.lock {
        let torchMode: AVCaptureDevice.TorchMode = mode == .on ? .on : .off
        if self.isRecordVideo && device.isTorchModeSupported(torchMode) {
            device.torchMode = torchMode
        }
        device.flashMode = mode
        self.lastFlashMode = mode
      }
    }
  }

  func focus(_ point: CGPoint) {
    guard let device = camera, device.isFocusModeSupported(AVCaptureDevice.FocusMode.locked) else { return }

    queue.async {
      self.lock {
        device.focusPointOfInterest = point
      }
    }
  }

  // MARK: - Lock

  func lock(_ block: () -> Void) {
    if let device = camera, (try? device.lockForConfiguration()) != nil {
      block()
      device.unlockForConfiguration()
    }
  }

  // MARK: - Configure
  func configure(_ block: () -> Void) {
    session.beginConfiguration()
    block()
    session.commitConfiguration()
  }

  // MARK: - Preset

  func configurePreset(_ input: AVCaptureDeviceInput) {
    for asset in preferredPresets() {
      if input.device.supportsSessionPreset(asset) && self.session.canSetSessionPreset(asset) {
        self.session.sessionPreset = asset
        return
      }
    }
  }

  func preferredPresets() -> [AVCaptureSession.Preset] {
    return [
      .photo,
      .high,
      .medium,
      .low
    ]
  }
}
