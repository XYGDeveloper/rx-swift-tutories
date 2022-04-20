# RxSwift_turtus

## 介绍
[RxSwift中文文档](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/first_app.html)
## 安装指导

## 基本用法
### 1. button点击事件

```
  button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)

```
-》

```
  button.rx.tap.subscribe(onNext: {
            print("button tap")
        })
        .disposed(by: disposeBag)

```

### 2. 代理

```
extension ViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }
}

//        scrollview.delegate  = self

```
-》
```
 scrollview.rx.contentOffset.subscribe(onNext:{ offset in
            print(offset)
        })
        .disposed(by: disposeBag)

```

### 3. 闭包回调


```
   URLSession.shared.dataTask(with: URL(string: "http://www.baidu.com")!) { data, response, error in
            guard let data = data else {
                print("get data error")
                return
            }
            guard let response = response else {
                print("get response error")
                return
            }
            guard let error = error else {
                return
            }

            print(data)
            print(response)
            print(error)

        }.resume()
```

-》 

```
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
```
### 4. 通知

```
 _ = NotificationCenter.default.addObserver(forName:UIApplication.didEnterBackgroundNotification, object: nil, queue: nil, using: { notification in
            print(notification)
        })
```
-》

```
 NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .subscribe(onNext: {
                notofication in
                print(notofication)
            })
            .disposed(by: disposeBag)
```
### 5. 异步顺序，通过用户名获取token，然后通过token获取userinfo

```
enum API{
    
    static func token(username:String,password:String,secuess:(String)->Void,failure:(Error)->Void){
        
    }
    
    static func userinfo(token:String,scuess:(String)->Void,failure:(Error)->Void){
        
    }
    
}

API.token(username: "username", password: "123456") { token in
            print(token)
            //然后获取用户信息
            API.userinfo(token: token, scuess: {
                userinfo in
                print(userinfo)
            }, failure: {
                error in
                print(error)
            })
        } failure: { error in
            print(error)
        }
```
=》

```
enum API{

    static func token(username:String,password:String)->Observable<String>{

    }

    static func userInfo(token:String)->Observable<String>{

    }

}

 API.token(username: "username", password: "password")
            .flatMapLatest(API.userInfo)
            .subscribe(onNext: {
                userinfo in
                print(userinfo)
            }, onError: {
                error in
                print(error)
            })
            .disposed(by: disposeBag)
```

### 6. 合并请求

```
enum API{

    static func getTeacher(teacherid:String)->Observable<Teacher>{

    }

    static func GetTeacherComment(teacherId:String)->Observable<[Comment]>{

    }
}

    Observable.zip(
            API.getTeacher(teacherid: "teacherId")
            API.GetTeacherComment(teacherId: "teacherId")
        ).subscribe(onNext:{
            (teacher,comments) in
            print(teacher)
            print(comments.count)
        }, onError: {
            error in
            print(error)
        }, onCompleted: {
            print("finish")
        })
        .disposed(by: disposeBag)
```

## 验证输入案例
### 0. 逻辑思路
![输入图片说明](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/assets/SimpleValid/All.png)

### 1. 效果展示
![rxswift验证登录](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/assets/SimpleValid/SimpleValidationFull.gif)
### 2. 验证登录demo

```
//
//  SimpleVallibViewController.swift
//  RxSwiftDemo
//
//  Created by xwtech on 2022/4/20.
//

import UIKit
import RxSwift

private let minmalUserLength = 5

private let minimalPasswordLength = 5

class SimpleVallibViewController: UIViewController {
    
    @IBOutlet weak var usernameOutlet: UITextField!
    
    @IBOutlet weak var usernameValidOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    
    @IBOutlet weak var passwordValidOutlet: UILabel!
    
    @IBOutlet weak var doSomethingOutlet: UIButton!
    
    var disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameValidOutlet.text = "username less \(minmalUserLength) characters."
        passwordValidOutlet.text  = "password less =\(minimalPasswordLength) characters."
        // 用户名是否有效
        let usernameValid = usernameOutlet.rx.text.orEmpty
            .map{$0.count >= minmalUserLength}
            .share(replay: 1)
        
        // 用户名是否有效 -> 密码输入框是否可用
        usernameValid.bind(to: passwordOutlet.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 用户名是否有效 -> 用户名提示语是否隐藏
        usernameValid.bind(to: usernameValidOutlet.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 密码是否有效
        let passwordValid = passwordOutlet.rx.text.orEmpty
            .map{$0.count >= minimalPasswordLength}
            .share(replay: 1)
        
        // 密码是否有效 -> 密码提示语是否隐藏
        passwordValid.bind(to: passwordValidOutlet.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 所有输入是否有效
        let everyThingValid = Observable.combineLatest(
            usernameValid,
            passwordValid
        ){ $0 && $1}
            .share(replay: 1)
        
        // 所有输入是否有效 -> 绿色按钮是否可点击
        everyThingValid.bind(to: doSomethingOutlet.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 点击绿色按钮 -> 弹出提示框
        doSomethingOutlet.rx.tap.subscribe(onNext: {
            [weak self] in
            self!.showAlert()
        })
        
    }
    
    func showAlert() {
        let alertController = UIAlertController(
            title: "alert title",
            message: "alert message",
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "ok",
            style: .default) { action in
                print(action)
            }
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    
    
}

```
## 函数响应式编程
![输入图片说明](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/assets/FunctionalReactiveProgramming/FunctionalReactiveProgramming.png)
### 0. 逻辑思路
### 0. 逻辑思路
### 0. 逻辑思路
### 0. 逻辑思路
