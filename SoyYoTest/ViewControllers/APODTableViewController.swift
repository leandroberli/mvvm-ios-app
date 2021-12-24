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
    let service = NasaHTTPClient.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        self.navigationItem.rightBarButtonItem = viewModel?.getFilterNavItem
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = viewModel?.getHeaderView
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.register(UINib(nibName: "APODTableViewCell", bundle: nil), forCellReuseIdentifier: "APODTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        tableView.tableHeaderView?.layoutSubviews()
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
        guard let model = viewModel?.APODModels[indexPath.row] else { return }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "APODDetailViewController") as! APODDetailViewController
        vc.apod = model
        navigationController?.pushViewController(vc, animated: true)
    }
}

