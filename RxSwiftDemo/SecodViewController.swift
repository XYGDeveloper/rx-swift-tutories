//
//  SecodViewController.swift
//  RxSwiftDemo
//
//  Created by xwtech on 2022/4/20.
//

import UIKit
import RxSwift
typealias JSON = Any
class SecodViewController: UIViewController {
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
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numbers.subscribe(onNext: {
            number in
            print(number)
        })
        .disposed(by: disposeBag)
        //
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
        // Do any additional setup after loading the view.
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
