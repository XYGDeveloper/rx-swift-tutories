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
### 7. 数据绑定（订阅）


```
let image: UIImage = UIImage(named: ...)
imageView.image = image
```
-》

```
let image: Observable<UIImage> = ...
image.bind(to: imageView.rx.image)
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
### 0. 函数式编程
[函数式编程](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/think_reactive/funtional_programming.html)
### 1. 函数式编程 -> 函数响应式编程
[函数式编程 -> 函数响应式编程](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/think_reactive/functional_reactive_progaramming.html)
### 2. 数据绑定（订阅）
[数据绑定](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/think_reactive/data_binding.html)
## RxSwift核心
### 1. 序列
#### 所有的事物都是序列，
Observable<Double> 温度，你可以将温度看作是一个序列，然后监测这个温度值，最后对这个值做出响应。例如：当室温高于 33 度时，打开空调降温。Observable<OnePieceEpisode> 《海贼王》动漫，你也可以把《海贼王》的动漫看作是一个序列。然后当《海贼王》更新一集时，我们就立即观看这一集。Observable<JSON> JSON，你可以把网络请求的返回的 JSON 看作是一个序列。然后当取到 JSON 时，将它打印出来。Observable<Void> 任务回调，你可以把任务回调看作是一个序列。当任务结束后，提示用户任务已完成。
#### 如何创建序列
现在我们已经可以把生活中的许多事物看作是一个序列了。那么我们要怎么创建这些序列呢？

实际上，框架已经帮我们创建好了许多常用的序列。例如：button的点击，textField的当前文本，switch的开关状态，slider的当前数值等等。

另外，有一些自定义的序列是需要我们自己创建的。这里介绍一下创建序列最基本的方法，例如，我们创建一个 [0, 1, ... 8, 9] 的序列：

```
var disposeBag = DisposeBag()
    
    let numbers:Observable<Int> = Observable.create { observer -> Disposable in
        observer.onNext(0)
        observer.onNext(1)
        observer.onNext(2)
        observer.onNext(3)
        observer.onNext(4)
        observer.onNext(5)
        observer.onNext(6)
        observer.onNext(7)
        observer.onNext(8)
        observer.onNext(9)
        observer.onCompleted()
        return Disposables.create()
    }

 numbers.subscribe(onNext: {
            number in
            print(number)
        })
        .disposed(by: disposeBag)
```
创建序列最直接的方法就是调用 Observable.create，然后在构建函数里面描述元素的产生过程。 observer.onNext(0) 就代表产生了一个元素，他的值是 0。后面又产生了 9 个元素分别是 1, 2, ... 8, 9 。最后，用 observer.onCompleted() 表示元素已经全部产生，没有更多元素了。
你可以用这种方式来封装功能组件，例如，闭包回调：

```
 let json:Observable<JSON> = Observable.create { (observer) -> Disposable in
        let task = URLSession.shared.dataTask(with: URL(string: "")!) { data, reponse, error in
            guard error == nil else{
                observer.onError(error!)
                return
            }
            guard let data = data,let jsonObject = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed) else {
                observer.onError(error!)
                return
            }
            observer.onNext(jsonObject)
            observer.onCompleted()
        }
        task.resume()
        
        return Disposables.create {
            task.cancel()
        }


 json.subscribe(onNext: {
            jsonObject in
            print(jsonObject)
        }, onError: {
            error in
            print(error)
        }, onCompleted: {
            print("finish")
        })
        .disposed(by: disposeBag)
