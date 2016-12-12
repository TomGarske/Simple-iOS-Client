import UIKit
import UAProgressView
import UICountingLabel

class HeartRateTableViewController: UITableViewController {

    @IBOutlet weak var progressView: UAProgressView!
    @IBOutlet weak var progressViewBack: UAProgressView!
    @IBOutlet weak var currentlyViewingDate: UILabel!

    @IBOutlet weak var messageLabel: UILabel!

    var items : [RecordedItem]!

    override func viewDidLoad() {
        super.viewDidLoad()
        items = [RecordedItem]()
        configureProgressView()
        displayDate()

    }

    func displayDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = .none
        let dateString = formatter.string(from: Date())
        let dateStringArr = dateString.characters.split{$0 == ","}.map(String.init)
        self.currentlyViewingDate.text = String(format: "Today, %@", dateStringArr[0])
    }

    var lastHeartrate : Double = 0
    func configureProgressView() {
        let duration = 10.0

        self.progressViewBack.borderWidth = 1.0
        self.progressViewBack.tintColor = UIColor.orange
        progressView.fillOnTouch = true

        self.progressView.lineWidth = 10.0
        self.progressView.borderWidth = 0.0
        self.progressView.tintColor = UIColor.orange
        self.progressView.animationDuration = duration

        let label = UICountingLabel(frame: CGRect(x: 0, y: 0, width: 100.0, height: 100.0))
        label.format = "%d";
        label.center = CGPoint(x: 160, y: 284)
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.orange
        label.font = UIFont.boldSystemFont(ofSize: 48.0)
        label.animationDuration = 0.5
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
        _ = Timer.scheduledTimer(timeInterval: 10.0,
                                         target: self,
                                         selector: #selector(self.finish),
                                         userInfo: nil,
                                         repeats: false);
        newHeartRate = 74.2
    }

    var newHeartRate : Double = 0
    func finish(){
        messageLabel.text = "Tap For New Recording"
        let someLabel =  progressView?.centralView as! UICountingLabel
        someLabel.count(from: CGFloat(self.lastHeartrate), to: CGFloat(newHeartRate))
        self.lastHeartrate = newHeartRate
        items.append(RecordedItem(val:Double(newHeartRate), time: Date()))
        items = items.sorted(by: { $0.date > $1.date })
        refreshTable()
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
extension HeartRateTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! HeartRateViewTableViewCell
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
