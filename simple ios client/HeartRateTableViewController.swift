import UIKit
import UAProgressView
import UICountingLabel

class HeartRateTableViewController: UITableViewController {

    @IBOutlet weak var progressView: UAProgressView!
    @IBOutlet weak var progressViewBack: UAProgressView!
    @IBOutlet weak var currentlyViewingDate: UILabel!

    var lastProgress = CGFloat(0)
    override func viewDidLoad() {
        super.viewDidLoad()

        activities = [
            dailyCheckActivity,
            GlucoseLogActivity(),
            WeeklyCheckActivity(),
            QualityOfLifeActivity(),
            WeightMeasurementActivity(),
            FoodLogActivity(),
            DoctorAppointmentActivity(),
            DPPActivity(),
        ]

        configureProgressView()
        displayDate()
    }

    func displayDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = .none
        let dateString = formatter.string(from: currentDate)
        let dateStringArr = dateString.characters.split{$0 == ","}.map(String.init)
        self.currentlyViewingDate.text = String(format: "Today, %@", dateStringArr[0])
    }

    func configureProgressView() {
        let duration = 0.5

        self.progressViewBack.borderWidth = 6.0
        self.progressViewBack.tintColor = UIColor.drGreyColor()
        progressView.fillOnTouch = false

        self.progressView.lineWidth = 10.0
        self.progressView.borderWidth = 0.0
        self.progressView.tintColor = UIColor.drOceanColor()
        self.progressView.animationDuration = duration

        let label = UICountingLabel(frame: CGRect(x: 0, y: 0, width: 100.0, height: 100.0))
        label.format = "%d";
        label.center = CGPoint(x: 160, y: 284)
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.drOceanColor()
        label.font = UIFont.boldSystemFont(ofSize: 48.0)
        label.animationDuration = duration
        self.progressView.centralView = label

        self.progressView.progressChangedBlock = {
            (progressView : UAProgressView?, progress : CGFloat) -> Void in
            let someLabel =  progressView?.centralView as! UICountingLabel
            someLabel.count(from: self.lastProgress, to: progress*100)
            self.lastProgress = progress*100
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //refreshTasks()
    }

    func refreshTasks() {
        statusForSurveyActivities(self.activities)
        refreshTable()

        let numActivities = CGFloat(self.activities.count)
        let completedActivities = CGFloat(self.activities.filter {
            switch $0.completionState {
            case .complete: return true
            default: return false
            }
            }.count)
        let progress = completedActivities / numActivities
        self.progressView.setProgress(progress, animated: true)
    }

    func refreshTable(){
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.progressView.setProgress(0.0, animated: false)
        super.viewDidDisappear(animated)
    }

    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        return activities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! ActivityViewTableViewCell
        let activity = activities[indexPath.row]

        cell.activityTitle?.text = activity.title
        cell.activitySubtitle?.text = activity.subtitle

        switch activity.completionState {
        case .incomplete, .partial(_, _):
            cell.activitySideBar.backgroundColor = UIColor.drOceanColor()
            cell.activityCompleted.image = UIImage(named: "emptyGlobal24X24")
        default:
            cell.activitySideBar.backgroundColor = UIColor.drDarkLimeGreenColor()
            cell.activityCompleted.image = UIImage(named: "completed24X24")
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        return cell
    }

    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let configuration = activities[indexPath.row].taskConfiguration
        if let configuration = configuration as? GlucoseReadingSelectionTask {
            let tc = GlucoseTimesTaskViewController(dataController: DatabaseController(databaseName: "glucose-log-data-store"), healthStore: sharedHealthStore, taskConfiguration: configuration)
            tc.activityController = self
            present(tc, animated: true, completion: nil)
        } else {
            let taskController = TaskController(taskConfiguration: configuration)
            taskController.delegate = self
            present(taskController, animated: true)
        }
    }

    func markActivityComplete(identifier: String) {
        if let activity = activities.first(where: { $0.identifier == identifier }) {
            activity.setComplete(forDate: currentDate) {
                DispatchQueue.main.async {
                    statusForSurveyActivities(self.activities)
                    self.refreshTable()
                    let numActivities = CGFloat(self.activities.count)
                    let completedActivities = CGFloat(self.activities.filter {
                        switch $0.completionState {
                        case .complete: return true
                        default: return false
                        }
                        }.count)
                    let progress = completedActivities / numActivities
                    self.progressView.setProgress(progress, animated: true)
                }
            }
        }
    }

    func updateDashboard(withTaskViewController tvc: ORKTaskViewController) {
        guard let task = tvc.task else { return }
        disablesAutomaticKeyboardDismissal = false
        switch task.identifier {

        case self.dailyCheckActivity.identifier:
            // Collect foot result data
            if let footResult = tvc.result
                .stepResult(forStepIdentifier: dashboardCheckFeetStep)?
                .result(forIdentifier: dashboardCheckFeetStep) as? ORKChoiceQuestionResult {
                let newValue = footResult.answer as! [NSNumber]
                DashboardTableViewController.setValue(value: newValue.first!.doubleValue, forType: .feet)
                print("New foot score: \(newValue)")
            }

            // Collect mood data
            if let moodResult = tvc.result
                .stepResult(forStepIdentifier: dashboardCheckMoodStep)?
                .result(forIdentifier: dashboardCheckMoodStep) as? ORKChoiceQuestionResult {
                let newValue = moodResult.answer as! [NSNumber]
                DashboardTableViewController.setValue(value: newValue.first!.doubleValue, forType: .mood)
            }

            // Collect eye result data

        default: break
        }
    }
}
