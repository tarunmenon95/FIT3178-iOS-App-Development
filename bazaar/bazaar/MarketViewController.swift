//  MarketViewController.swift
//  bazaar

import UIKit
import Charts
import TinyConstraints

//Codable struct for parsing forexData
struct forexData  : Codable {
    var description : String
    var displaySymbol: String
    var symbol: String
}

//The MarketViewController handles all relevant actions/information for displaying/retrieved forexData and currency exchange rates
//Further adds functionality for creating and displaying graphs on click for any given forex item

class MarketViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
  
    //Class Variables
    @IBOutlet weak var posLabel: UILabel!
    var currencies : [GeneralisedItem] = []
    var forexArray: [forexItem] = []
    var candleArray : [ChartDataEntry] = []
    
    //Create chart lazily
    lazy var DetailedLineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.rightAxis.enabled = false
        chartView.leftAxis.labelTextColor = .white
        chartView.leftAxis.axisLineColor = .white
        chartView.legend.enabled = false
        chartView.leftAxis.gridColor = .black
        chartView.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.gridColor = .black
        chartView.animate(xAxisDuration: 2.5)
        chartView.backgroundColor = .black
        return chartView
    }()
  
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }
    
    //When view loads, get real time currency and forex information
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCurrency()
        self.getForex()
    }
    
    //Get candlestick data for selected forex item on click, used to create the graph for the given item
    func getCandle(aSymbol:String){
        
        //Time variables
        let from = Int(Date().timeIntervalSince1970) - 31536000
        let to = Int(Date().timeIntervalSince1970)
        
        //API Query
        guard let url = URL(string: "https://finnhub.io/api/v1/forex/candle?symbol=\(aSymbol)&resolution=M&from=\(from)&to=\(to)&token=c2vjl72ad3ifkigbq5o0")
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
                    let candleData = try decoder.decode(stockHistory.self, from: data)

                    //Create chart entries
                    for x in 0...candleData.c.count-1{
                        self.candleArray.append(ChartDataEntry(x: Double(x), y: candleData.c[x]))
                    }
                    //Make Chart
                    DispatchQueue.main.async {
                        self.makeChart()
                    }
                 }
                catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    //Function that does API Query to retrieve real time forex data, used to populate table view
    func getForex(){
        
        //API Query
        guard let url = URL(string: "https://finnhub.io/api/v1/forex/symbol?exchange=oanda&token=c2vjl72ad3ifkigbq5o0")
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
                    let forex = try decoder.decode([forexData].self, from: data)
                    
                    //Populate forexArray
                    for elem in forex{
                        self.forexArray.append(forexItem(newDesc: elem.description, newDis: elem.displaySymbol, newSymb: elem.symbol))
                    }
                    //Reload forexTable after population
                    DispatchQueue.main.async {
                        self.forexTable.reloadData()
                       
                    }
                    
                 }
                catch {
                    print(error)
                }
                
            }
        }
        
        task.resume()
    }
    
    //Function to retrieve real time exchange rate data on currency via API Query, used to populate collection view
    func getCurrency(){
        //API Query
        guard let url = URL(string: "https://v6.exchangerate-api.com/v6/514604fa79f89199d08b2dba/latest/USD")
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
                    let curInfo = try decoder.decode(currencyData.self, from: data)
                    let rates = curInfo.conversion_rates
                    
                    //Create currency item and add to currency array
                    for elem in rates {
                        let name = elem.key
                        let val = elem.value
                        let currency = GeneralisedItem(newName: name, newValue: val,newType: "Currency",newSymbol: name)
                        self.currencies.append(currency)
                    }
                    
                    //Reload collection view
                    DispatchQueue.main.async {
                        self.colView.reloadData()
                       
                    }
                 }
                catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    //Add chart to view and set data
    func makeChart(){
        view.addSubview(DetailedLineChartView)
        DetailedLineChartView.centerXToSuperview()
        DetailedLineChartView.centerY(to: posLabel)
        
        DetailedLineChartView.width(to: view)
        DetailedLineChartView.height(CGFloat(300))
        
        setData()
    }
    
    //Use candlestick data to add chart entry data to graph
    func setData(){
            let candleSet = LineChartDataSet(entries: candleArray)
            candleSet.drawCirclesEnabled = false
            candleSet.mode = .cubicBezier
            candleSet.lineWidth = 5
            candleSet.setColor(.purple)
            
            let data = LineChartData(dataSet: candleSet)
            data.setDrawValues(false)
            DetailedLineChartView.data = data
            candleArray = []
        }
    
    //Collection View
    @IBOutlet weak var colView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencies.count
    }
    
    //Use custom collectionviewCell for displaying currencies
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrencyCollectionViewCell", for: indexPath) as! CurrencyCollectionViewCell
        cell.nameLabel.text = currencies[indexPath.row].name
        cell.valueLabel.text = String(format: "%.2f",currencies[indexPath.row].value)
        return cell
    }
    
    //Table View
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return forexArray.count
     }
    
    //On select, getCandlestick data and create graph
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = forexArray[indexPath.row].symbol
        getCandle(aSymbol: item)
        
    }
     
     @IBOutlet weak var forexTable: UITableView!
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "forexCell", for: indexPath)
         cell.textLabel?.text = forexArray[indexPath.row].display
         cell.detailTextLabel?.text = forexArray[indexPath.row].descript
         return cell
         
     }

}
