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

class GalleryView: UIView {
    
    var collectionView: UICollectionView!
    
    /// 已选相册
    var selectedAlbum: Album?
    
    var arrowButton: ArrowButton!
    
    /// 所有图片
    var imageItems: [Image] = []
    var imageLibrary: ImagesLibrary?
    
    /// 所有视频
    var videoItems: [Video] = []
    
    /// 最多选择限制
    var limit: Int = 1
    
    /// 已选照片
    var selectedImages: [Image] = []
    
    var mediaType = PHAssetMediaType.image
    
    convenience init(frame: CGRect, mediaType: PHAssetMediaType) {
        self.init(frame: frame)
        self.mediaType = mediaType
        check()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        arrowButton = ArrowButton()
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
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: String(describing: VideoCell.self))
        
        addSubview(collectionView)
        collectionView.g_pin(on: .top, constant: 40)
        collectionView.g_pin(on: .left)
        collectionView.g_pin(on:.right)
        collectionView.g_pin(on: .bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Logic

    func check() {
      if Permission.Photos.status == .notDetermined {
        Permission.Photos.request { [weak self] in
          self?.check()
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
            if mediaType == .video {
                // TODO: - 暂时展示所有视频
                let fetchResults = PHAsset.fetchAssets(with: .video, options: Utils.fetchOptions())
                fetchResults.enumerateObjects({ (asset, _, _) in
                  self?.videoItems.append(Video(asset: asset))
                })
                return
            }
            self?.imageLibrary = ImagesLibrary(mediaType: mediaType)
            self?.imageLibrary?.reload {
                if let album = self?.imageLibrary?.albums.first {
                    self?.selectedAlbum = album
                    self?.show(album: album)
                }
            }
        }
      }
    }

    @objc func arrowButtonTouched(_ button: ArrowButton) {
        let dropdownView = DropdownView()
        dropdownView.top = 120//arrowButton.frame.maxY
        dropdownView.albums = self.imageLibrary?.albums ?? []
        dropdownView.tableView.reloadData()
        (UIApplication.shared.delegate as! FlutterAppDelegate).window.addSubview(dropdownView)
        dropdownView.delegate = self

      dropdownView.show()
      button.toggle(true)
    }

    func show(album: Album) {
      arrowButton.updateText(album.collection.localizedTitle ?? "")
        if mediaType == .image {
            imageItems = album.items
        } else if mediaType == .video {
            videoItems = album.videoItems
        }
        
      collectionView.reloadData()
      collectionView.g_scrollToTop()
    }
}

extension GalleryView: DropdownViewDelegate {

  func dropdownView(_ view: DropdownView, didSelect album: Album?) {
    arrowButton.toggle(false)
    if let album = album {
        selectedAlbum = album
        show(album: album)
    }
  }
}

extension GalleryView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  // MARK: - UICollectionViewDataSource

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch mediaType {
    case .image:
        return imageItems.count
    case .video:
        return videoItems.count
    default:
        return 0
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if mediaType == .video {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoCell.self), for: indexPath)
          as! VideoCell
          let item = videoItems[(indexPath as NSIndexPath).item]

          cell.configure(item)
          configureFrameView(cell, indexPath: indexPath)
        return cell
    }

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath)
      as! ImageCell
    let item = imageItems[(indexPath as NSIndexPath).item]

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
    if mediaType == .video {
        let item = videoItems[(indexPath as NSIndexPath).item]
        SwiftCameraAlbumPlugin.channel.invokeMethod("onMessage", arguments: ["identifier": [item.asset.localIdentifier], /*"paths": [file]]*/])
    } else {
        let item = imageItems[(indexPath as NSIndexPath).item]
        if limit == 1 {
        //        item.resolve { (image, info) in
        //            guard let info = info else { return }
        //            print(info)
        //            let file = (info["PHImageFileSandboxExtensionTokenKey"] as? NSString)?.components(separatedBy: ";").last ?? ""
                    SwiftCameraAlbumPlugin.channel.invokeMethod("onMessage", arguments: ["identifier": [item.asset.localIdentifier], /*"paths": [file]]*/])
        //        }
            } else if selectedImages.contains(item) {
              guard let index = selectedImages.firstIndex(of: item) else { return }
              selectedImages.remove(at: index)
            } else {
              if limit == 0 || limit > selectedImages.count{
                selectedImages.append(item)
              }
            }
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
//    let item = items [(indexPath as NSIndexPath).item]
//
//    if let index = images.firstIndex(of: item) {
//      UIView.animate(withDuration: 0.1, animations: {
//        cell.imageView.alpha = 1
//      })
//      cell.frameView.label.text = "\(index + 1)"
//    } else {
//      cell.imageView.alpha = 0
//    }
  }
}
