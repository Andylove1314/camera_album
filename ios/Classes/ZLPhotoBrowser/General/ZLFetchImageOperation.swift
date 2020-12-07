//
//  ZLFetchImageOperation.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/18.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import Photos

class ZLFetchImageOperation: Operation {

    let model: ZLPhotoModel
    
    let isOriginal: Bool
    
    let progress: ( (CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void )?
    
    // + TODO:修改源码
    let completion: ( (UIImage?, PHAsset?, String?, String?, Double?) -> Void )
    // + TODO:修改源码
    
    var pri_isExecuting = false {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
        }
        didSet {
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return self.pri_isExecuting
    }
    
    var pri_isFinished = false {
        willSet {
            self.willChangeValue(forKey: "isFinished")
        }
        didSet {
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return self.pri_isFinished
    }
    
    var pri_isCancelled = false {
        willSet {
            self.willChangeValue(forKey: "isCancelled")
        }
        didSet {
            self.didChangeValue(forKey: "isCancelled")
        }
    }

    override var isCancelled: Bool {
        return self.pri_isCancelled
    }
    
    init(model: ZLPhotoModel, isOriginal: Bool, progress: ( (CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void )? = nil, completion:
    // + TODO:修改源码
            @escaping ( (UIImage?, PHAsset?, String?, String?, Double?) -> Void )) {
        // + TODO:修改源码
        self.model = model
        self.isOriginal = isOriginal
        self.progress = progress
        self.completion = completion
        super.init()
    }
    
    override func start() {
        if self.isCancelled {
            self.fetchFinish()
            return
        }
        zl_debugPrint("---- start fetch")
        self.pri_isExecuting = true
        
        // 存在编辑的图片
        if let ei = self.model.editImage {
            if ZLPhotoConfiguration.default().saveNewImageAfterEdit {
                ZLPhotoManager.saveImageToAlbum(image: ei) { [weak self] (suc, asset) in
                    // + TODO:修改源码
                    self?.completion(ei, asset, nil, nil, nil)
                    // + TODO:修改源码
                    self?.fetchFinish()
                }
            } else {
                DispatchQueue.main.async {
                    // + TODO:修改源码
                    self.completion(ei, nil, nil, nil, nil)
                    // + TODO:修改源码
                    self.fetchFinish()
                }
            }
            return
        }
        
        if ZLPhotoConfiguration.default().allowSelectGif, self.model.type == .gif {
            ZLPhotoManager.fetchOriginalImageData(for: self.model.asset) { [weak self] (data, _, isDegraded) in
                if !isDegraded {
                    let image = UIImage.zl_animateGifImage(data: data)
                    // + TODO:修改源码
//                    self?.completion(image, nil)
//                    self?.fetchFinish()
                    if let image = image, let asset = self?.model.asset {
                        self?.saveToSandbox(image: image, asset: asset)
                    }
                    // + TODO:修改源码
                    
                }
            }
            return
        }
        
        if self.isOriginal {
            ZLPhotoManager.fetchOriginalImage(for: self.model.asset, progress: self.progress) { [weak self] (image, isDegraded) in
                if !isDegraded {
                    // + TODO:修改源码
                    self?.completion(image?.fixOrientation(), nil, nil, nil, nil)
                    // + TODO:修改源码
                    self?.fetchFinish()
                }
            }
        } else {
            ZLPhotoManager.fetchImage(for: self.model.asset, size: self.model.previewSize, progress: self.progress) { [weak self] (image, isDegraded) in
                if !isDegraded {
//                    self?.completion(self?.scaleImage(image?.fixOrientation()), nil)
//                    self?.fetchFinish()
                    // + TODO:修改源码
                    if let image = image, let asset = self?.model.asset {
                        self?.saveToSandbox(image: image, asset: asset)
                    }
                    // + TODO:修改源码
                }
            }
        }
    }
    
    func scaleImage(_ image: UIImage?) -> UIImage? {
        guard let i = image else {
            return nil
        }
        guard let data = i.jpegData(compressionQuality: 1) else {
            return i
        }
        let mUnit: CGFloat = 1024 * 1024
        
        if data.count < Int(0.2 * mUnit) {
            return i
        }
        let scale: CGFloat = (data.count > Int(mUnit) ? 0.5 : 0.7)
        
        guard let d = i.jpegData(compressionQuality: scale) else {
            return i
        }
        return UIImage(data: d)
    }
    
    func fetchFinish() {
        self.pri_isExecuting = false
        self.pri_isFinished = true
    }
    
    override func cancel() {
        super.cancel()
        self.pri_isCancelled = true
    }
    
    // + TODO:修改源码
    func saveToSandbox(image: UIImage, asset: PHAsset) {
        if ZLPhotoConfiguration.default().allowSelectImage {
            // 保存源图到沙盒
            ZLPhotoManager.fetchOriginalImageData(for: self.model.asset) { [weak self] (data, info, isDegraded) in
                guard let `self` = self else { return }
                let isHEIC: Bool = data.imageFormat == .HEIC || data.imageFormat == .HEIF
                debugPrint("isDegraded: \(isDegraded)    isHEIC: \(isHEIC)    imageFormat: \(data.imageFormat)")
                var imageData = data
                if isHEIC {
                    if let ciImage = CIImage(data: data) {
                        let context = CIContext()
                        if let colorSpace = ciImage.colorSpace {
                            if #available(iOS 10.0, *) {
                                if let data = context.jpegRepresentation(of: ciImage, colorSpace: colorSpace) {
                                    imageData = data
                                }
                            } else {
                                /*heic文件是目前苹果公司专门制作出来的一种图片格式们目前只适合苹果用户专用，和我们熟知的JPEG、PNG等同类，HEIC是一种图像格式，由苹果公司在近几年推出，iOS11、MacOS High Sierra（10.13）以及更新的版本支持该图片格式。并不是所有的iOS设备都默认支持HEIC图像格式，只有使用A9芯片及以上的设备才可以，比如搭载最新的A11仿生的芯片的iPhone X、iPhone8、iPhone8 Plus会默认使用HEIC图像格式。

                                作者：规规这小子真帅
                                链接：https://www.zhihu.com/question/266966789/answer/356730794
                                来源：知乎
                                著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。*/
                            }
                        }
                    }
                }
                
                let originPath = tmpNwdn + self.model.asset.localIdentifier.replacingOccurrences(of: "/", with: "")
                let previewPath = originPath + "preivew"
                
                // 保存预览图
                if (imageData.imageFormat == .GIF) {
                    try? FileManager.default.removeItem(atPath: previewPath)
                    try? imageData.write(to: URL(fileURLWithPath: previewPath), options: .atomic)
                } else {
                    let pngData = image.pngData()
                    try? FileManager.default.removeItem(atPath: previewPath)
                    try? pngData?.write(to: URL(fileURLWithPath: previewPath), options: .atomic)
                }
                
                // 保存源图
                try? FileManager.default.removeItem(atPath: originPath)
                try? imageData.write(to: URL(fileURLWithPath: originPath), options: .atomic)
                self.completion(self.scaleImage(image.fixOrientation()), nil, originPath, previewPath, nil)
                self.fetchFinish()
            }
        } else {
            // 保存视频到沙盒
            // https://blog.csdn.net/qq_22157341/article/details/80758683
            if let assetResource = PHAssetResource.assetResources(for: asset).first {
                let fileName = assetResource.originalFilename
                    let path = tmpNwdn + fileName
                    try? FileManager.default.removeItem(atPath: path)
                
                let options = PHAssetResourceRequestOptions()
                    options.isNetworkAccessAllowed = true;
                PHAssetResourceManager.default().writeData(for: assetResource, toFile: URL(fileURLWithPath: path), options: options) { (error) in
                    if let error = error {
                        debugPrint(error);
                    } else {
                        DispatchQueue.main.async {
                            self.completion(self.scaleImage(image.fixOrientation()), nil, path, nil, asset.duration)
                            self.fetchFinish()
                        }
                    }
                }
            }
        }
    }
    // + TODO:修改源码
}
