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

class GalleryImageView: UIView {
    
    var collectionView: UICollectionView!
    
    var arrowButton: ArrowButton!
    
    var items: [Image] = []
    let library = ImagesLibrary()
    var selectedAlbum: Album?
    
    var imageLimit: Int = 1
    var images: [Image] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        arrowButton = ArrowButton()
        addSubview(arrowButton)
        arrowButton.g_pin(on: .centerX)
        arrowButton.g_pin(height: 40)
        
        arrowButton.addTarget(self, action: #selector(arrowButtonTouched(_:)), for: .touchUpInside)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 50, width: frame.width, height: frame.height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GalleryImageCell.self, forCellWithReuseIdentifier: String(describing: GalleryImageCell.self))
        addSubview(collectionView)
        
        library.reload {
            if let album = self.library.albums.first {
                self.selectedAlbum = album
                self.show(album: album)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func arrowButtonTouched(_ button: ArrowButton) {
        let dropdownView = DropdownView()
        dropdownView.top = 120//arrowButton.frame.maxY
        dropdownView.albums = self.library.albums
        dropdownView.tableView.reloadData()
        (UIApplication.shared.delegate as! FlutterAppDelegate).window.addSubview(dropdownView)
        dropdownView.delegate = self

      dropdownView.show()
      button.toggle(true)
    }

    func show(album: Album) {
      arrowButton.updateText(album.collection.localizedTitle ?? "")
      items = album.items
      collectionView.reloadData()
      collectionView.g_scrollToTop()
    }
}

extension GalleryImageView: DropdownViewDelegate {

  func dropdownView(_ view: DropdownView, didSelect album: Album?) {
    arrowButton.toggle(false)
    if let album = album {
        selectedAlbum = album
        show(album: album)
    }
  }
}

extension GalleryImageView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  // MARK: - UICollectionViewDataSource

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GalleryImageCell.self), for: indexPath)
      as! GalleryImageCell
    let item = items[(indexPath as NSIndexPath).item]

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
    let item = items[(indexPath as NSIndexPath).item]
    
    if imageLimit == 1 {
        item.resolve { (image, info) in
            guard let image = image?.jpegData(compressionQuality: 0.5), let info = info else { return }
            print(info)
            let file = (info["PHImageFileSandboxExtensionTokenKey"] as? NSString)?.components(separatedBy: ";").last ?? ""
            SwiftCameraAlbumPlugin.channel.invokeMethod("selected", arguments: ["identifier": item.asset.burstIdentifier ?? "", "image": image, "file": file])
        }
    } else if images.contains(item) {
      guard let index = images.firstIndex(of: item) else { return }
      images.remove(at: index)
    } else {
      if imageLimit == 0 || imageLimit > images.count{
        images.append(item)
      }
    }

    configureFrameViews()
  }

  func configureFrameViews() {
    for case let cell as GalleryImageCell in collectionView.visibleCells {
      if let indexPath = collectionView.indexPath(for: cell) {
        configureFrameView(cell, indexPath: indexPath)
      }
    }
  }

  func configureFrameView(_ cell: GalleryImageCell, indexPath: IndexPath) {
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
