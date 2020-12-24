//
//  GalleryView.swift
//  camera_album
//
//  Created by OctMon on 2020/7/20.
//

import UIKit
import Photos
 
let columnCount: CGFloat = 4
let cellSpacing: CGFloat = 2
let kTop: CGFloat = 45

class GalleryView: UIView {
    
    var collectionView: UICollectionView!
    lazy var emptyView: UIView = self.makeEmptyView()
    
    /// 已选相册
    var selectedAlbum: Album?
    var selectedAlbumIndex: Int?
    
    var arrowButton: ArrowButton!
    let loadingView = UIActivityIndicatorView(style: .gray)
    
    /// 所有图片
    var imageItems: [Image] = []
    var imageLibrary: ImagesLibrary?
    
    /// 最多选择限制
    var limit: Int = 1
    
    /// 已选照片
    var selectedImages: [Image] = []
    
    var mediaType = PHAssetMediaType.image
    
    var appBarHeight: CGFloat = 0
    
    @available(iOS 14, *)
    var showAddPhotoCell: Bool {
        PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited
    }
    
    /// 添加图片按钮的数量
    /// the count of addPhotoButton & cameraButton
    private var offset: Int {
        if #available(iOS 14, *) {
            return self.showAddPhotoCell ? 1 : 0
        } else {
            return 0
        }
    }
    
    convenience init(frame: CGRect, mediaType: PHAssetMediaType, limit: Int, appBarHeight: CGFloat) {
        self.init(frame: frame)
        self.mediaType = mediaType
        self.limit = limit
        self.appBarHeight = appBarHeight
        check()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 14.0, *), PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
            PHPhotoLibrary.shared().register(self)
        }
        
        arrowButton = ArrowButton()
        arrowButton.isHidden = true
        addSubview(arrowButton)
        
        arrowButton.g_pin(on: .top)
        arrowButton.g_pin(on: .centerX)
        arrowButton.g_pin(height: 40)
        arrowButton.addTarget(self, action: #selector(arrowButtonTouched(_:)), for: .touchUpInside)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: String(describing: VideoCell.self))
        collectionView.register(GalleryAddPhotoCell.self, forCellWithReuseIdentifier: "GalleryAddPhotoCell")
        
        addSubview(collectionView)
        collectionView.g_pin(on: .top, constant: kTop)
        collectionView.g_pin(on: .left)
        collectionView.g_pin(on:.right)
        collectionView.g_pin(on: .bottom)
        
        addSubview(loadingView)
        loadingView.g_pinEdges(view: collectionView)
        
        addSubview(emptyView)
        emptyView.g_pinEdges(view: collectionView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Logic

    func check() {
        loadingView.startAnimating()
      if Permission.Photos.status == .notDetermined {
        let dispatchTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            Permission.Photos.request { [weak self] in
              self?.check()
            }
        }

        return
      }
        
      DispatchQueue.main.async { [weak self] in
        guard Permission.Photos.status == .authorized else {
            let permissionView = PermissionView()
            self?.addSubview(permissionView)
            permissionView.g_pinEdges()
          return
        }
        
        if let mediaType = self?.mediaType {
//            if mediaType == .video {
//                // TODO: - 暂时展示所有视频
//                let fetchResults = PHAsset.fetchAssets(with: .video, options: Utils.fetchOptions())
//                fetchResults.enumerateObjects({ (asset, _, _) in
//                  self?.videoItems.append(Video(asset: asset))
//                })
//                return
//            }
            self?.imageLibrary = ImagesLibrary(mediaType: mediaType)
            self?.imageLibrary?.reload {
                self?.loadingView.stopAnimating()
                self?.loadingView.isHidden = true
                if #available(iOS 14, *) {
                    if self?.showAddPhotoCell == true {
                        self?.emptyView.isHidden = true
                        if let album = self?.imageLibrary?.albums.first {
                            self?.arrowButton.isHidden = false
                            self?.selectedAlbum = album
                            self?.show(album: album)
                        } else {
                            self?.imageItems = []
                            self?.collectionView.reloadData()
                        }
                        return
                    }
                }
                if let album = self?.imageLibrary?.albums.first {
                    self?.arrowButton.isHidden = false
                    self?.selectedAlbum = album
                    self?.show(album: album)
                } else {
                    self?.arrowButton.isHidden = true
                    self?.emptyView.isHidden = false
                }
            }
        }
      }
    }

    @objc func arrowButtonTouched(_ button: ArrowButton) {
        let dropdownView = DropdownView()
        dropdownView.selectedIndex = selectedAlbumIndex ?? 0
        dropdownView.top = UIApplication.shared.statusBarFrame.height + appBarHeight + kTop
        
        dropdownView.albums = self.imageLibrary?.albums ?? []
        dropdownView.tableView.reloadData()
        (UIApplication.shared.delegate as! FlutterAppDelegate).window.addSubview(dropdownView)
        dropdownView.delegate = self
        dropdownView.g_pinEdges()

      dropdownView.show()
      button.toggle(true)
    }

    func show(album: Album) {
      arrowButton.updateText(album.collection.localizedTitle ?? "")
      imageItems = album.items
      collectionView.reloadData()
      collectionView.g_scrollToTop()
      emptyView.isHidden = !album.items.isEmpty
    }

    private func makeEmptyView() -> EmptyView {
      let view = EmptyView()
      view.isHidden = true

      return view
    }
}

