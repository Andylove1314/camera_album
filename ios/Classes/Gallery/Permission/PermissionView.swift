import UIKit

class PermissionView: UIView {

  lazy var imageView: UIImageView = self.makeImageView()
  lazy var label: UILabel = self.makeLabel()
  lazy var settingButton: UIButton = self.makeSettingButton()

  // MARK: - Initialization
    
    
  convenience init(needsPermission: Bool) {
    self.init()
    
    if needsPermission {
      label.text = "Please grant access to camera."
    }
    
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = UIColor.white
    setup()

    label.text = "Please grant access to photos."
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    [label, settingButton, imageView].forEach {
      addSubview($0)
    }

    settingButton.g_pinCenter()
    settingButton.g_pin(height: 44)

    label.g_pin(on: .bottom, view: settingButton, on: .top, constant: -24)
    label.g_pinHorizontally(padding: 50)

    imageView.g_pin(on: .centerX)
    imageView.g_pin(on: .bottom, view: label, on: .top, constant: -16)
  }

  // MARK: - Controls

  func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = UIColor(red: 102/255, green: 118/255, blue: 138/255, alpha: 1)
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping

    return label
  }

  func makeSettingButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setTitle("Go to Settings",
                    for: UIControl.State())
    button.backgroundColor = UIColor(red: 40/255, green: 170/255, blue: 236/255, alpha: 1)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    button.setTitleColor(UIColor.white, for: UIControl.State())
    button.setTitleColor(UIColor.lightGray, for: .highlighted)
    button.layer.cornerRadius = 22
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    button.addTarget(self, action: #selector(settingButtonTouched(_:)),
    for: .touchUpInside)

    return button
  }

  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(GalleryBundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
    button.tintColor = UIColor(red: 109/255, green: 107/255, blue: 132/255, alpha: 1)

    return button
  }

  func makeImageView() -> UIImageView {
    let view = UIImageView()
    view.image = GalleryBundle.image("gallery_permission_view_camera")

    return view
  }
    
    // MARK: - Action

    @objc func settingButtonTouched(_ button: UIButton) {
      DispatchQueue.main.async {
          if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.openURL(settingsURL)
        }
      }
    }

}
