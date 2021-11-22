import Foundation

class ViewModel: ObservableObject{
    
    private enum FetchError: Error {
        case runtimeError(String)
    }
    
    class JsonData: Decodable {
        let approvedTime: String
        let timeSeries: [TimeSeries]
    }
    
    class TimeSeries: Decodable {
        let validTime: String
        let parameters: [Parameter]
    }
    
    struct Parameter: Decodable {
        let name: String
        let values: [Float]
    }
    
    @Published var lon: Float!
    @Published var lat: Float!
    @Published var allForecasts: AllForecasts? //Listan med all info
    let saveKey = "SavedData" //För att spara data
    
    func requestWeather(){
        Task {
            allForecasts = await fetchData(lon: lon, lat: lat)
            await saveData()
        }
    }
    
    func saveData() async {
        let listOfForecasts = AllForecasts(self.allForecasts!.approvedTime, self.allForecasts!.forecasts)
        if let encoded = try? JSONEncoder().encode(listOfForecasts){
            //Save data to UserDefault
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func fetchSavedData() async {
        if let dataExist = UserDefaults.standard.data(forKey: saveKey){
            do {
                let decodedData = try JSONDecoder().decode(AllForecasts.self, from: dataExist)
                self.allForecasts!.forecasts = decodedData.forecasts
            }
            catch{
                print(error)
            }
        }
    }
    
    func fetchData(lon: Float, lat: Float) async -> AllForecasts? {
        do {
            //Gör Stringen till en URLstring
            guard let urlString = URL(string: "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/\(lon)/lat/\(lat)/data.json")
            else{throw FetchError.runtimeError("Could not fetch url")}
            
            //Gör om URL sträng till data och decodar json datat
            let (data, _) = try await URLSession.shared.data(from: urlString)
            let forecastData = try JSONDecoder().decode(JsonData.self, from: data)
            
            //Skapar en array av forecasts med en dynamisk storlek anpassad från antal timeseries
            var forecastList: [Forecast] = []
            forecastList.reserveCapacity(forecastData.timeSeries.count)
            
            //Går igenom alla timeseries & samlar ihop info för: time, temp, icon, "t" och "Wsymb2"
            for timeserie in forecastData.timeSeries {
                let time = timeserie.validTime
                var temperature: Float = 0
                var icon = 0
                for parameter in timeserie.parameters {
                    if("t" == parameter.name){
                        temperature = parameter.values[0]
                    }
                    if("Wsymb2" == parameter.name){
                        icon = Int(parameter.values[0])
                    }
                }
                forecastList.append(Forecast(time: time, temp: temperature, icon: icon))
            }
            return AllForecasts(forecastData.approvedTime, forecastList)
        }
        catch {return nil}
    }
}
