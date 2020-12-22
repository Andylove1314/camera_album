//
//  MainModule.swift
//  Runner
//
//  Created by OctMon on 2020/12/21.
//

import Foundation
import thrio

class MainModule: ThrioModule {
    override func onPageBuilderRegister() {
        register({ (_) -> UIViewController? in
            return UIViewController()
        }, forUrl: "/biz1/test")
    }
}
