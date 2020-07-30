import UIKit

class AlbumCell: UITableViewCell {

  lazy var albumImageView: UIImageView = self.makeAlbumImageView()
  lazy var albumTitleLabel: UILabel = self.makeAlbumTitleLabel()
  lazy var itemCountLabel: UILabel = self.makeItemCountLabel()
  lazy var duiGouImageView: UIImageView = self.makeDuiGouCountImageView()

  // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Config

  func configure(_ album: Album) {
    albumTitleLabel.text = album.collection.localizedTitle
    itemCountLabel.text = "\(album.items.count)"

    if let item = album.items.first {
      albumImageView.layoutIfNeeded()
      albumImageView.g_loadImage(item.asset)
    }
  }

  // MARK: - Setup

  func setup() {
    [albumImageView, albumTitleLabel, itemCountLabel, duiGouImageView].forEach {
        addSubview($0)
    }

    albumImageView.g_pin(on: .left, constant: 12)
    albumImageView.g_pin(on: .top, constant: 5)
    albumImageView.g_pin(on: .bottom, constant: -5)
    albumImageView.g_pin(on: .width, view: albumImageView, on: .height)

    albumTitleLabel.g_pin(on: .left, view: albumImageView, on: .right, constant: 10)
    albumTitleLabel.g_pin(on: .top, constant: 24)
    albumTitleLabel.g_pin(on: .right, constant: -10)

    itemCountLabel.g_pin(on: .left, view: albumImageView, on: .right, constant: 10)
    itemCountLabel.g_pin(on: .top, view: albumTitleLabel, on: .bottom, constant: 6)
    
    
    duiGouImageView.g_pin(on: .right, constant: -15)
    duiGouImageView.g_pin(on: .centerY)
    duiGouImageView.g_pin(width: 25)
    duiGouImageView.g_pin(height: 19)

  }

  // MARK: - Controls

  private func makeAlbumImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.image = GalleryBundle.image("gallery_placeholder")

    return imageView
  }

  private func makeAlbumTitleLabel() -> UILabel {
    let label = UILabel()
    label.numberOfLines = 1
    label.font = UIFont.systemFont(ofSize: 14)

    return label
  }

  private func makeItemCountLabel() -> UILabel {
    let label = UILabel()
    label.numberOfLines = 1
    label.font = UIFont.systemFont(ofSize: 10)

    return label
  }

  private func makeDuiGouCountImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = GalleryBundle.image("gallery_green_duigou")

    return imageView
  }
}
