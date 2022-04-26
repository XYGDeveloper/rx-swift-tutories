//
//  ViewController.swift
//  SimpleTableSection
//
//  Created by xwtech on 2022/4/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
class ViewController: UIViewController,UITableViewDelegate{

    @IBOutlet weak var tableview: UITableView!
    
    var dispose = DisposeBag()
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,Double>>(
        configureCell:  { _, tableview, indexpath, item in
            let cell = tableview.dequeueReusableCell(withIdentifier: "cell")
            cell?.textLabel?.text = "\(item) @ \(indexpath.row)"
            return cell!
        },
        titleForHeaderInSection: { datasource, sectionIndex in
            // title of header
            return datasource[sectionIndex].model
        }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataSource = dataSource
        let items = Observable.just([
            SectionModel(model: "First Section", items: [1.0,2.0,3.0]),
           SectionModel(model: "Second Section", items:  [1.0,2.0,3.0]),
           SectionModel(model: "Third Section", items:  [1.0,2.0,3.0])
        ])
        
        items.bind(to: tableview.rx.items(dataSource: dataSource))
            .disposed(by: dispose)
        
        //点击事件
        tableview.rx.itemSelected
            .map{ indexPath in return (indexPath,dataSource[indexPath])}
            .subscribe(onNext: {
                pair in
                print("\(pair.0)--\(pair.1)")
            }, onError: {
                error in
                print(error)
            })
            .disposed(by: dispose)
        
        tableview.rx.setDelegate(self).disposed(by: dispose)
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
}



extension UITableView{
    func hiddenEmptyCell(){
        self.tableFooterView = UIView(frame: .zero)
    }
}



// 简单的tableview列表展示
//-----------------------------------------------
/*
let items = Observable.just(
    (0..<20).map { "\($0)" }
)

items
    .bind(to: tableview.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { (row, element, cell) in
        cell.textLabel?.text = "\(element) @ row \(row)"
    }
    .disposed(by: dispose)


tableview.rx
    .modelSelected(String.self)
    .subscribe(onNext:  { value in
        print(value)
//                DefaultWireframe.presentAlert("Tapped `\(value)`")
    })
    .disposed(by:dispose)

tableview.rx
    .itemAccessoryButtonTapped
    .subscribe(onNext: { indexPath in
//                DefaultWireframe.presentAlert("Tapped Detail @ \(indexPath.section),\(indexPath.row)")
        print(indexPath.section)
        print(indexPath.row)
    })
    .disposed(by: dispose)
 */
//-----------------------------------------------


