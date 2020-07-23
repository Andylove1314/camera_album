import UIKit
import Photos

extension UIImageView {

  func g_loadImage(_ asset: PHAsset) {
    guard frame.size != CGSize.zero else {
//      image = GalleryBundle.image("gallery_placeholder")
      return
    }

    if tag == 0 {
//      image = GalleryBundle.image("gallery_placeholder")
    } else {
      PHImageManager.default().cancelImageRequest(PHImageRequestID(tag))
    }

    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true

    let id = PHImageManager.default().requestImage(
      for: asset,
      targetSize: frame.size,
      contentMode: .aspectFill,
      options: options) { [weak self] image, _ in
      self?.image = image
    }
    
    tag = Int(id)
  }
}

class GalleryImageCell: UICollectionViewCell {

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    
    override init(frame: CGRect) {
      super.init(frame: frame)
      
        contentView.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

 
    func configure(_ image: Image) {
        imageView.layoutIfNeeded()
        imageView.g_loadImage(image.asset)
    }

}
