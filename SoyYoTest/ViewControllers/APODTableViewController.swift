//
//  ViewController.swift
//  SoyYoTest
//
//  Created by Leandro Berli on 22/12/2021.
//

import UIKit

class APODTableViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: APODTableViewModel?
    var filterView: UIView?
    let service = NasaHTTPClient.shared
    var lastContetOffset: CGPoint = CGPoint(x: 0, y: 60)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Soy yo test"
        initViewModel()
        setFilterView()
        setupTable()
    }
    
    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 10, right: 0)
        tableView.register(viewModel?.cellNib, forCellReuseIdentifier: viewModel?.cellReuseId ?? "" )
        tableView.bounces = false
    }
    
    
    func setFilterView() {
        filterView = viewModel?.headerView
        self.view.addSubview(filterView!)
        filterView?.pin(.leading, .trailing, to: self.view)
        filterView?.pin(.topMargin, to: tableView)
        filterView?.pin(.height, constant: 50)
        self.view.bringSubviewToFront(filterView!)
    }
    
    func initViewModel() {
        viewModel = APODTableViewModel()
        viewModel?.touchFilterAction = {
            self.filterAction()
        }
        
        getAPODs { apods in
            self.viewModel?.APODModels = apods
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
    
    private func getAPODs(completion: @escaping (([APOD]) -> Void)) {
        //TODO: Dynamic dates
        var params = [String: String]()
        params["start_date"] = "2021-12-15"
        params["end_date"] = "2021-12-23"
        service.getAPOD(queryParams: params) { apods, error in
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
            }
            if let _ = error {
                completion([])
                return
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            completion(apods ?? [])
        }
    }
    
    func filterAction() {
        let vc = UIViewController()
        present(vc, animated: true, completion: nil)
    }
    
    private func hideHeaderView() {
        UIView.animate(withDuration: 0.2) {
            self.filterView?.alpha = 0
            self.tableView.contentInset.top = 10
        }
    }
    
    private func showHeaderView() {
        UIView.animate(withDuration: 0.2) {
            self.filterView?.alpha = 1
            self.tableView.contentInset.top = 60
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension APODTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.APODModels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "APODTableViewCell", for: indexPath) as! APODTableViewCell
        let model = viewModel?.APODModels[indexPath.row]
        cell.setupModel(model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: Coordinator pattern
        guard let model = viewModel?.APODModels[indexPath.row] else { return }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "APODDetailViewController") as! APODDetailViewController
        vc.apod = model
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > lastContetOffset.y {
            hideHeaderView()
        } else {
            showHeaderView()
        }
        lastContetOffset = scrollView.contentOffset
    }
}