extension GalleryView: DropdownViewDelegate {

    func dropdownView(_ view: DropdownView, didSelect album: Album?, index: Int) {
    arrowButton.toggle(false)
    if let album = album {
        selectedImages.removeAll()
        selectedAlbum = album
        selectedAlbumIndex = index
        onSelectedInvoke()
        show(album: album)
    }
  }
    func onSelectedInvoke() {
        SwiftCameraAlbumPlugin.channel.invokeMethod("onSelected", arguments: ["paths": selectedImages.map { $0.asset.localIdentifier }, "durs": selectedImages.map { $0.asset.duration } /*"paths": [file]]*/])
    }
}

extension GalleryView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  // MARK: - UICollectionViewDataSource

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imageItems.count + self.offset
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if #available(iOS 14, *) {
        if self.showAddPhotoCell && indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryAddPhotoCell", for: indexPath) as? GalleryAddPhotoCell else {
                return UICollectionViewCell()
            }
            return cell
        }
    }
    let item = imageItems[(indexPath as NSIndexPath).item - self.offset]
    if let item = item as? Video {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoCell.self), for: indexPath)
        as! VideoCell
        cell.configure(item)
        configureFrameView(cell, indexPath: indexPath)
        return cell
    }
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath)
    as! ImageCell
    cell.configure(item)
    configureFrameView(cell, indexPath: indexPath)
    return cell
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    let size = (collectionView.bounds.size.width - (columnCount - 1) * cellSpacing)
      / columnCount
    return CGSize(width: size, height: size)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if #available(iOS 14, *) {
        if let viewController = UIApplication.shared.keyWindow?.rootViewController, collectionView.cellForItem(at: indexPath) is GalleryAddPhotoCell {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: viewController)
            return
        }
    }
    
    let item = imageItems[(indexPath as NSIndexPath).item - self.offset]
     if limit == 1 {
 //        item.resolve { (image, info) in
 //            guard let info = info else { return }
 //            print(info)
 //            let file = (info["PHImageFileSandboxExtensionTokenKey"] as? NSString)?.components(separatedBy: ";").last ?? ""
             SwiftCameraAlbumPlugin.channel.invokeMethod("onMessage", arguments: ["paths": [item.asset.localIdentifier], "durs": [item.asset.duration], /*"paths": [file]]*/])
 //        }
     } else {
         if selectedImages.contains(item) {
           guard let index = selectedImages.firstIndex(of: item) else { return }
           selectedImages.remove(at: index)
         } else {
           if limit == 0 || limit > selectedImages.count{
             selectedImages.append(item)
           } else {
            // 选超了
            SwiftCameraAlbumPlugin.channel.invokeMethod("onLimitCallback", arguments: nil)
            }
         }
         onSelectedInvoke()
     }

    configureFrameViews()
  }

  func configureFrameViews() {
    if mediaType == .image {
        for case let cell as ImageCell in collectionView.visibleCells {
          if let indexPath = collectionView.indexPath(for: cell) {
            configureFrameView(cell, indexPath: indexPath)
          }
        }
    } else if mediaType == .video {
        for case let cell as VideoCell in collectionView.visibleCells {
          if let indexPath = collectionView.indexPath(for: cell) {
            configureFrameView(cell, indexPath: indexPath)
          }
        }
    }
  }

  func configureFrameView(_ cell: ImageCell, indexPath: IndexPath) {
    let item = imageItems[(indexPath as NSIndexPath).item - self.offset]
    
    if limit > 1 {
        cell.checkImageView.isHidden = false
    } else {
        cell.checkImageView.isHidden = true
    }

    if let _ = selectedImages.firstIndex(of: item) {
      UIView.animate(withDuration: 0.1, animations: {
        cell.checkImageView.image = GalleryBundle.image("gallery_muilt_selected_icon")
      })
//      cell.frameView.label.text = "\(index + 1)"
    } else {
      cell.checkImageView.image = GalleryBundle.image("gallery_muilt_nomal_icon")
    }
  }
}

extension GalleryView: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
//        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        DispatchQueue.main.async {
            self.check()
        }
    }
    
}

class GalleryAddPhotoCell: UICollectionViewCell {
    var imageView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width / 3, height: self.bounds.width / 3)
        self.imageView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
    }
    
    func setupUI() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 0
        
        self.imageView = UIImageView(image:GalleryBundle.image("gallery_addPhoto"))
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
        self.backgroundColor = UIColor(white: 0.3, alpha: 1)
    }
}
