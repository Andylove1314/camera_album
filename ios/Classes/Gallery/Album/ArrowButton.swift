import UIKit

class ArrowButton: UIButton {

  lazy var label: UILabel = self.makeLabel()
  lazy var arrow: UIImageView = self.makeArrow()

  let padding: CGFloat = 20
  let arrowSize: CGFloat = 11

  // MARK: - Initialization

  init() {
    super.init(frame: CGRect.zero)

    backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
    layer.cornerRadius = 20
    
    addSubview(label)
    addSubview(arrow)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    label.center = CGPoint(x: bounds.size.width / 2 - 5, y: bounds.size.height / 2)

    arrow.frame.size = CGSize(width: 11, height: 6)
    arrow.center = CGPoint(x: label.frame.maxX + padding / 2, y: bounds.size.height / 2)
  }


  override var intrinsicContentSize : CGSize {
    let size = super.intrinsicContentSize
    label.sizeToFit()

    return CGSize(width: label.frame.size.width + arrowSize * 2 + padding, height: size.height)
  }

  // MARK: - Logic

  func updateText(_ text: String) {
    label.text = text//.uppercased()
    arrow.alpha = text.isEmpty ? 0 : 1
    invalidateIntrinsicContentSize()
  }

  func toggle(_ expanding: Bool) {
    let transform = expanding
      ? CGAffineTransform(rotationAngle: CGFloat(Double.pi)) : CGAffineTransform.identity
    
    UIView.animate(withDuration: 0.25, animations: {
      self.arrow.transform = transform
    }) 
  }

  // MARK: - Controls

  private func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .center

    return label
  }

  private func makeArrow() -> UIImageView {
    let arrow = UIImageView()
    arrow.image = GalleryBundle.image("gallery_title_arrow")?.withRenderingMode(.alwaysTemplate)
    arrow.tintColor = UIColor(red: 110/255, green: 117/255, blue: 131/255, alpha: 1)
    arrow.alpha = 0

    return arrow
  }

  // MARK: - Touch

  override var isHighlighted: Bool {
    didSet {
      label.textColor = isHighlighted ? UIColor.lightGray : UIColor(red: 110/255, green: 117/255, blue: 131/255, alpha: 1)
      arrow.tintColor = isHighlighted ? UIColor.lightGray : UIColor(red: 110/255, green: 117/255, blue: 131/255, alpha: 1)
    }
  }
}
