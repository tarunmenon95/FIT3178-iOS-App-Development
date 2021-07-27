//  CryptoGraphViewController.swift
//  bazaar

import UIKit
import Charts
import TinyConstraints

//Codable struct for parsing cryptoCoinData
struct cryptoCoinData: Codable{
    var price : String
    var hour : cryptoHistoric
    var day : cryptoHistoric
    var week : cryptoHistoric
    var month : cryptoHistoric
    
    private enum CodingKeys:String, CodingKey {
        case price
        case hour = "1h"
        case day = "1d"
        case week = "7d"
        case month = "30d"
        
    }
}

//Codable struct for parsing crpytoHistoric
struct cryptoHistoric :Codable{
    var price_change : String
}

//TheCryptoGraphViewController handles all relevant actions/information for creating and displaying a graph representing the
//three highest performing crpyto currencies
class CryptoGraphViewController: UIViewController,ChartViewDelegate {

    //Class Variables
    var cryptoDataArray : [[Double]] = []
    var btcArray : [ChartDataEntry] = []
    var ethArray : [ChartDataEntry] = []
    var usdtArray : [ChartDataEntry] = []
    
    //Create linechartview
    lazy var lineChartView: LineChartView = {
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
    
    //When view loads, complete API Query to retrieve datasets then create graph
    override func viewDidLoad() {
        super.viewDidLoad()

        //API query for datasets
        guard let url = URL(string: "https://api.nomics.com/v1/currencies/ticker?key=e9a5092e5343677facc0784bb58c64043ab47d95&ids=BNB,ETH,BCH&interval=1h,1d,7d,30d&convert=USD&per-page=100&page=1")
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
                    let historicCrypto = try decoder.decode([cryptoCoinData].self, from: data)
                    
                    //Get crypto history then add to array
                    for elem in historicCrypto{
                        let current = Double(elem.price)
                        let hour = current! - Double(elem.hour.price_change)!
                        let day = current! - Double(elem.day.price_change)!
                        let week = current! - Double(elem.week.price_change)!
                        let month = current! - Double(elem.month.price_change)!
                        self.cryptoDataArray.append([month,week,day,hour,current!])
                    }
                    
                    //For each crypto, get monthly history then add to chart data entry array
                    for n in 0...4{
                        self.btcArray.append(ChartDataEntry(x: Double(n), y: self.cryptoDataArray[0][n]))
                    }
                    for n in 0...4{
                        self.ethArray.append(ChartDataEntry(x: Double(n), y: self.cryptoDataArray[1][n]))
                    }
                    for n in 0...4{
                        self.usdtArray.append(ChartDataEntry(x: Double(n), y: self.cryptoDataArray[2][n]))
                    }
                    //Make chart
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
    
    //Add chart to view and set data
    func makeChart(){
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        setData()
    }
    
    //Set data for three high performers, add all sets to linechart view
    func setData(){
        let btcSet = LineChartDataSet(entries: btcArray,label: "BNB")
        btcSet.drawCirclesEnabled = false
        btcSet.mode = .cubicBezier
        btcSet.lineWidth = 5
        btcSet.setColor(.purple)
        
        let ethSet = LineChartDataSet(entries: ethArray,label: "ETH")
        ethSet.drawCirclesEnabled = false
        ethSet.mode = .cubicBezier
        ethSet.lineWidth = 5
        ethSet.setColor(.systemPink)
        
        let usdtSet = LineChartDataSet(entries: usdtArray,label: "BCH")
        usdtSet.drawCirclesEnabled = false
        usdtSet.mode = .cubicBezier
        usdtSet.lineWidth = 5
        usdtSet.setColor(.magenta)
        
        let data = LineChartData(dataSets: [btcSet,ethSet,usdtSet])
        data.setDrawValues(false)
        lineChartView.data = data
    }

}