```
#### Event - 事件

```
public enum Event<Element> {
    case next(Element)
    case error(Swift.Error)
    case completed
}
```

- next - 序列产生了一个新的元素
- error - 创建序列时产生了一个错误，导致序列终止
- completed - 序列的所有元素都已经成功产生，整个序列已经完成
### 1.1. 特征序列
#### Single
Single 是 Observable 的另外一个版本。不像 Observable 可以发出多个元素，它要么只能发出一个元素，要么产生一个 error 事件。

发出一个元素，或一个 error 事件
不会共享附加作用
一个比较常见的例子就是执行 HTTP 请求，然后返回一个应答或错误。不过你也可以用 Single 来描述任何只有一个元素的序列。
```
func getRepo(_ repo:String) -> Single<[String:Any]> {
        return Single<[String:Any]>.create { single in
            let url = URL(string: "https://api.github.com/repos/\(repo)")!
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    single(.error(error))
                }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                      let result = json as? [String:Any] else {
                    single(.error(error!))
                    return
                }
                single(.success(result))
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }



 getRepo("XYGDeveloper/RemoteImageView_swiftSPM")
            .subscribe(onSuccess: {
                result in
                print(result)
            }, onError: {
                error in
                print(error)
            })
            .disposed(by: disposeBag)

```

- 订阅提供一个 SingleEvent 的枚举：

```
public enum SingleEvent<Element> {
    case success(Element)
    case error(Swift.Error)
}
```

- success - 产生一个单独的元素
- error - 产生一个错误
- 你同样可以对 Observable 调用 .asSingle() 方法，将它转换为 Single。


#### Completable

- Completable 是 Observable 的另外一个版本。不像 Observable 可以发出多个元素，它要么只能产生一个 completed 事件，要么产生一个 error 事件。
- 发出零个元素
- 发出一个 completed 事件或者一个 error 事件
- 不会共享附加作用
- Completable 适用于那种你只关心任务是否完成，而不需要在意任务返回值的情况。它和 Observable<Void> 有点相似。


```
  func cacheLocal() -> Completable {
        return Completable.create { complete in
            /* 进行缓存操作
                ....
                ....
            */
            guard let success else{
                completable(.error(CacheError.failedCaching))
                return Disposables.create {}
            }
            complete(.completed)
            return Disposables.create{}
        }
    }



 cacheLocal().subscribe(onCompleted: {
            
        }, onError: {
            error in
            print(error)
        })
        .disposed(by: disposeBag)
```
订阅提供一个 CompletableEvent 的枚举：

```
public enum CompletableEvent {
    case error(Swift.Error)
    case completed
}
```

- completed - 产生完成事件
- error - 产生一个错误

#### Maybe

- Maybe 是 Observable 的另外一个版本。它介于 Single 和 Completable 之间，它要么只能发出一个元素，要么产生一个 completed 事件，要么产生一个 error 事件。
- 
- 发出一个元素或者一个 completed 事件或者一个 error 事件
- 不会共享附加作用
- 如果你遇到那种可能需要发出一个元素，又可能不需要发出时，就可以使用 Maybe。

```
 func generalString() -> Maybe<String> {
        return Maybe<String>.create { maybe in
            maybe(.success("RXSWIFT"))
            maybe(.completed)
            let error = NSError()
            maybe(.error(error))
            return Disposables.create {}
        }
    }

generalString().subscribe(onSuccess: {
            success in
            print("get maybe string is\(success)")
        }, onError: {
            error in
            print(error)
        }, onCompleted: {
            print("complete")
        })
        .disposed(by: disposeBag)
```

- 你同样可以对 Observable 调用 .asMaybe() 方法，将它转换为 Maybe。

#### Driver

- Driver（司机？） 是一个精心准备的特征序列。它主要是为了简化 UI 层的代码。不过如果你遇到的序列具有以下特征，你也可以使用它：
- 
- 不会产生 error 事件
- 一定在 MainScheduler 监听（主线程监听）
- 共享附加作用
- 这些都是驱动 UI 的序列所具有的特征。
我们举个例子来说明一下，为什么要使用 Driver。

这是文档简介页的例子：

#### Signal

#### ControlEvent

### 2. 观察者
### 3. 既是可监听序列也是观察者
### 4. 操作符
### 4. 可被清除的资源
### 4. 调度器
### 4. 错误处理


