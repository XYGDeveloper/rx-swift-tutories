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

```
let results = query.rx.text
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
    }

results
    .map { "\($0.count)" }
    .bind(to: resultCount.rx.text)
    .disposed(by: disposeBag)

results
    .bind(to: resultsTableView.rx.items(cellIdentifier: "Cell")) {
      (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .disposed(by: disposeBag)
```
这段代码的主要目的是：

取出用户输入稳定后的内容
向服务器请求一组结果
将返回的结果绑定到两个 UI 元素上：tableView 和 显示结果数量的label
那么这里存在什么问题？

如果 fetchAutoCompleteItems 的序列产生了一个错误（网络请求失败），这个错误将取消所有绑定，当用户输入一个新的关键字时，是无法发起新的网络请求。
如果 fetchAutoCompleteItems 在后台返回序列，那么刷新页面也会在后台进行，这样就会出现异常崩溃。
返回的结果被绑定到两个 UI 元素上。那就意味着，每次用户输入一个新的关键字时，就会分别为两个 UI 元素发起 HTTP 请求，这并不是我们想要的结果。
一个更好的方案是这样的：

```
let results = query.rx.text
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
            .observeOn(MainScheduler.instance)  // 结果在主线程返回
            .catchErrorJustReturn([])           // 错误被处理了，这样至少不会终止整个序列
    }
    .share(replay: 1)                             // HTTP 请求是被共享的

results
    .map { "\($0.count)" }
    .bind(to: resultCount.rx.text)
    .disposed(by: disposeBag)

results
    .bind(to: resultsTableView.rx.items(cellIdentifier: "Cell")) {
      (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .disposed(by: disposeBag)
```
在一个大型系统内，要确保每一步不被遗漏是一件不太容易的事情。所以更好的选择是合理运用编译器和特征序列来确保这些必备条件都已经满足。

以下是使用 Driver 优化后的代码：

```
let results = query.rx.text.asDriver()        // 将普通序列转换为 Driver
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
            .asDriver(onErrorJustReturn: [])  // 仅仅提供发生错误时的备选返回值
    }

results
    .map { "\($0.count)" }
    .drive(resultCount.rx.text)               // 这里改用 `drive` 而不是 `bindTo`
    .disposed(by: disposeBag)                 // 这样可以确保必备条件都已经满足了

results
    .drive(resultsTableView.rx.items(cellIdentifier: "Cell")) {
      (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .disposed(by: disposeBag)
```

```
首先第一个 asDriver 方法将 ControlProperty 转换为 Driver

然后第二个变化是：

.asDriver(onErrorJustReturn: [])
任何可监听序列都可以被转换为 Driver，只要他满足 3 个条件：

不会产生 error 事件
一定在 MainScheduler 监听（主线程监听）
共享附加作用
那么要如何确定条件都被满足？通过 Rx 操作符来进行转换。asDriver(onErrorJustReturn: []) 相当于以下代码：

let safeSequence = xs
  .observeOn(MainScheduler.instance)       // 主线程监听
  .catchErrorJustReturn(onErrorJustReturn) // 无法产生错误
  .share(replay: 1, scope: .whileConnected)// 共享附加作用
return Driver(raw: safeSequence)           // 封装
最后使用 drive 而不是 bindTo

drive 方法只能被 Driver 调用。这意味着，如果你发现代码所存在 drive，那么这个序列不会产生错误事件并且一定在主线程监听。这样你可以安全的绑定 UI 元素。
```

#### Signal

- Signal 和 Driver 相似，唯一的区别是，Driver 会对新观察者回放（重新发送）上一个元素，而 Signal 不会对新观察者回放上一个元素。
- 
- 他有如下特性:
- 
- 不会产生 error 事件
- 一定在 MainScheduler 监听（主线程监听）
- 共享附加作用
- 现在，我们来看看以下代码是否合理：

```
let textField: UITextField = ...
let nameLabel: UILabel = ...
let nameSizeLabel: UILabel = ...

let state: Driver<String?> = textField.rx.text.asDriver()

let observer = nameLabel.rx.text
state.drive(observer)

// ... 假设以下代码是在用户输入姓名后运行

let newObserver = nameSizeLabel.rx.text
state.map { $0?.count.description }.drive(newObserver)
```
这个例子只是将用户输入的姓名绑定到对应的标签上。当用户输入姓名后，我们创建了一个新的观察者，用于订阅姓名的字数。那么问题来了，订阅时，展示字数的标签会立即更新吗？

