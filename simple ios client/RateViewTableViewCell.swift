import UIKit

class RateViewTableViewCell: UITableViewCell {

    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var activitySubtitle: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
