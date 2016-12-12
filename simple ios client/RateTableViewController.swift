import UIKit
import UAProgressView
import UICountingLabel

class RateTableViewController: UITableViewController {

    @IBOutlet weak var progressView: UAProgressView!
    @IBOutlet weak var progressViewBack: UAProgressView!
    @IBOutlet weak var currentlyViewingDate: UILabel!

    @IBOutlet weak var messageLabel: UILabel!

    var rateType : NSString! = "test"
    var items : [RecordedItem]!
    let recordingDuration = 20.0

    override func viewDidLoad() {
        super.viewDidLoad()
        items = [RecordedItem]()
        configureProgressView()
        displayDate()

        print(self.rateType)
    }

    func displayDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = .none
        let dateString = formatter.string(from: Date())
        self.currentlyViewingDate.text = dateString
    }

    var lastrate : Double = 0
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
        _ = Timer.scheduledTimer(timeInterval: recordingDuration,
                                         target: self,
                                         selector: #selector(self.finish),
                                         userInfo: nil,
                                         repeats: false);
        newrate = recordNewRate()
    }

    func recordNewRate() -> Double {
        var nrate = 0.0
        if self.rateType == "heartrate" {
            nrate = 74.2
        }else {
            nrate = 17.3
        }
        return nrate
    }

    var newrate : Double = 0
    func finish(){
        messageLabel.text = "Tap For New Recording"
        let someLabel =  progressView?.centralView as! UICountingLabel
        someLabel.count(from: CGFloat(self.lastrate), to: CGFloat(newrate))
        self.lastrate = newrate
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
