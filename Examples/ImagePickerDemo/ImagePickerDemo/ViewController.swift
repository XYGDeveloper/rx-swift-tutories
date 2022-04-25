//
//  ViewController.swift
//  ImagePickerDemo
//
//  Created by xwtech on 2022/4/25.
//

import UIKit
import RxCocoa
import RxSwift
class ViewController: UIViewController {
    @IBOutlet weak var imageview: UIImageView!
    
    @IBOutlet weak var camerabutton: UIButton!
    
    @IBOutlet weak var libararyButton: UIButton!
    
    @IBOutlet weak var dropButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 拍照获取图片
        camerabutton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        camerabutton.rx.tap
            .flatMapLatest{
                [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self){
                    picker in
                    picker.sourceType = .camera
                    picker.allowsEditing = false
                }
                .flatMap{$0.rx.didFinishPickingMediaWithInfo}
                .take(1)
            }
            .map{ info in return info[.originalImage] as? UIImage}
            .bind(to: imageview.rx.image)
            .disposed(by: disposeBag)
       
        // 图片库获取图片
        libararyButton.rx.tap
            .flatMapLatest{
                [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self){
                    picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = false
                }
                .flatMap{$0.rx.didFinishPickingMediaWithInfo}
                .take(1)
            }
            .map{ info in return info[.originalImage] as? UIImage}
            .bind(to: imageview.rx.image)
            .disposed(by: disposeBag)
        
        // 图片库编辑并获取
        dropButton.rx.tap
            .flatMapLatest{
                [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self){
                    picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = true
                }
                .flatMap{$0.rx.didFinishPickingMediaWithInfo}
                .take(1)
            }
            .map{ info in return info[.originalImage] as? UIImage}
            .bind(to: imageview.rx.image)
            .disposed(by: disposeBag)
    }


}

