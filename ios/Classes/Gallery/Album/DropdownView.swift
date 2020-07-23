import UIKit
import Photos

protocol DropdownViewDelegate: class {
  func dropdownView(_ view: DropdownView, didSelect album: Album?)
}

class DropdownView: UIView {

    lazy var tableView: UITableView = self.makeTableView()
 
    var blackOverlayColor = UIColor(white: 0, alpha: 0.6)
    var dismissOnBlackOverlayTap = true
    var selectedIndex: Int = 0
    var top: CGFloat = 0

  var albums: [Album] = [] {
    didSet {
      selectedIndex = 0
    }
  }

  weak var delegate: DropdownViewDelegate?

  // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  // MARK: - Life cycle
    
  // MARK: - Setup

  func setup() {
    backgroundColor = .clear
    tableView.backgroundColor = UIColor.white
    
    addSubview(tableView)
    tableView.register(AlbumCell.self, forCellReuseIdentifier: String(describing: AlbumCell.self))

    tableView.g_pin(on: .left)
    tableView.g_pin(on: .width)
    tableView.g_pin(on: .bottom, constant: -100)
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    tapGestureRecognizer.delegate = self
    tapGestureRecognizer.addTarget(self, action: #selector(dismiss))
    addGestureRecognizer(tapGestureRecognizer)
  }

  // MARK: - Logic

    func show() {
      UIView.animate(withDuration: 0.25, animations: { [weak self] in
          self?.backgroundColor = self?.blackOverlayColor
          self?.tableView.g_pin(on: .top, constant: self?.top ?? 0)
      })
    }

    @objc func dismiss() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.backgroundColor = .clear
            self?.alpha = 0
        }) { [weak self] (completion) in
            if completion {
                self?.removeFromSuperview()
                guard let self = self else {
                    return
                }
                self.delegate?.dropdownView(self, didSelect: nil)
            }
        }
    }

  // MARK: - Controls

  func makeTableView() -> UITableView {
    let tableView = UITableView()
    tableView.tableFooterView = UIView()
    tableView.separatorStyle = .none
    tableView.rowHeight = 84

    tableView.dataSource = self
    tableView.delegate = self

    return tableView
  }

  func makeBlurView() -> UIVisualEffectView {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))

    return view
  }
}

extension DropdownView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if !dismissOnBlackOverlayTap {
            return false
        }
        if let view = touch.view, view.isDescendant(of: self.tableView) {
            return false
        }
        return true
    }
    
}

extension DropdownView: UITableViewDataSource, UITableViewDelegate {

  // MARK: - UITableViewDataSource

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return albums.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AlbumCell.self), for: indexPath)
      as! AlbumCell

    let album = albums[(indexPath as NSIndexPath).row]
    cell.configure(album)
    cell.backgroundColor = UIColor.clear

    return cell
  }

  // MARK: - UITableViewDelegate

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let album = albums[(indexPath as NSIndexPath).row]
    dismiss()
    delegate?.dropdownView(self, didSelect: album)

    selectedIndex = (indexPath as NSIndexPath).row
    tableView.reloadData()
  }
}