嗯、、、 因为 Driver 会对新观察者回放上一个元素（当前姓名），所以这里是会更新的。在对他进行订阅时，标签的默认文本会被刷新。这是合理的。

那如果我们用 Driver 来描述点击事件呢，这样合理吗？

```
let button: UIButton = ...
let showAlert: (String) -> Void = ...

let event: Driver<Void> = button.rx.tap.asDriver()

let observer: () -> Void = { showAlert("弹出提示框1") }
event.drive(onNext: observer)

// ... 假设以下代码是在用户点击 button 后运行

let newObserver: () -> Void = { showAlert("弹出提示框2") }
event.drive(onNext: newObserver)
```

- 在同样的场景中，Signal 不会把上一次的点击事件回放给新观察者，而只会将订阅后产生的点击事件，发布给新观察者。这正是我们所需要的。
- 
- 结论
- 
- 一般情况下状态序列我们会选用 Driver 这个类型，事件序列我们会选用 Signal 这个类型。

#### ControlEvent

- ControlEvent 专门用于描述 UI 控件所产生的事件，它具有以下特征：
- 
- 不会产生 error 事件
- 一定在 MainScheduler 订阅（主线程订阅）
- 一定在 MainScheduler 监听（主线程监听）
- 共享附加作用

### 2. 观察者
#### Observer - 观察者 [输入链接说明](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/rxswift_core/observer.html)
#### AnyObserver
AnyObserver 可以用来描叙任意一种观察者。


```
URLSession.shared.rx.data(request: URLRequest(url: URL(string: "https://api.github.com/repos/XYGDeveloper/RemoteImageView_swiftSPM")!))
            .subscribe(onNext: {
                data in
                print(data)
            }, onError: {
                error in
                print(error)
            }, onCompleted: {
                print("finish")
            })
            .disposed(by: disposeBag)
```
可以看做是：

```
   let anyObserver:AnyObserver<Data> = AnyObserver{
            (event) in
            switch event{
                case .next(let data):
                        print(data)
                case .error(let error):
                    print(error)
                case .completed:
                    print("")
            }
        }
```




```
let usernameValid = textField.rx.text.orEmpty
            .map{
                $0.count >= 6
            }
            .share(replay: 1)
        
        usernameValid.bind(to: nameLabel.rx.isHidden)
```
可以看做是：

```
 let obser:AnyObserver<Bool>  = AnyObserver{
            [weak self]
            (event) in
            switch event{
              case .next(let isHidden):
                self?.nameLabel.isHidden = isHidden
                break
            default:
                break
            }
        }
 usernameValid.bind(to: obser).disposed(by: disposeBag)

```

#### Binder
Binder 主要有以下两个特征：


- 不会处理错误事件
- 确保绑定都是在给定 Scheduler 上执行（默认 MainScheduler）
- 一旦产生错误事件，在调试环境下将执行 fatalError，在发布环境下将打印错误信息。
在介绍 AnyObserver 时，我们举了这样一个例子：

```
let observer: AnyObserver<Bool> = AnyObserver { [weak self] (event) in
    switch event {
    case .next(let isHidden):
        self?.usernameValidOutlet.isHidden = isHidden
    default:
        break
    }
}

usernameValid
    .bind(to: observer)
    .disposed(by: disposeBag)
```
由于这个观察者是一个 UI 观察者，所以它在响应事件时，只会处理 next 事件，并且更新 UI 的操作需要在主线程上执行。

因此一个更好的方案就是使用 Binder：

```
let obsser:Binder<Bool> = Binder(nameLabel){
            (view,ishidden) in
            view.isHidden = ishidden
        }
        
        usernameValid.bind(to: obsser).disposed(by: disposeBag)
```
Binder 可以只处理 next 事件，并且保证响应 next 事件的代码一定会在给定 Scheduler 上执行，这里采用默认的 MainScheduler。
你也可以用这种方式来创建自定义的 UI 观察者。

```
//nameLabel.rx.isHidde
extension Reactive where Base: UIView{
    public var isHidde:Binder<Bool>{
        return Binder(self.base){
            view, isHidden in
            view.isHidden = isHidden
        }
    }
}

//button.rx.isEnabled
extension Reactive where Base: UIControl{
    public var isEnabled:Binder<Bool>{
        return Binder(self.base){
            control, value in
            control.isEnabled = value
        }
    }
}

//nameLabel.rx.text
extension Reactive where Base: UILabel{
    public var text:Binder<String?>{
        return Binder(self.base){
            label, text in
            label.text = text
        }
    }
}
```

