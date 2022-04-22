//
//  SimpleVallibViewController.swift
//  RxSwiftDemo
//
//  Created by xwtech on 2022/4/20.
//

import UIKit
import RxSwift
import RxCocoa
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
        
        /**
         
         */
        // Observable<String>
        let text = usernameOutlet.rx.text.orEmpty.asObservable()
        // Observable<Bool>
        let passwordVali = text
        // Operator
            .map{$0.count >= minmalUserLength}
        // Observer<Bool>
        let observer =  usernameValidOutlet.rx.isHidden
        // Disposable
        let dispose = passwordVali
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .bind(to: observer)
        dispose.dispose()
        
//        在我们所遇到的事物中，有一部分非常特别。它们既是可监听序列也是观察者。
//
//        例如：textField的当前文本。它可以看成是由用户输入，而产生的一个文本序列。也可以是由外部文本序列，来控制当前显示内容的观察者：
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
        
        // ControlProperty
        //操作符
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
        //map 转换
        
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
