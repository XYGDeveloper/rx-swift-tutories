//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by xwtech on 2022/4/20.
//

import UIKit
import RxSwift
import RxCocoa
class ViewController: UIViewController {
    lazy var button: UIButton = {
        let button = UIButton(frame: CGRect(x: 100, y: 200, width: 200, height: 50))
        button.backgroundColor = UIColor.red
        button.setTitle("rxbutton", for: .normal)
        view.addSubview(button)
        return button
    }()
    lazy var scrollview: UIScrollView = {
        let scrolview = UIScrollView(frame: CGRect(x: 100, y: 250, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height/2))
        scrolview.backgroundColor = UIColor.blue
        scrolview.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        scrolview.showsVerticalScrollIndicator = true
        scrolview.isPagingEnabled = true
        scrolview.delegate  = self
        return scrolview
    }()
        
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //RxSwift基本用法
        
        view.addSubview(scrollview)
//        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
         
//        scrollview.delegate  = self
        
        button.rx.tap.subscribe(onNext: {
            print("button tap")
        })
        .disposed(by: disposeBag)
        
        scrollview.rx.contentOffset.subscribe(onNext:{ offset in
            print(offset)
        })
        .disposed(by: disposeBag)
        
//        URLSession.shared.dataTask(with: URL(string: "http://www.baidu.com")!) { data, response, error in
//            guard let data = data else {
//                print("get data error")
//                return
//            }
//            guard let response = response else {
//                print("get response error")
//                return
//            }
//            guard let error = error else {
//                return
//            }
//
//            print(data)
//            print(response)
//            print(error)
//
//        }.resume()
        
        URLSession.shared.rx.data(request: URLRequest(url: URL(string: "https://www.baidu.com")!))
            .subscribe(onNext: {
                data in
                print(data)
            }, onError: {
                error in
                print(error)
            }, onCompleted: {
                print("finilish")
            })
            .disposed(by: disposeBag)
        
        
//        _ = NotificationCenter.default.addObserver(forName:UIApplication.didEnterBackgroundNotification, object: nil, queue: nil, using: { notification in
//            print(notification)
//        })
        
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .subscribe(onNext: {
                notofication in
                print(notofication)
            })
            .disposed(by: disposeBag)
        
        
//        API.token(username: "username", password: "123456") { token in
//            print(token)
//            //然后获取用户信息
//            API.userinfo(token: token, scuess: {
//                userinfo in
//                print(userinfo)
//            }, failure: {
//                error in
//                print(error)
//            })
//        } failure: { error in
//            print(error)
//        }
        
//        API.token(username: "username", password: "password")
//            .flatMapLatest(API.userInfo)
//            .subscribe(onNext: {
//                userinfo in
//                print(userinfo)
//            }, onError: {
//                error in
//                print(error)
//            })
//            .disposed(by: disposeBag)

        
        /// 同时取得老师信息和老师评论
        
//        Observable.zip(
//            API.getTeacher(teacherid: "teacherId")
//            API.GetTeacherComment(teacherId: "teacherId")
//        ).subscribe(onNext:{
//            (teacher,comments) in
//            print(teacher)
//            print(comments.count)
//        }, onError: {
//            error in
//            print(error)
//        }, onCompleted: {
//            print("finish")
//        })
//        .disposed(by: disposeBag)
        
    }
    
    @objc func buttonTap() {
        print("button tap")
    }

}

extension ViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }
}


/*
enum API{
    
    static func token(username:String,password:String,secuess:(String)->Void,failure:(Error)->Void){
        
    }
    
    static func userinfo(token:String,scuess:(String)->Void,failure:(Error)->Void){
        
    }
    
}
*/

//enum API{
//
//    static func token(username:String,password:String)->Observable<String>{
//
//    }
//
//    static func userInfo(token:String)->Observable<String>{
//
//    }
//
////}


//enum API{
//
//    static func getTeacher(teacherid:String)->Observable<Teacher>{
//
//    }
//
//    static func GetTeacherComment(teacherId:String)->Observable<[Comment]>{
//
//    }
//}