### 3. 既是可监听序列也是观察者
在我们所遇到的事物中，有一部分非常特别。它们既是可监听序列也是观察者。

例如：textField的当前文本。它可以看成是由用户输入，而产生的一个文本序列。也可以是由外部文本序列，来控制当前显示内容的观察者：

```
//        textField可监听序列
        let observable =  usernameOutlet.rx.text
        observable.subscribe(onNext: {
            text in
            print(text)
        }, onError: {
            error in
            print(error)
        })
        .disposed(by: disposeBag)
        
        
//        textField作为观察者
        let observer01  = usernameOutlet.rx.text
        let textobservable:Observable<String?> = Observable.create { obser -> Disposable in
            obser.onNext("hello")
            obser.onCompleted()
            return Disposables.create()
        }
        observable.bind(to: observer01).disposed(by: disposeBag)
```
有许多 UI 控件都存在这种特性，例如：switch的开关状态，segmentedControl的选中索引号，datePicker的选中日期等等。
#### AsyncSubject
AsyncSubject 将在源 Observable 产生完成事件后，发出最后一个元素（仅仅只有最后一个元素），如果源 Observable 没有发出任何元素，只有一个完成事件。那 AsyncSubject 也只有一个完成事件。
它会对随后的观察者发出最终元素。如果源 Observable 因为产生了一个 error 事件而中止， AsyncSubject 就不会发出任何元素，而是将这个 error 事件发送出来。

```
 //AsyncSubject
        let asyncSubject = AsyncSubject<String>()
        asyncSubject.subscribe(onNext: {
           print("event :",$0)
        }, onError: {
            error in
            print(error)
        }, onCompleted: {
            print("finish")
        })
        .disposed(by: disposeBag)
        
        asyncSubject.onNext("1")
        asyncSubject.onNext("2")
        asyncSubject.onNext("3")
        asyncSubject.onCompleted()
```
输出结果

```
event : 3
finish
```

#### PublishSubject
PublishSubject 将对观察者发送订阅后产生的元素，而在订阅前发出的元素将不会发送给观察者。如果你希望观察者接收到所有的元素，你可以通过使用 Observable 的 create 方法来创建 Observable，或者使用 ReplaySubject。
如果源 Observable 因为产生了一个 error 事件而中止， PublishSubject 就不会发出任何元素，而是将这个 error 事件发送出来。

```
//PublishSubject
        let publishSubject = PublishSubject<String>()
        publishSubject.subscribe(onNext: {
            print("event:",$0)
        })
        .disposed(by: disposeBag)
        publishSubject.onNext("ddd")
        publishSubject.onNext("fff")
        publishSubject.subscribe(onNext: {
            print("event",$0)
        })
        .disposed(by: disposeBag)
        publishSubject.onNext("aaa")
        publishSubject.onNext("bbb")
```
输出结果

```
event: ddd
event: fff
event: aaa
event aaa
event: bbb
event bbb
```

#### ReplaySubject
ReplaySubject 将对观察者发送全部的元素，无论观察者是何时进行订阅的。

这里存在多个版本的 ReplaySubject，有的只会将最新的 n 个元素发送给观察者，有的只会将限制时间段内最新的元素发送给观察者。

如果把 ReplaySubject 当作观察者来使用，注意不要在多个线程调用 onNext, onError 或 onCompleted。这样会导致无序调用，将造成意想不到的结果。

```
//ReplaySubject
        let replaySubject = ReplaySubject<String>.create(bufferSize: 1)
        replaySubject.subscribe(onNext: {
            print("replay:",$0)
        }).disposed(by: disposeBag)
        
        replaySubject.onNext("11")
        replaySubject.onNext("22")
        
        replaySubject.subscribe(onNext: {
            print("repaly:",$0)
        }).disposed(by: disposeBag)
        
        replaySubject.onNext("33")
        replaySubject.onNext("44")
```
输出结果‘

```
replay: 11
replay: 22
repaly: 22
replay: 33
repaly: 33
replay: 44
repaly: 44
```

#### BehaviorSubject
当观察者对 BehaviorSubject 进行订阅时，它会将源 Observable 中最新的元素发送出来（如果不存在最新的元素，就发出默认元素）。然后将随后产生的元素发送出来。
如果源 Observable 因为产生了一个 error 事件而中止， BehaviorSubject 就不会发出任何元素，而是将这个 error 事件发送出来。

