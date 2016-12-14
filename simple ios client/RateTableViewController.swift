import UIKit
import UAProgressView
import UICountingLabel
import CoreMotion

class RateTableViewController: UITableViewController {

    var serverPath="http://192.168.0.23:5000/api/v1.0/"
    let motionManager = CMMotionManager()

    @IBOutlet weak var progressView: UAProgressView!
    @IBOutlet weak var progressViewBack: UAProgressView!
    @IBOutlet weak var currentlyViewingDate: UILabel!

    @IBOutlet weak var messageLabel: UILabel!

    var rateType : NSString! = "test"
    var items : [RecordedItem]!
    let recordingDuration = 20.0


    var newData : [Double]!
    var dt : [Double]!

    override func viewDidLoad() {
        super.viewDidLoad()
        items = [RecordedItem]()
        configureProgressView()
        displayDate()
        self.serverPath = self.serverPath + String(self.rateType) + "/" + String(self.getUserId())
        loadItemsFromHistory()
    }

    func loadItemsFromHistory(){
        self.getRequestHistory(path: self.serverPath)
    }

    func displayDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = .none
        let dateString = formatter.string(from: Date())
        self.currentlyViewingDate.text = dateString
    }

    func configureProgressView() {
        if self.rateType == "heartrate" {
            self.progressViewBack.tintColor = UIColor.orange
            self.progressView.tintColor = UIColor.orange
        }else {
            self.progressViewBack.tintColor = UIColor.blue
            self.progressView.tintColor = UIColor.blue
        }

        self.progressViewBack.borderWidth = 1.0
        progressView.fillOnTouch = true

        self.progressView.lineWidth = 10.0
        self.progressView.borderWidth = 0.0
        self.progressView.animationDuration = recordingDuration

        let label = UICountingLabel(frame: CGRect(x: 0, y: 0, width: 100.0, height: 100.0))
        label.format = "%d";
        label.center = CGPoint(x: 160, y: 284)
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.clear

        if self.rateType == "heartrate" {
            label.textColor = UIColor.orange
        }else {
            label.textColor = UIColor.blue
        }

        label.font = UIFont.boldSystemFont(ofSize: 48.0)
        label.animationDuration = 1.0
        self.progressView.centralView = label
        self.progressView.didSelectBlock = {
            (progressView : UAProgressView?) -> Void in
            self.startRecording()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        messageLabel.text = "Tap For New Recording"
        super.viewDidAppear(animated)
        refreshTable()
    }

    func startRecording() {
        messageLabel.text = "Measuring..."
        self.progressView.setProgress(0, animated: false)
        self.progressView.setProgress(100, animated: true)
        let someLabel =  progressView?.centralView as! UICountingLabel
        someLabel.text = "0"
        startAccelerometer()
        _ = Timer.scheduledTimer(timeInterval: recordingDuration,
                                         target: self,
                                         selector: #selector(self.finish),
                                         userInfo: nil,
                                         repeats: false);

        _ = Timer.scheduledTimer(timeInterval: recordingDuration-2.0,
                                 target: self,
                                 selector: #selector(self.sendToServer),
                                 userInfo: nil,
                                 repeats: false);
    }

    func sendToServer(){
        print("Sending to server...")
        messageLabel.text = "Calculating..."
        motionManager.stopAccelerometerUpdates()
        let json = [ "dt":self.dt,"values":self.newData] as [String : Any]
        self.sendRequestRate(path: self.serverPath,data:json,method:"POST")
    }

    var newrate : Double = 0
    func finish(){
        print(String.init(format:"Presenting Result: %f", newrate))
        messageLabel.text = "Tap For New Recording"
        let someLabel =  progressView?.centralView as! UICountingLabel
        someLabel.count(from: CGFloat(0.0), to: CGFloat(newrate))
        items.append(RecordedItem(val:Double(newrate), time: Date(), type:getType()))
        items = items.sorted(by: { $0.date > $1.date })
        refreshTable()
    }

    func getType()->String{
        if rateType == "heartrate"{
            return "Beats"
        }
        return "Breaths"
    }

    func refreshTable(){
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.progressView.setProgress(0.0, animated: false)
        super.viewDidDisappear(animated)
    }
}

// MARK: UITableViewDataSource
extension RateTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! RateViewTableViewCell
        let record = items[indexPath.row]
        cell.activityTitle?.text = record.value
        cell.activitySubtitle?.text =  record.timestamp
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        return cell
    }
}

// Extension for recording from accelerometer
extension RateTableViewController {

    func startAccelerometer() {
        self.newData = [Double]()
        self.dt = [Double]()
        if motionManager.isAccelerometerAvailable {
            let sampling = 0.00
            motionManager.accelerometerUpdateInterval = sampling
            var lastTime = TimeInterval()
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) {
                (data: CMAccelerometerData?, error: Error?) in
                let z = data!.acceleration.z
                let time = (data!.timestamp - lastTime)*1000
                lastTime = data!.timestamp
                if(time<1000){
                    self.dt.append(time)
                    self.newData.append(z)
                }
            }
        }
    }
    
}

// Extension for sending post requests
extension RateTableViewController {

    func sendRequestRate(path : String, data : Dictionary<String, Any>, method : String){
        print(path)
        let url = URL(string: path)!
        let session = URLSession.shared
        do {
            // Set Data to JSON Object
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)

            // Set URLRequest body and header
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.cachePolicy = .reloadIgnoringCacheData
            request.httpBody = jsonData

            // Send request and capture response
            let task = session.dataTask(with: request){ data,response,error in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                let dict = (json as! NSDictionary!)
                if((dict?.allKeys.count)! > 0){
                    self.newrate = dict![self.rateType] as! Double
                }
                print(String.init(format:"Fetched Result: %f", self.newrate))
            }
            task.resume()
        }catch { print(error) }
    }

    func getRequestHistory(path : String){
        print(path)
        let url = URL(string: path)!
        let session = URLSession.shared
        do {
            // Set URLRequest body and header
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.cachePolicy = .reloadIgnoringCacheData

            // Send request and capture response
            let task = session.dataTask(with: request){ data,response,error in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                let dict = (json as! NSDictionary!)
                let items = dict?["items"] as! Array<NSDictionary>
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
                for item in items {
                    print(item)
                    let rate : Double = item["recordedValue"] as! Double
                    let time : Date = dateFormatter.date(from: item["recordedDatetime"] as! String)!
                    self.items.append(RecordedItem(val:rate,time:time, type:self.getType()))
                }
                self.items = self.items.sorted(by: { $0.date > $1.date })
                DispatchQueue.main.async {
                    self.refreshTable()
                }
            }
            task.resume()
        }
    }
    
}
