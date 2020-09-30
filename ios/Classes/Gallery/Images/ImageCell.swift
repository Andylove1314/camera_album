import UIKit
import Photos

extension UIImageView {

  func g_loadImage(_ asset: PHAsset) {
    guard frame.size != CGSize.zero else {
      image = GalleryBundle.image("gallery_placeholder")
      return
    }

    if tag == 0 {
      image = GalleryBundle.image("gallery_placeholder")
    } else {
      PHImageManager.default().cancelImageRequest(PHImageRequestID(tag))
    }

    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true

    let id = PHImageManager.default().requestImage(
      for: asset, targetSize: CGSize(width: frame.size.width * 3, height: frame.size.height * 3),
      contentMode: .aspectFill,
      options: options) { [weak self] image, _ in
      self?.image = image
    }
    
    tag = Int(id)
  }
}

class ImageCell: UICollectionViewCell {

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    override init(frame: CGRect) {
      super.init(frame: frame)
      
        contentView.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        contentView.addSubview(checkImageView)
        checkImageView.g_pin(on: .top, constant: 8)
        checkImageView.g_pin(on: .right, constant: -8)
        checkImageView.g_pin(width: 22)
        checkImageView.g_pin(on: .width, view: checkImageView, on: .height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ asset: PHAsset) {
        imageView.layoutIfNeeded()
        imageView.g_loadImage(asset)
    }

    func configure(_ image: Image) {
        imageView.layoutIfNeeded()
        imageView.g_loadImage(image.asset)
    }

}
