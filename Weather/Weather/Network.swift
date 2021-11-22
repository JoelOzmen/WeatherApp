import Foundation
import Network

final class Network: ObservableObject{
    let monitor =  NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    
    @Published var Connected = true
    
    init(){
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.Connected = path.status == .satisfied ? true : false
            }
        }
        monitor.start(queue: queue)
    }
}
