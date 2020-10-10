import UIKit
import Photos

class VideoCell: ImageCell {

  lazy var cameraImageView: UIImageView = self.makeCameraImageView()
  lazy var durationLabel: UILabel = self.makeDurationLabel()
  lazy var bottomOverlay: UIView = self.makeBottomOverlay()

  // MARK: - Config

  func configure(_ video: Video) {
    super.configure(video.asset)

    video.fetchDuration { duration in
      DispatchQueue.main.async {
        print(duration);
        if duration <= 0 {
            self.bottomOverlay.isHidden = true;
            self.cameraImageView.isHidden = true;
            self.durationLabel.isHidden = true;
        } else {
            self.bottomOverlay.isHidden = false;
            self.cameraImageView.isHidden = false;
            self.durationLabel.isHidden = false;
            self.durationLabel.text = "\(Utils.format(duration))"
        }
      }
    }
  }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [bottomOverlay, cameraImageView, durationLabel].forEach {
          self.insertSubview($0, belowSubview: self)
        }

        bottomOverlay.g_pinDownward()
        bottomOverlay.g_pin(height: 16)

        cameraImageView.g_pin(on: .left, constant: 4)
        cameraImageView.g_pin(on: .centerY, view: durationLabel, on: .centerY)
        cameraImageView.g_pin(size: CGSize(width: 12, height: 6))

        durationLabel.g_pin(on: .right, constant: -4)
        durationLabel.g_pin(on: .bottom, constant: -2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  // MARK: - Controls

  func makeCameraImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = GalleryBundle.image("gallery_video_cell_camera")
    imageView.contentMode = .scaleAspectFit

    return imageView
  }

  func makeDurationLabel() -> UILabel {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 9)
    label.textColor = UIColor.white
    label.textAlignment = .right

    return label
  }

  func makeBottomOverlay() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

    return view
  }
}
