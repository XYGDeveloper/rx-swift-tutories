//
//  ThirdViewController.swift
//  RxSwiftDemo
//
//  Created by xwtech on 2022/4/20.
//

import UIKit
import RxSwift

class ThirdViewController: UIViewController {
    var disposeBag = DisposeBag()

    var data:Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .userInitiated).async {
            // 解析数据
            let data = try? Data(contentsOf: URL(string: "https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/rxswift_core/schedulers.html")!)
            DispatchQueue.main.async {
                // 赋值刷新
                self.data  = data
            }
        }
        //Schedulers 是 Rx 实现多线程的核心模块，它主要用于控制任务在哪个线程或队列运行。
        // 用rxswift实现
        let rxData:Observable<Data> = Observable.create{
            observble -> Disposable in
            let data = try? Data(contentsOf: URL(string: "https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/rxswift_core/schedulers.html")!)
            if let data = data{
                observble.onNext(data)
            }
            observble.onCompleted()
            return Disposables.create()
        }
        
        rxData.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
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
        
                let rxjson:Observable<JSON> = Observable.create { (observer) -> Disposable in
                    let url = URL(string: "https://api.github.com/repos/XYGDeveloper/RemoteImageView_swiftSPM")!
                        let task = URLSession.shared.dataTask(with:url) { data, reponse, error in
                            guard error == nil else{
                                observer.onError(error!)
                                return
                            }
                            guard let data = data,let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {
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
        
        // 请求 JSON 失败时，立即重试，
        // 重试 3 次后仍然失败，就将错误抛出
        rxjson
            .retry(3)
            .subscribe(onNext: {
                jsonObject in
                print(jsonObject)
            }, onError: {
                error in
                print(error)
            }, onCompleted: {
                
            })
            .disposed(by: disposeBag)
        
        //延时5s重试
        let retryDelay:Double = 5
        rxjson
            .retryWhen { (observerbleError:Observable<Error>) -> Observable<Int> in
            return Observable.timer(retryDelay, scheduler: MainScheduler.instance)
            }
            .subscribe(onNext: {
                jsonobject in
                print(jsonobject)
            }, onError: {
                error in
                print(error)
            })
            .disposed(by: disposeBag)
        // 请求 JSON 失败时，等待 5 秒后重试，
        // 重试 4 次后仍然失败，就将错误抛出
        let maxRetryCount = 4       // 最多重试 4 次
        let retryDelay1: Double = 5  // 重试延时 5 秒
        rxjson
            .retryWhen{
            (rxerror:Observable<Error>) -> Observable<Int> in
            return rxerror.flatMapWithIndex { (error, index) -> Observable<Int> in
                       guard index < maxRetryCount else {
                           return Observable.error(error)
                       }
                       return Observable<Int>.timer(retryDelay, scheduler: MainScheduler.instance)
                   }
             }
            .subscribe(onNext: {
                jsonObject in
                print(jsonObject)
            }, onError: {
                error in
                print(error)
            })
            .disposed(by: disposeBag)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
