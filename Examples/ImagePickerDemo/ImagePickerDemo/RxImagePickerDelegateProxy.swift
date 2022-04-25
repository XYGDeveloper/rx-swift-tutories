//
//  RxImagePickerDelegateProxy.swift
//  ImagePickerDemo
//
//  Created by xwtech on 2022/4/25.
//

#if os(iOS)

import RxSwift
import RxCocoa
import UIKit

open class RxImagePickerDelegateProxy
    : RxNavigationControllerDelegateProxy, UIImagePickerControllerDelegate {

    public init(imagePicker: UIImagePickerController) {
        super.init(navigationController: imagePicker)
    }

}

#endif
