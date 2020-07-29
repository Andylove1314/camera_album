//
//  CameraView.swift
//  camera_album
//
//  Created by OctMon on 2020/7/29.
//

import UIKit

class CameraView: UIView {
    
    var appBarHeight: CGFloat = 0
    
    convenience init(frame: CGRect, appBarHeight: CGFloat) {
        self.init(frame: frame)

        self.appBarHeight = appBarHeight
        
        check()
    }
    
    // MARK: - Logic

    func check() {
      if Permission.Camera.status == .notDetermined {
        Permission.Camera.request { [weak self] in
          self?.check()
        }

        return
      }
    
        DispatchQueue.main.async { [weak self] in
            guard Permission.Camera.status == .authorized else {
                let permissionView = PermissionView(needsPermission: true)
                self?.addSubview(permissionView)
                permissionView.g_pinEdges()
                return
            }
            self?.backgroundColor = UIColor.red
        }
    }
    
}
