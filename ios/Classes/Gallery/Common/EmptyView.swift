import UIKit

class EmptyView: UIView {

  lazy var imageView: UIImageView = self.makeImageView()
  lazy var label: UILabel = self.makeLabel()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  private func setup() {
    [label, imageView].forEach {
        addSubview($0)
    }

    label.g_pinCenter()
    imageView.g_pin(on: .centerX)
    imageView.g_pin(on: .bottom, view: label, on: .top, constant: -12)
  }

  // MARK: - Controls

  private func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = UIColor(red: 102/255, green: 118/255, blue: 138/255, alpha: 1)
    label.font = UIFont.systemFont(ofSize: 14.0)
    label.text = "Nothing to show"

    return label
  }

  private func makeImageView() -> UIImageView {
    let view = UIImageView()
    view.image = GalleryBundle.image("gallery_empty_view_image")

    return view
  }
}
