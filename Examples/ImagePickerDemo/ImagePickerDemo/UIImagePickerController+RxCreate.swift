//
//  UIImagePickerController+RxCreate.swift
//  ImagePickerDemo
//
//  Created by xwtech on 2022/4/25.
//

import UIKit
import RxSwift
import RxCocoa
func dismissViewcontroller(_ viewController:UIViewController,animate:Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewcontroller(viewController, animate: animate)
        }
        return
    }
    if viewController.presentedViewController != nil {
        dismissViewcontroller(viewController, animate: animate)
    }
    
}

extension Reactive where Base:UIImagePickerController{
    static func createWithParent(_ parent: UIViewController?, animated: Bool = true, configureImagePicker: @escaping (UIImagePickerController) throws -> Void = { x in }) -> Observable<UIImagePickerController> {
            return Observable.create { [weak parent] observer in
                let imagePicker = UIImagePickerController()
                let dismissDisposable = imagePicker.rx
                    .didCancel
                    .subscribe(onNext: { [weak imagePicker] _ in
                        guard let imagePicker = imagePicker else {
                            return
                        }
                        dismissViewcontroller(imagePicker, animate: animated)
                    })
                
                do {
                    try configureImagePicker(imagePicker)
                }
                catch let error {
                    observer.on(.error(error))
                    return Disposables.create()
                }

                guard let parent = parent else {
                    observer.on(.completed)
                    return Disposables.create()
                }

                parent.present(imagePicker, animated: animated, completion: nil)
                observer.on(.next(imagePicker))
                
                return Disposables.create(dismissDisposable, Disposables.create {
                    dismissViewcontroller(imagePicker, animate: animated)
                    })
            }
        }
}
