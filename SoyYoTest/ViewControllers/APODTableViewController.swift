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
    
    var datePicker: UIDatePicker?
    var helperTextfield = UITextField()
    var selectedDate: Date?
    
    var filterView: UIView?
    
    var viewModel: APODTableViewModel?
    let service = NasaHTTPClient.shared
    var lastContetOffset: CGPoint = CGPoint(x: 0, y: 60)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Soy yo test"
        initViewModel()
        setFilterView()
        setupTable()
        setHelperTextfield()
    }
    
    //For Show date picker
    private func setHelperTextfield() {
        self.datePicker = viewModel?.datePicker
        //self.datePicker.delegate = self
        self.datePicker?.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        helperTextfield.inputView = self.datePicker
        helperTextfield.inputAccessoryView = viewModel?.dateToolbar
        self.view.addSubview(helperTextfield)
    }
    
    @objc func datePickerValueChanged(_ datePicker: UIDatePicker) {
        selectedDate = datePicker.date
    }
    
    private func changeHeaderTitle(_ title: String) {
        filterView?.subviews.forEach( { view in
            if let button = view as? UIButton {
                button.setTitle(title, for: .normal)
            }
        })
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
        
        viewModel?.touchSevenDaysFilterAction = {
            self.handle7DaysToolbar()
        }
        
        viewModel?.touchDoneFilterAction = {
            self.handleDoneToolbar()
        }
        
        getAPODs { apods in
            self.viewModel?.APODModels = apods
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
    
    private func handle7DaysToolbar() {
        helperTextfield.resignFirstResponder()
        selectedDate = nil
        changeHeaderTitle("Last 7 days")
        
        activityIndicator.isHidden = false
        getAPODs { apods in
            self.viewModel?.APODModels = apods
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
    
    private func handleDoneToolbar() {
        guard let date = self.selectedDate else {
            return
        }
        helperTextfield.resignFirstResponder()
        changeHeaderTitle(date.getFilterDateString())
        
        activityIndicator.isHidden = false
        getSingleAPOD { apods in
            self.viewModel?.APODModels = apods
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
    
    private func getAPODs(completion: @escaping (([APOD]) -> Void)) {
        let params = getRequestParams()
        
        service.getAPODs(queryParams: params) { apods, error in
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
            }
            if let _ = error {
                completion([])
                return
            }
            completion(apods ?? [])
        }
    }
    
    private func getSingleAPOD(completion: @escaping (([APOD]) -> Void)) {
        let params = getRequestParams()
        service.getSingleAPOD(queryParams: params) { apod, error in
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
            }
            if let _ = error {
                completion([])
                return
            }
            if let apod = apod {
                completion([apod])
            } else {
                completion([])
            }
        }
    }
    
    func getRequestParams() -> [String: String] {
        var params = [String: String]()
        //specific date
        if let currentSelectedDate = self.selectedDate {
            params["date"] = currentSelectedDate.getQueryParamDateString()
        } else {
            //Default - Last 7 days pictures
            let lastDays = last7Days()
            params["start_date"] = lastDays.last?.getQueryParamDateString()
            params["end_date"] = lastDays.first?.getQueryParamDateString()
        }
        
        return params
    }
    
    private func last7Days() -> [Date] {
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var days = [Date]()
        for _ in 1 ... 7 {
            days.append(date)
            date = cal.date(byAdding: .day, value: -1, to: date)!
        }
        return days
    }
    
    func filterAction() {
        if helperTextfield.isFirstResponder {
            helperTextfield.resignFirstResponder()
        } else {
            helperTextfield.becomeFirstResponder()
        }
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

