# RxSwift_turtus

#### 介绍
[RxSwift中文文档](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/first_app.html)

#### 安装教程
1. button点击事件
- `button.rx.tap.subscribe(onNext: {
            print("button tap")
        })
        .disposed(by: disposeBag)`

2. 代理
- ` scrollview.rx.contentOffset.subscribe(onNext:{ offset in
            print(offset)
        })
        .disposed(by: disposeBag)`
3. 闭包回调
- `URLSession.shared.dataTask(with: URL(string: "http://www.baidu.com")!) { data, response, error in
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

        }.resume()`
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
4. 通知
- ` NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .subscribe(onNext: {
                notofication in
                print(notofication)
            })
            .disposed(by: disposeBag)`
