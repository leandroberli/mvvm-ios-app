//
//  ViewController.swift
//  SoyYoTest
//
//  Created by Leandro Berli on 22/12/2021.
//

import UIKit

class APODTableViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var didTapAPODItem: ((APOD) -> Void)?

    var datePicker: UIDatePicker?
    var helperTextfield = UITextField()
    var selectedDate: Date?
    var headerView: UIView?
    var viewModel: APODTableViewModel?
    let service = NasaHTTPClient.shared
    var lastContetOffset: CGPoint = CGPoint(x: 0, y: 60)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "NASA API"
        initViewModel()
        setHeaderView()
        setupTable()
        setHelperTextfield()
    }
    
    func initViewModel() {
        viewModel = APODTableViewModel()
        
        viewModel?.touchFilterAction = {
            self.handleOpenDatepicker()
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
    
    func setHeaderView() {
        headerView = viewModel?.headerView
        self.view.addSubview(headerView!)
        headerView?.pin(.leading, .trailing, to: self.view)
        headerView?.pin(.topMargin, to: tableView)
        headerView?.pin(.height, constant: 50)
        self.view.bringSubviewToFront(headerView!)
    }
    
    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 10, right: 0)
        tableView.register(viewModel?.cellNib, forCellReuseIdentifier: viewModel?.cellReuseId ?? "" )
        tableView.bounces = false
    }
    
    //For Show date picker
    private func setHelperTextfield() {
        datePicker = viewModel?.datePicker
        datePicker?.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        helperTextfield.inputView = self.datePicker
        helperTextfield.inputAccessoryView = viewModel?.dateToolbar
        self.view.addSubview(helperTextfield)
    }
    
    @objc func datePickerValueChanged(_ datePicker: UIDatePicker) {
        selectedDate = datePicker.date
    }
    
    private func changeHeaderTitle(_ title: String) {
        headerView?.subviews.forEach( { view in
            if let button = view as? UIButton {
                button.setTitle(title, for: .normal)
            }
        })
    }
    
    //MARK: Toolbar actions
    private func handle7DaysToolbar() {
        helperTextfield.resignFirstResponder()
        selectedDate = nil
        changeHeaderTitle("Last 7 days")
        
        removeDataSourceAndReaload()
        
        activityIndicator.isHidden = false
        getAPODs { apods in
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.setDataSourceAndReaload(apods: apods)
            }
        }
    }
    
    private func removeDataSourceAndReaload() {
        self.viewModel?.APODModels.removeAll()
        self.tableView.reloadSections([0], with: .automatic)
        
    }
    
    private func setDataSourceAndReaload(apods: [APOD]?) {
        self.viewModel?.APODModels = apods ?? []
        self.tableView.reloadSections([0], with: .automatic)
    }
    
    private func handleDoneToolbar() {
        guard let date = self.selectedDate else {
            return
        }
        helperTextfield.resignFirstResponder()
        changeHeaderTitle(date.getFilterDateString())
        
        removeDataSourceAndReaload()
        
        activityIndicator.isHidden = false
        getSingleAPOD { apods in
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.setDataSourceAndReaload(apods: apods)
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
            let lastDays = get7IntervalDates()
            params["start_date"] = lastDays.last?.getQueryParamDateString()
            params["end_date"] = lastDays.first?.getQueryParamDateString()
        }
        return params
    }
    
    private func get7IntervalDates() -> [Date] {
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var days = [Date]()
        for _ in 1 ... 7 {
            days.append(date)
            date = cal.date(byAdding: .day, value: -1, to: date)!
        }
        return days
    }
    
    func handleOpenDatepicker() {
        if helperTextfield.isFirstResponder {
            helperTextfield.resignFirstResponder()
        } else {
            selectedDate = datePicker?.date
            helperTextfield.becomeFirstResponder()
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
        helperTextfield.resignFirstResponder()
        guard let model = viewModel?.APODModels[indexPath.row] else { return }
        didTapAPODItem?(model)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > lastContetOffset.y {
            hideHeaderView()
        } else {
            showHeaderView()
        }
        lastContetOffset = scrollView.contentOffset
    }
    
    private func hideHeaderView() {
        UIView.animate(withDuration: 0.2) {
            self.headerView?.alpha = 0
            self.tableView.contentInset.top = 10
        }
    }
    
    private func showHeaderView() {
        UIView.animate(withDuration: 0) {
            self.headerView?.alpha = 1
            self.tableView.contentInset.top = 60
        }
    }
}