```
  // BehaviSubject
        let behavSubject = BehaviorSubject(value: "😀")
        behavSubject.subscribe(onNext: {
            print("behavi:",$0)
        }).disposed(by: disposeBag)
        behavSubject.onNext("😇")
        behavSubject.onNext("😎")
        behavSubject.subscribe(onNext: {
            print("behavi:",$0)
        }).disposed(by: disposeBag)
        behavSubject.onNext("🤓")
        behavSubject.onNext("😶‍🌫️")
        behavSubject.subscribe(onNext: {
            print("behavi:",$0)
        }).disposed(by: disposeBag)
        behavSubject.onNext("11")
        behavSubject.onNext("22")
```
输出结果

```
behavi: 😀
behavi: 😇
behavi: 😎
behavi: 😎
behavi: 🤓
behavi: 🤓
behavi: 😶‍🌫️
behavi: 😶‍🌫️
behavi: 😶‍🌫️
behavi: 11
behavi: 11
behavi: 11
behavi: 22
behavi: 22
behavi: 22
```
#### ControlProperty

- ControlProperty 专门用于描述 UI 控件属性的，它具有以下特征：
- 
- 不会产生 error 事件
- 一定在 MainScheduler 订阅（主线程订阅）
- 一定在 MainScheduler 监听（主线程监听）
- 共享附加作用

### 4. 操作符
 **操作符可以帮助大家创建新的序列，或者变化组合原有的序列，从而生成一个新的序列。
** 
我们之前在输入验证例子中就多次运用到操作符。例如，通过 map 方法将输入的用户名，转换为用户名是否有效。然后用这个转化后来的序列来控制红色提示语是否隐藏。我们还通过 combineLatest 方法，将用户名是否有效和密码是否有效合并成两者是否同时有效。然后用这个合成后来的序列来控制按钮是否可点击。
#### filter - 过滤
你可以用 filter 创建一个新的序列。这个序列只发出温度大于 33 度的元素。

```
let operatures:Observable<Double> = Observable.create { observe -> Disposable in
            observe.onNext(28.55)
            observe.onNext(26.66)
            observe.onNext(30.55)
            observe.onNext(33.01)
            observe.onNext(35.66)
            observe.onCompleted()
            return Disposables.create()
        }
        
        operatures.filter{ tempture in tempture >= 30.00 }
            .subscribe(onNext: {
                tempture in
                print(tempture)
            })
            .disposed(by: disposeBag)
```
输出结果

```
30.55
33.01
35.66
```

#### map - 转换
你可以用 map 创建一个新的序列。这个序列将原有的 JSON 转换成 Model 。这种转换实际上就是解析 JSON 。

```
     let json:Observable<JSON> = Observable.create { (observer) -> Disposable in
            let url = URL(string: "https://api.github.com/repos/XYGDeveloper/RemoteImageView_swiftSPM")!
                let task = URLSession.shared.dataTask(with:url) { data, reponse, error in
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
        }
        
        json.map(GithubModel.init)
            .subscribe(onNext: {
                model in
                print(model)
            })
            .disposed(by: disposeBag)
```
GithubModel:

```
import UIKit

struct GithubModel {
    var id = 0
    var node_id = ""
    var name = ""
    var full_name = ""
    var html_url = ""
    var fork = true
    var url = ""
    var forks_url = ""
    var keys_url = ""
    var collaborators_url = ""
    var teams_url = ""
    var hooks_url = ""
    var issue_events_url = ""
    var events_url = ""
    var assignees_url = ""
    var branches_url = ""
    var tags_url = ""
    var blobs_url = ""
    var git_tags_url = ""
    var git_refs_url = ""
    var trees_url = ""
    var statuses_url = ""
    var languages_url = ""
    var stargazers_url = ""
    var contributors_url = ""
    var subscribers_url = ""
    var commits_url = ""
    var compare_url = ""
    var merges_url = ""
    var clone_url = ""
    var svn_url = ""
     
}

```

#### zip - 配对
案例1：

