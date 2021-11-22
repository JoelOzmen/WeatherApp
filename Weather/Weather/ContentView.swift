import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @ObservedObject var monitor = Network()
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack{
            //Rubrik
            VStack{
                Image(systemName: monitor.Connected ? "wifi" : "wifi.slash").font(.system(size: 20))
                Text(monitor.Connected ? "Connected" : "Not connected!")
                
                Text("Weather forecast")
                    .fontWeight(.bold)
                    .font(.system(size: 30))
                    .padding()
                HStack{
                    Text("Approved time:")
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                    Text("\(viewModel.allForecasts?.approvedTime ?? "---")")
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                }
            }
            .padding([.leading, .bottom, .trailing], 10.0)
            Spacer()
            
            //Listan
            NavigationView{
                List(viewModel.allForecasts?.forecasts ?? []) { forecast in
                    VStack{
                        Text(forecast.time)
                            .fontWeight(.bold)
                            .font(.system(size: 15))
                        HStack{
                            Image(String(forecast.icon))
                            Text("\(forecast.temp)")
                                .fontWeight(.bold)
                                .font(.system(size: 20))
                        }
                    }
                }
            }
            Spacer()
            
            //Knappar
            HStack {
                Spacer()
                TextField("Longitude", value: $viewModel.lon, format: .number)
                    .padding(7.0)
                    .font(.system(size: 25))
                    .disableAutocorrection(true)
                    .background(Color(.systemGray4))
                    .cornerRadius(12)
                    .keyboardType(.decimalPad)
                    .focused($focused)
                
                TextField("Latitude", value: $viewModel.lat, format: .number)
                    .padding(7.0)
                    .font(.system(size: 25))
                    .disableAutocorrection(true)
                    .background(Color(.systemGray4))
                    .cornerRadius(12)
                    .keyboardType(.decimalPad)
                    .focused($focused)
                
                Button(action: {
                    focused = false
                    Task {viewModel.requestWeather()}}, label: {
                        Text("Submit")
                            .padding(7.0)
                            .font(.system(size: 25))
                            .foregroundColor(.black)
                            .background(Color(.systemGray4))
                    })
                    .cornerRadius(12)
                    .shadow(color: .black, radius: 1, x: 0, y: 1)
                    .disabled(viewModel.disableButton)
                Spacer()
            }
        }
        .alert(isPresented: $viewModel.errorCatch) {
            return Alert(title: Text("Could not fetch data"), message: Text("Invalid input"), dismissButton: .default(Text("Dismiss")))
        }
        .onChange(of: viewModel.lon) { n in
            disableSubmit()
        }
        .onChange(of: viewModel.lat) { n in
            disableSubmit()
        }
    }
    
    func disableSubmit(){
        if(viewModel.lat == nil || viewModel.lon == nil){
                viewModel.disableButton = true
        }
        else{
            viewModel.disableButton = false
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
