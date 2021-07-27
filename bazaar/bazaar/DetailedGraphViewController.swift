//  DetailedGraphViewController.swift
//  bazaar


import UIKit
import Charts
import TinyConstraints

//Codable struct to parse stockHistory
struct stockHistory :Codable{
    var c : [Double]
}

//The DetailedGraphTableViewController handles all relevant actions/information for  creating and displaying a visual graph which
//is based on current stock information retrieved from API Request
class DetailedGraphViewController: UIViewController{
    
    //Class Variables
    var symbol = ""
    var type = ""
    var coinArray : [ChartDataEntry] = []
    var stockArray : [ChartDataEntry] = []
    
    //Create LineChartView lazily
    lazy var DetailedLineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.rightAxis.enabled = false
        chartView.leftAxis.labelTextColor = .white
        chartView.leftAxis.axisLineColor = .white
        chartView.legend.textColor = .white
        chartView.leftAxis.gridColor = .black
        chartView.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.gridColor = .black
        chartView.animate(xAxisDuration: 2.5)
          return chartView
    }()
    
    //When view loads, create crypto or stock graph
    override func viewDidLoad() {
        super.viewDidLoad()
        if type != ""{
            //Crypto graph after delay (Due to API Constraints)
            if type == "Crypto"{
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    self.cryptoCall()
                }
            }
            //Stock Graph
            if type == "Stock"{
                self.stockCall()
            }
        }
    }
    
    //Function that does API request for current data of selected cryptocurrency, then using this data we create the respective graph
    func cryptoCall(){
        //API Query
        guard let url = URL(string: "https://api.nomics.com/v1/currencies/ticker?key=e9a5092e5343677facc0784bb58c64043ab47d95&ids=\(symbol)&interval=1h,1d,7d,30d&convert=USD&per-page=100&page=1")
        else{
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
            }
            else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let coinhistory = try decoder.decode([cryptoCoinData].self, from: data)
                    
                    let elem = coinhistory[0]
                    
                    //Get relevant data
                    let current = Double(elem.price)
                    let hour = current! - Double(elem.hour.price_change)!
                    let day = current! - Double(elem.day.price_change)!
                    let week = current! - Double(elem.week.price_change)!
                    let month = current! - Double(elem.month.price_change)!
                        
                    //Store as chartDataEntries
                    self.coinArray.append(ChartDataEntry(x: 0, y: month))
                    self.coinArray.append(ChartDataEntry(x: 1, y: week))
                    self.coinArray.append(ChartDataEntry(x: 2, y: day))
                    self.coinArray.append(ChartDataEntry(x: 3, y: hour))
                    self.coinArray.append(ChartDataEntry(x: 4, y: current!))
                    
                    //Create Chart
                    DispatchQueue.main.async {
                        self.makeChart()
                    }
                 }
                catch {
                    print(url)
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    //Function that does API request for current data of selected stock, then using this data we create the respective graph
    func stockCall(){
        
        //Time variables
        let monthUnix = 2419200
        let from = Int(Date().timeIntervalSince1970) - monthUnix
        let to = Int(Date().timeIntervalSince1970)
        
        //API Query
        guard let url = URL(string: "https://finnhub.io/api/v1/stock/candle?symbol=\(symbol)&resolution=D&from=\(from)&to=\(to)&token=c2vjl72ad3ifkigbq5o0")
        
        else{
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
            }
            else if let data = data {
                do {
                    
                    let decoder = JSONDecoder()
                    let stockItem = try decoder.decode(stockHistory.self, from: data)
                    
                    //Add chartEntries
                    for x in 0...stockItem.c.count-1{
                        self.stockArray.append(ChartDataEntry(x: Double(x), y: stockItem.c[x]))
                    }
                    
                    //Make Chart
                    DispatchQueue.main.async {
                        self.makeChart()
                    }
                 }
                catch {
                    print(url)
                    print(error)
                }
            }
        }
        
        task.resume()
    }
    
    //Adds chart to the view and positions it
    func makeChart(){
        view.addSubview(DetailedLineChartView)
        DetailedLineChartView.centerInSuperview()
        DetailedLineChartView.width(to: view)
        DetailedLineChartView.heightToWidth(of: view)
        setData()
    }
    
    //Sets the data for the chart based on crypto/stock data entries
    func setData(){
        if type == "Crypto"{
            let coinSet = LineChartDataSet(entries: coinArray,label: symbol)
            coinSet.drawCirclesEnabled = false
            coinSet.mode = .cubicBezier
            coinSet.lineWidth = 5
            coinSet.setColor(.purple)
            
            let data = LineChartData(dataSet: coinSet)
            data.setDrawValues(false)
            DetailedLineChartView.data = data
        }
        if type == "Stock"{
            let stockSet = LineChartDataSet(entries: stockArray,label: symbol)
            stockSet.drawCirclesEnabled = false
            stockSet.mode = .cubicBezier
            stockSet.lineWidth = 5
            stockSet.setColor(.purple)
            
            let data = LineChartData(dataSet: stockSet)
            data.setDrawValues(false)
            DetailedLineChartView.data = data
            }
        }
        
    }
