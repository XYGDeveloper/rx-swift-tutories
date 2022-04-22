//
//  SecodViewController.swift
//  RxSwiftDemo
//
//  Created by xwtech on 2022/4/20.
//

import UIKit
import RxSwift
import RxCocoa
typealias JSON = Any
class SecodViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var sizeNameLabel: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
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
    
//    let json:Observable<JSON> = Observable.create { (observer) -> Disposable in
//        let task = URLSession.shared.dataTask(with: URL(string: "")!) { data, reponse, error in
//            guard error == nil else{
//                observer.onError(error!)
//                return
//            }
//            guard let data = data,let jsonObject = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed) else {
//                observer.onError(error!)
//                return
//            }
//            observer.onNext(jsonObject)
//            observer.onCompleted()
//        }
//        task.resume()
//
//        return Disposables.create {
//            task.cancel()
//        }
//    }
    
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
    
//    func cacheLocal() -> Completable {
//        return Completable.create { complete in
//            /* 进行缓存操作
//                ....
//                ....
//            */
//            guard let success else{
//                completable(.error(CacheError.failedCaching))
//                return Disposables.create {}
//            }
//            complete(.completed)
//            return Disposables.create{}
//        }
//    }
    
    func generalString() -> Maybe<String> {
        return Maybe<String>.create { maybe in
            maybe(.success("RXSWIFT"))
            maybe(.completed)
            let error = NSError()
            maybe(.error(error))
            return Disposables.create {}
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
//        json.subscribe(onNext: {
//            jsonObject in
//            print(jsonObject)
//        }, onError: {
//            error in
//            print(error)
//        }, onCompleted: {
//            print("finish")
//        })
//        .disposed(by: disposeBag)
        
        
        getRepo("XYGDeveloper/RemoteImageView_swiftSPM")
            .subscribe(onSuccess: {
                result in
                print(result)
            }, onError: {
                error in
                print(error)
            })
            .disposed(by: disposeBag)
        
        
        
        
//        cacheLocal().subscribe(onCompleted: {
//
//        }, onError: {
//            error in
//            print(error)
//        })
//        .disposed(by: disposeBag)
        
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
        
        //
        textField.text  = "driver"
        let status:Driver<String?> = textField.rx.text.asDriver()
        let observer = nameLabel.rx.text
        status.drive(observer)
        let newObsever = sizeNameLabel.rx.text.asObserver()
        status.map{$0?.count.description}.drive(newObsever)
        
        //
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
        
        //
        let usernameValid = textField.rx.text.orEmpty
            .map{
                $0.count >= 6
            }
            .share(replay: 1)
        
        usernameValid.bind(to: nameLabel.rx.isHidden)
        
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
        
        //
        
        let obsser:Binder<Bool> = Binder(nameLabel){
            (view,ishidden) in
            view.isHidden = ishidden
        }
        
        usernameValid.bind(to: obsser).disposed(by: disposeBag)
        
        
//        nameLabel.rx.isHidde
//        usernameValid.bind(to: nameLabel.rx.isHidde).disposed(by: disposeBag)
//        button.rx.isEnabled
//        nameLabel.rx.text
        
//        let json:Observable<JSON> = Observable.create { (observer) -> Disposable in
//            let url = URL(string: "https://api.github.com/repos/XYGDeveloper/RemoteImageView_swiftSPM")!
//                let task = URLSession.shared.dataTask(with:url) { data, reponse, error in
//                    guard error == nil else{
//                        observer.onError(error!)
//                        return
//                    }
//                    guard let data = data,let jsonObject = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed) else {
//                        observer.onError(error!)
//                        return
//                    }
//                    observer.onNext(jsonObject)
//                    observer.onCompleted()
//                }
//                task.resume()
//
//                return Disposables.create {
//                    task.cancel()
//                }
//        }
//
//        json.map(GithubModel.init)
//            .subscribe(onNext: {
//                model in
//                print(model)
//            })
//            .disposed(by: disposeBag)
        
        
        
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


