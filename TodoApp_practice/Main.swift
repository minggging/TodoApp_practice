//
//  ViewController.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/26.
//

import UIKit
import Alamofire
import Combine

class Main: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var todoTableView: UITableView!
    
    var subscriptions = Set<AnyCancellable>()
    var viewModel : TodosVM = TodosVM()
    
    var todoList : [Todo] = []

    /// 테이블뷰 하단 로딩 인디케이터
    lazy var bottomIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0, y: 0,
                                 width: todoTableView.bounds.width,
                                 height: 44)
        
        return indicator
    }()
    
    /// 테이블뷰 상단 리프레시 컨트롤
    lazy var refreshControl : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged) // 액션 연결
        
        return refreshControl
    }()

    /// 서치바 관련 DispatchWorkItem
    var searchTermInputWorkItem : DispatchWorkItem? = nil
    
    /// 검색결과를 찾지 못했다 뷰
    lazy var searchDataNotFoundView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0,
                                        width: todoTableView.bounds.width,
                                        height: 300))
        let label = UILabel()
        label.text = "검색결과를 찾을 수 없습니다 🗑️"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    /// 불러올 결과가 없다 뷰
    lazy var ButtomNoMoreDataView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0,
                                        width: todoTableView.bounds.width,
                                        height: 44))
        let label = UILabel()
        label.text = "더 이상 가져올 데이터가 없습니다 ❌"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        print(" -", #fileID, #function, #line)
        
        // ===== 테이블뷰 관련 =====
        todoTableView.dataSource = self
        todoTableView.delegate = self
        todoTableView.tableFooterView = bottomIndicator
        todoTableView.refreshControl = refreshControl
        
        //cell Nib 등록
        let todoCellNib = UINib(nibName: "TodoCell", bundle: .main)
        self.todoTableView.register(todoCellNib, forCellReuseIdentifier: "TodoCell")
        // ====  ====
        
        // ==== 서치바 설정 ====
        self.searchBar.searchTextField.addTarget(self, action: #selector(searchTermChanged(_:)), for: .editingChanged)
        
        // 검색결과 없음 여부
        self.viewModel.notifySearchDataNotFound = { [weak self] notFound in
            guard let self = self else { return }
            print(#fileID, #function, #line, "- notFound: \(notFound)")
            DispatchQueue.main.async {
                self.todoTableView.backgroundView = notFound ? self.searchDataNotFoundView : nil
            }
        }

        self.viewModel.notifyHasNextPage = { [weak self] hasNext in
            guard let self = self else { return }
            print("hasNext \(hasNext) -", #fileID, #function, #line)
            DispatchQueue.main.async {
                self.todoTableView.tableFooterView = !hasNext ? self.ButtomNoMoreDataView : nil
            }
            
        }

        // 뷰모델 바인딩
        bindViewModel()
        
    } //viewDidLoad.
    
    /// 추가 바버튼 - 얼럿 띄우기 + 추가 api 호출
    @IBAction func addTodoBarBtn(_ sender: UIBarButtonItem) {
        
        /// 할 일 추가 얼럿
        let alertController = UIAlertController(title: "할 일 추가하기", message: "", preferredStyle: .alert)
        
        /// 할 일 추가 얼럿 - 추가 버튼
        let addAction = UIAlertAction(title: "추가", style: UIAlertAction.Style.default, handler: { (action : UIAlertAction!) -> Void in
            
            /// 얼럿창 텍스트필드
            let addTextField = alertController.textFields?.first
            
            /// 얼럿 입력값
            guard let addedTodos = addTextField?.text else { return }
            
            self.viewModel.addATodoWithCombine(todoInput: addedTodos)

            
        })
        /// 할 일 추가 얼럿 - 취소 버튼
        let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: {
            (action : UIAlertAction!) -> Void in })
        
        // 텍스트 필드 추가
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "추가할 할 일을 입력해주세요."
        }

        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
} // class.

//MARK: - UITableViewDataSource
extension Main : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(" -", #fileID, #function, #line)
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print(" -", #fileID, #function, #line)
        let cellData = todoList[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? TodoCell else { return UITableViewCell() }
        
        cell.todos.text = cellData.title
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension Main : UITableViewDelegate {
    
    //MARK: - 쎌 스와이프 버튼
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        /// 스와이프 수정 버튼
        let edit = UIContextualAction(style: .normal, title: "수정") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print("수정버튼 클릭됨 -", #fileID, #function, #line)
            success(true)
        }
        
        /// 스와이프 삭제 버튼
        let delete = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print("삭제버튼 클릭됨 -", #fileID, #function, #line)
            success(true)
        }
        
        edit.backgroundColor = .systemBlue
        delete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions:[delete,edit])
    }
    
    //MARK: - 페이지 스크롤 관련
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset
        
        if distanceFromBottom - 200 < height {
            viewModel.fetchMoreWithCombine()
            print("리스트 하단 추가하기")

        }
    }
    

}

//MARK: - 뷰모델 관련
extension Main {
    
    /// 뷰컨 - 뷰모델 바인드
    fileprivate func bindViewModel(){
        
        // todoList 처리
        viewModel.$todoList
            .receive(on: DispatchQueue.main) // 메인쓰레드에서 처리
            .sink(receiveValue: { (updateTodoList : [Todo]) in
                self.todoList = updateTodoList
                self.todoTableView.reloadData()
            }).store(in: &subscriptions)

         //로딩 여부
        viewModel.$isLoading
            .map{ $0 == true ? self.bottomIndicator : nil }
            .receive(on: DispatchQueue.main)
            .assign(to: \.tableFooterView, on: self.todoTableView)
            .store(in: &subscriptions)
        
    }// bindViewModel.
    
}

//MARK: - 액션 관련
extension Main {
    
    /// handleRefresh - 새로고침 액션
    @objc fileprivate func handleRefresh(_ sender: UIRefreshControl) {
        print(" -", #fileID, #function, #line)
        
        self.viewModel.fetchRefreshWithCombine()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            sender.endRefreshing()
        })
    }
    
    
    /// 검색 관련 액션
    /// - Parameter sender:
    @objc fileprivate func searchTermChanged(_ sender: UITextField){
        print(#fileID, #function, #line, "- sender: \(String(describing: sender.text))")
        
        // 검색어가 입력되면 기존 작업 취소
        searchTermInputWorkItem?.cancel()
        
        let dispatchWorkItem = DispatchWorkItem(block: {
            // 백그라운드 - 사용자 입력 userInteractive
            DispatchQueue.global(qos: .userInteractive).async {
                DispatchQueue.main.async { [weak self] in
                    guard let userInput = sender.text,
                          let self = self else { return }
                    
                    print(#fileID, #function, #line, "- 검색 API 호출하기 userInput: \(userInput)")
                    self.viewModel.todoList = []
                    // 뷰모델 검색어 갱신
                    self.viewModel.searchTerm = userInput
                }
            }
        })
        
        // 기존작업을 나중에 취소하기 위해 메모리 주소 일치 시켜줌
        self.searchTermInputWorkItem = dispatchWorkItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: dispatchWorkItem)
    }
}
