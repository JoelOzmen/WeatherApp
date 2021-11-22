import Foundation

class AllForecasts: Identifiable, Codable {
    let approvedTime: String
    var forecasts: [Forecast]
    
    init(_ aTime: String,_ forecasts: [Forecast]) {
        self.approvedTime = aTime
        self.forecasts = forecasts
    }
}

class Forecast: Identifiable, Codable {
    let time: String
    let temp: Float
    let icon: Int
    
    init(time: String, temp: Float, icon: Int){
        self.time = time
        self.temp = temp
        self.icon = icon
    }
}
