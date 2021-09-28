//
//  ViewController.swift
//  APCS Stock
//
//  Created by Brian Kim on 5/31/20.
//  Copyright © 2020 Brian Kim. All rights reserved.
//

import UIKit
import Charts
import TinyConstraints
import SQLite3

// UIColor referenced from: https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}


class ViewController: UIViewController, ChartViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var symbolName: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var depositButton: UIButton!
    @IBOutlet weak var depositAmount: UITextField!
    @IBOutlet weak var stockPrice: UILabel!
    @IBOutlet weak var balanceAmount: UILabel!
    
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let rGreen = UIColor(hex: "#21ce99ff")
    let rDark = UIColor(hex: "#040d14ff")
    let rRed = UIColor(hex: "#f45532ff")
    
    var db: OpaquePointer?
    
   
    lazy var lineChartView: LineChartView = {
        
        let chartView = LineChartView()
        chartView.backgroundColor = rDark
        
        chartView.rightAxis.enabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.legend.enabled = false
        chartView.extraLeftOffset = -20
        
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .clear
        yAxis.axisLineColor = .white
        yAxis.drawAxisLineEnabled = false
        yAxis.drawGridLinesEnabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .clear
        xAxis.setLabelCount(6, force: false)
        xAxis.axisLineColor = .systemGray
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        
        chartView.animate(xAxisDuration: 0.9)
        
        
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stock = UserDefaults.standard
        var balance = stock.float(forKey: "balance")
        if(balance <= 0) {
            stock.set(Float(10000.00), forKey: "balance")
            balance = 10000.00
        }
        let id = stock.integer(forKey: "id")
        if(id == 0) {
            stock.set(1, forKey: "id")
        }
        
        balanceAmount.text = "$" + String(balance)
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = rDark
        
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        
        setData()
        
    }
    
  
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }

    
    func setData() {
        let set1 = LineChartDataSet(entries: yValues, label: nil)
        
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 3
        set1.setColor(rGreen!)
        
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.highlightColor = .white
        set1.highlightLineWidth = 0.75
        set1.highlightLineDashPhase = 2
        set1.highlightLineDashLengths = [2]
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactGenerator.impactOccurred()

        let colorTop =  rGreen!.cgColor

        let gradientColors = [colorTop, UIColor.clear.cgColor] as CFArray
        let colorLocations:[CGFloat] = [0.6, 0.0]
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        set1.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        set1.drawFilledEnabled = true
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }
    
    let yValues: [ChartDataEntry] = [
        ChartDataEntry(x:0, y: 15.0),
        ChartDataEntry(x:1, y: 10.0),
        ChartDataEntry(x:2, y: 20.0),
        ChartDataEntry(x:3, y: 15.0),
        ChartDataEntry(x:4, y: 16.0),
        ChartDataEntry(x:5, y: 25.0),
        ChartDataEntry(x:6, y: 35.0),
        ChartDataEntry(x:7, y: 30.0),
        ChartDataEntry(x:8, y: 37.0),
        ChartDataEntry(x:9, y: 34.0),
        ChartDataEntry(x:10, y: 29.0),
        ChartDataEntry(x:11, y: 12.0),
        ChartDataEntry(x:12, y: 20.0),
        ChartDataEntry(x:13, y: 34.0)
    ]

}