```
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
案例2：

```
 let rxHamburgs:Observable<Teacher> = Observable.create { ob -> Disposable in
            var teach1 = Teacher()
            teach1.teacherId = "1"
            teach1.teacherName = "tanme1"
            var t2 = Teacher()
            t2.teacherId = "2"
            t2.teacherName = "tanme2"
            var t3 = Teacher()
            t3.teacherId = "3"
            t3.teacherName = "tanme3"
            var t4 = Teacher()
            t4.teacherId = "4"
            t4.teacherName = "tanme4"
            ob.onNext(teach1)
            ob.onNext(t2)
            ob.onNext(t3)
            ob.onNext(t4)
            ob.onCompleted()
            return Disposables.create()
        }
        
        let rxFrenchFries:Observable<Comment> = Observable.create{
            ob1 -> Disposable in
            var comm1 = Comment()
            comm1.commentId  = "1"
            comm1.content  = "c1"
            
            var comm2 = Comment()
            comm2.commentId  = "2"
            comm2.content  = "c2"
            
            var comm3 = Comment()
            comm3.commentId  = "3"
            comm3.content  = "c3"
            ob1.onNext(comm1)
            ob1.onNext(comm2)
            ob1.onNext(comm3)
            ob1.onCompleted()
            return Disposables.create()
        }
        
        Observable.zip(rxHamburgs,rxFrenchFries)
            .subscribe(onNext: {
                (teacher,comment) in
                print(teacher)
                print(comment)
            }, onError: {
                error in
                print(error)
            }, onCompleted: {
                
            })
            .disposed(by: disposeBag)
```
输出结果：

```
Teacher(teacherId: "1", teacherName: "tanme1")
Comment(commentId: "1", content: "c1")
Teacher(teacherId: "2", teacherName: "tanme2")
Comment(commentId: "2", content: "c2")
Teacher(teacherId: "3", teacherName: "tanme3")
Comment(commentId: "3", content: "c3")
```
#### [更多操作符](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/rxswift_core/operator.html)
### 5. Disposable - 可被清除的资源
![输入图片说明](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/assets/Disposable/Disposable.png)
通常来说，一个序列如果发出了 error 或者 completed 事件，那么所有内部资源都会被释放。如果你需要提前释放这些资源或取消订阅的话，那么你可以对返回的 可被清除的资源（Disposable） 调用 dispose 方法：

```
import UIKit
import RxSwift

class ThirdViewController: UIViewController {
    @IBOutlet weak var textfield: UITextField!
    
    var disposable:Disposable?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposable = textfield.rx.text.orEmpty
            .subscribe(onNext: {
                text in
                print(text)
            })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposable?.dispose()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  

}
```
调用 dispose 方法后，订阅将被取消，并且内部资源都会被释放。通常情况下，你是不需要手动调用 dispose 方法的，这里只是做个演示而已。我们推荐使用 清除包（DisposeBag） 或者 takeUntil 操作符 来管理订阅的生命周期。
![输入图片说明](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/assets/Disposable/DisposeBag.png)
因为我们用的是 Swift ，所以我们更习惯于使用 ARC 来管理内存。那么我们能不能用 ARC 来管理订阅的生命周期了。答案是肯定了，你可以用 清除包（DisposeBag） 来实现这种订阅管理机制：

```
import UIKit
import RxSwift

class ThirdViewController: UIViewController {
    @IBOutlet weak var textfield: UITextField!
    
//    var disposable:Disposable?
    
    //arc
    var disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        disposable = textfield.rx.text.orEmpty
//            .subscribe(onNext: {
//                text in
//                print(text)
//            })
        textfield.rx.text.orEmpty.subscribe(onNext: {
            field in
            print(field)
        }).disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        disposable?.dispose()
        self.disposeBag = DisposeBag()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
```
当 清除包 被释放的时候，清除包 内部所有 可被清除的资源（Disposable） 都将被清除。在输入验证中我们也多次看到 清除包 的身影：

```
var disposeBag = DisposeBag() // 来自父类 ViewController

override func viewDidLoad() {
    super.viewDidLoad()

    ...

    usernameValid
        .bind(to: passwordOutlet.rx.isEnabled)
        .disposed(by: disposeBag)

    usernameValid
        .bind(to: usernameValidOutlet.rx.isHidden)
        .disposed(by: disposeBag)

    passwordValid
        .bind(to: passwordValidOutlet.rx.isHidden)
        .disposed(by: disposeBag)

    everythingValid
        .bind(to: doSomethingOutlet.rx.isEnabled)
        .disposed(by: disposeBag)

    doSomethingOutlet.rx.tap
        .subscribe(onNext: { [weak self] in self?.showAlert() })
        .disposed(by: disposeBag)
}
```
这个例子中 disposeBag 和 ViewController 具有相同的生命周期。当退出页面时， ViewController 就被释放，disposeBag 也跟着被释放了，那么这里的 5 次绑定（订阅）也就被取消了。这正是我们所需要的
![输入图片说明](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/assets/Disposable/TakeUntil.png)
#### takeUntil

### 4. 调度器
### 4. 错误处理


