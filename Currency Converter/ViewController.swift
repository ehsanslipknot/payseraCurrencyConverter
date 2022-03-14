//
//  ViewController.swift
//  Currency Converter
//
//  Created by Ehsan Zeinalinia on 3/14/22.
//

import UIKit
import Alamofire
import DropDown

class ViewController: UIViewController {
    
    @IBOutlet weak var clcView: UICollectionView!
    @IBOutlet weak var fromCurrencyTxtfield: UITextField!
    @IBOutlet weak var toCurrencyTxtfield: UITextField!
    
    @IBOutlet weak var fromCurrencyDropdown: UIButton!
    @IBOutlet weak var toCurrencyDropdown: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    
    let fromDropsDowns = DropDown()
    let toDropsDowns = DropDown()
    
    var fromCurrencyString = String()
    var toCurrencyString = String()
    var fromValue = Float()
    var toValue = Float()
    
    var spinner = UIActivityIndicatorView(style: .large)
    var loadingView: UIView = UIView()
    
    var convertLimitCounter = 1
    
    var currenciesDropdownList = ["EUR","USD","JPY"]
    
    private var myBalancesArray = [1000.00,0.00,0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDoneButtonOnKeyboard()
        
        toCurrencyTxtfield.isEnabled = false
        
        let layout = UICollectionViewCenterLayout()
        layout.estimatedItemSize = CGSize(width: 140, height: 40)
        layout.scrollDirection = .horizontal
        clcView.collectionViewLayout = layout
        
        fromDropsDowns.customCellConfiguration = { (_: Index, _: String, cell: DropDownCell) -> Void in
            // Setup your custom UI components
            cell.optionLabel.textAlignment = .center
            cell.optionLabel.font = .systemFont(ofSize: 20, weight: .regular)
        }
        fromDropsDowns.anchorView = fromCurrencyDropdown
        fromDropsDowns.dataSource = currenciesDropdownList
        fromDropsDowns.separatorColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        fromDropsDowns.selectionBackgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        fromCurrencyDropdown.setTitle("EUR ▼", for: .normal)
        
        fromDropsDowns.selectionAction = { [weak self] index, item in
            self?.fromCurrencyDropdown.setTitle(item + " ▼", for: .normal)
            
            if index == 0 {
                self?.fromCurrencyTxtfield.addTarget(self, action: #selector(self!.myTextFieldDidChange), for: .editingChanged)
                if let amountString = self?.fromCurrencyTxtfield.text?.currencyInputFormatting() {
                    self?.fromCurrencyTxtfield.text = amountString
                }
                print(self!.fromCurrencyTxtfield.text!)
                self?.fromValue = Float(self!.fromCurrencyTxtfield.text!) ?? 0.0
                self?.fromCurrencyString = "EUR"
            }else if index == 1 {
                self?.fromCurrencyTxtfield.addTarget(self, action: #selector(self!.myTextFieldDidChange), for: .editingChanged)
                if let amountString = self?.fromCurrencyTxtfield.text?.currencyInputFormatting() {
                    self?.fromCurrencyTxtfield.text = amountString
                }
                print(self!.fromCurrencyTxtfield.text!)
                self?.fromValue = Float(self!.fromCurrencyTxtfield.text!) ?? 0.0
                self?.fromCurrencyString = "USD"
            }else {
                self?.fromCurrencyTxtfield.removeTarget(self, action: #selector(self!.myTextFieldDidChange), for: .editingChanged)
                if let index = self?.fromCurrencyTxtfield.text!.firstIndex(of: ",") {
                    self?.fromCurrencyTxtfield.text!.replaceSubrange(index...index, with: "")
                }
                if let index = self?.fromCurrencyTxtfield.text!.firstIndex(of: ".") {
                    self?.fromCurrencyTxtfield.text!.replaceSubrange(index...index, with: "")
                }
                print(self!.fromCurrencyTxtfield.text!)
                self?.fromValue = Float(self!.fromCurrencyTxtfield.text!) ?? 0.0
                self?.fromCurrencyString = "JPY"
            }
        }
        
        self.fromCurrencyString = "EUR"
//        fromCurrencyTxtfield.text = "0.00"
        fromCurrencyTxtfield.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        
        toDropsDowns.customCellConfiguration = { (_: Index, _: String, cell: DropDownCell) -> Void in
            // Setup your custom UI components
            cell.optionLabel.textAlignment = .center
            cell.optionLabel.font = .systemFont(ofSize: 20, weight: .regular)
        }
        toDropsDowns.anchorView = toCurrencyDropdown
        toDropsDowns.dataSource = currenciesDropdownList
        toDropsDowns.separatorColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        toDropsDowns.selectionBackgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        toCurrencyDropdown.setTitle("EUR ▼", for: .normal)
        
        toDropsDowns.selectionAction = { [weak self] index, item in
            self?.toCurrencyDropdown.setTitle(item + " ▼", for: .normal)
            if index == 0 {
                print(self!.toCurrencyTxtfield.text!)
                self?.toCurrencyString = "EUR"
            }else if index == 1 {
                print(self!.toCurrencyTxtfield.text!)
                self?.toCurrencyString = "USD"
            }else {
                print(self!.toCurrencyTxtfield.text!)
                self?.toCurrencyString = "JPY"
            }
        }
        
        self.toCurrencyString = "EUR"
        toCurrencyTxtfield.text = "0.00"
        toCurrencyTxtfield.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
            print(textField.text!)
            fromValue = Float(textField.text!) ?? 0.0
        }
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = self.view.center
            self.loadingView.backgroundColor = UIColor(named: "#444444")
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10

            self.spinner = UIActivityIndicatorView(style: .large)
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)

            self.loadingView.addSubview(self.spinner)
            self.view.addSubview(self.loadingView)
            self.spinner.startAnimating()
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
    
    func fetchCurrency(fromAmount:Float,fromCurrency:String,toCurrency:String){
        showActivityIndicator()
        let urlString2 = "http://api.evp.lt/currency/commercial/exchange/\(fromAmount)-\(fromCurrency)/\(toCurrency)/latest"
        let url2 = URL(string: urlString2)
        
        AF.request(url2!, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            
            switch response.result {
            case let .success(json):
                
                self.hideActivityIndicator()
                let jsonsss = response.value as! NSDictionary
                
                var amount = Float()
                
                if jsonsss["amount"] == nil {
                    amount = 0
                }else {
                    amount = Float(jsonsss["amount"]! as! Substring)!
                }
                
                var comparedAmount = String()
                
                if self.toCurrencyString == "JPY" {
                    self.toCurrencyTxtfield.text = "+ " + String(Int(amount))
                    comparedAmount = String(Int(amount))
                    
                }else {
                    self.toCurrencyTxtfield.text = "+ " + String(amount)
                    comparedAmount = String(amount)
                }
                
                self.toCurrencyTxtfield.textColor = #colorLiteral(red: 0.4034030437, green: 0.6776425838, blue: 0.3543780744, alpha: 1)
                
                if self.convertLimitCounter > 5 {
                    let commissonFee = self.calculatePercentage(value: Double(self.fromValue), percentageVal: 0.7)
                    print(commissonFee)
                    let commissionFeeRound = Double(commissonFee).roundToDecimal(2)
                    let alert = UIAlertController(title: "Currency converted", message: "You Have converted \(self.fromValue) \(self.fromCurrencyString) to \(comparedAmount) \(self.toCurrencyString). Commission Fee - \(commissionFeeRound) \(self.fromCurrencyString).", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    if self.fromCurrencyString == "EUR" && self.toCurrencyString == "USD" {
                        self.myBalancesArray[0] -= (Double(self.fromValue) + commissionFeeRound).roundToDecimal(2)
                        self.myBalancesArray[1] += (Double(comparedAmount)! - commissionFeeRound).roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.fromCurrencyString == "EUR" && self.toCurrencyString == "JPY" {
                        self.myBalancesArray[0] -= (Double(self.fromValue) + commissionFeeRound).roundToDecimal(2)
                        self.myBalancesArray[2] += (Double(comparedAmount)! - commissionFeeRound).roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.fromCurrencyString == "USD" && self.toCurrencyString == "EUR" {
                        self.myBalancesArray[1] -= (Double(self.fromValue) + commissionFeeRound).roundToDecimal(2)
                        self.myBalancesArray[0] += (Double(comparedAmount)! - commissionFeeRound).roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.fromCurrencyString == "USD" && self.toCurrencyString == "JPY" {
                        self.myBalancesArray[1] -= (Double(self.fromValue) + commissionFeeRound).roundToDecimal(2)
                        self.myBalancesArray[2] += (Double(comparedAmount)! - commissionFeeRound).roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.fromCurrencyString == "JPY" && self.toCurrencyString == "EUR" {
                        self.myBalancesArray[2] -= (Double(self.fromValue) + commissionFeeRound).roundToDecimal(2)
                        self.myBalancesArray[0] += (Double(comparedAmount)! - commissionFeeRound).roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.fromCurrencyString == "JPY" && self.toCurrencyString == "USD" {
                        self.myBalancesArray[2] -= (Double(self.fromValue) + commissionFeeRound).roundToDecimal(2)
                        self.myBalancesArray[1] += (Double(comparedAmount)! - commissionFeeRound).roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.myBalancesArray[0].sign == .minus {
                        let alert = UIAlertController(title: "Alert" , message: "you can't do this conversion", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.toCurrencyTxtfield.text = ""
                    }else if self.myBalancesArray[1].sign == .minus {
                        let alert = UIAlertController(title: "Alert" , message: "you can't do this conversion", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.toCurrencyTxtfield.text = ""
                    }else if self.myBalancesArray[2].sign == .minus {
                        let alert = UIAlertController(title: "Alert" , message: "you can't do this conversion", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.toCurrencyTxtfield.text = ""
                    }
                    
                    
                }else {
                    let alert = UIAlertController(title: "Currency converted", message: "You Have converted \(self.fromValue) \(self.fromCurrencyString) to \(comparedAmount) \(self.toCurrencyString).", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    if self.fromCurrencyString == "EUR" && self.toCurrencyString == "USD" {
                        self.myBalancesArray[0] -= Double(self.fromValue).roundToDecimal(2)
                        self.myBalancesArray[1] += Double(comparedAmount)!.roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.fromCurrencyString == "EUR" && self.toCurrencyString == "JPY" {
                        self.myBalancesArray[0] -= Double(self.fromValue).roundToDecimal(2)
                        self.myBalancesArray[2] += Double(comparedAmount)!.roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.fromCurrencyString == "USD" && self.toCurrencyString == "EUR" {
                        self.myBalancesArray[1] -= Double(self.fromValue).roundToDecimal(2)
                        self.myBalancesArray[0] += Double(comparedAmount)!.roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.fromCurrencyString == "USD" && self.toCurrencyString == "JPY" {
                        self.myBalancesArray[1] -= Double(self.fromValue).roundToDecimal(2)
                        self.myBalancesArray[2] += Double(comparedAmount)!.roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.fromCurrencyString == "JPY" && self.toCurrencyString == "EUR" {
                        self.myBalancesArray[2] -= Double(self.fromValue).roundToDecimal(2)
                        self.myBalancesArray[0] += Double(comparedAmount)!.roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.fromCurrencyString == "JPY" && self.toCurrencyString == "USD" {
                        self.myBalancesArray[2] -= Double(self.fromValue).roundToDecimal(2)
                        self.myBalancesArray[1] += Double(comparedAmount)!.roundToDecimal(2)
                        self.convertLimitCounter += 1
                    }else if self.myBalancesArray[0].sign == .minus {
                        let alert = UIAlertController(title: "Alert" , message: "you can't do this conversion", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.toCurrencyTxtfield.text = ""
                    }else if self.myBalancesArray[1].sign == .minus {
                        let alert = UIAlertController(title: "Alert" , message: "you can't do this conversion", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.toCurrencyTxtfield.text = ""
                    }else if self.myBalancesArray[2].sign == .minus {
                        let alert = UIAlertController(title: "Alert" , message: "you can't do this conversion", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.toCurrencyTxtfield.text = ""
                    }
                    
                }
                
                
                self.clcView.reloadData()
                
                print("fetch success: \(json)")
                
            case let .failure(error):
                print("fetch error :\(error)")
                self.hideActivityIndicator()
            }
            
        }.cURLDescription { description in
            print(description)
        }
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "close", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        fromCurrencyTxtfield.inputAccessoryView = doneToolbar
        toCurrencyTxtfield.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        fromCurrencyTxtfield.resignFirstResponder()
        toCurrencyTxtfield.resignFirstResponder()
    }
    
    public func calculatePercentage(value:Double,percentageVal:Double)->Double{
        let val = value * percentageVal
        return val / 100.0
    }
    
    @IBAction func fromCurrencyDropdownAction(_ sender: UIButton) {
        fromDropsDowns.show()
    }
    
    @IBAction func toCurrencyDropdownAction(_ sender: UIButton) {
        toDropsDowns.show()
    }
    
    @IBAction func submitBtnAction(_ sender: UIButton) {
        if fromValue == 0.0{
            let alert = UIAlertController(title: "Alert" , message: "The value you entered is not valid", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.toCurrencyTxtfield.text = ""
        }else {
            if fromCurrencyString == toCurrencyString {
                let alert = UIAlertController(title: "Alert" , message: "both currencies are equal", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.toCurrencyTxtfield.text = ""
            }else {
                if self.fromCurrencyString == "EUR" && Double(fromValue) > self.myBalancesArray[0] {
                    let alert = UIAlertController(title: "Alert" , message: "you don't have enough balance for this conversion", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.toCurrencyTxtfield.text = ""
                }else if self.fromCurrencyString == "USD" && Double(fromValue) > self.myBalancesArray[1]{
                    let alert = UIAlertController(title: "Alert" , message: "you don't have enough balance for this conversion", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.toCurrencyTxtfield.text = ""
                }else if self.fromCurrencyString == "JPY" && Double(fromValue) > self.myBalancesArray[2]{
                    let alert = UIAlertController(title: "Alert" , message: "you don't have enough balance for this conversion", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.toCurrencyTxtfield.text = ""
                }else{
                    self.fetchCurrency(fromAmount: fromValue, fromCurrency: fromCurrencyString, toCurrency: toCurrencyString)
                }
                
            }
            
        }
        
    }
    
}


extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myBalancesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "titleCell",
                                                            for: indexPath) as? RoundedCollectionViewCell else {
            return RoundedCollectionViewCell()
        }
        
        cell.textLabel.text = String(myBalancesArray[indexPath.row].roundToDecimal(2)) + " " + currenciesDropdownList[indexPath.row]
        
        return cell
    }
    
}


extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
