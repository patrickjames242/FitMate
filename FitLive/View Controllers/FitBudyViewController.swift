//
//  FitBudyViewController.swift
//  FitLive
//
//  Created by Akeil S on 5/30/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit
import FirebaseFirestore

class FitBudyViewController: UIViewController {
    
	static func getNew() -> UIViewController{
		return UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "FitBuddiesVC")
	}
	
    @IBOutlet weak var tableView: UITableView!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.modalPresentationStyle = .fullScreen
	}
	
	private let cellID = "BUDDY_CELL"
	
	var buddies = [Networking.User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		tableView.dataSource = self
        tableView.delegate = self
		tableView.register(BuddyTableViewCell.self, forCellReuseIdentifier: cellID)
		tableView.delaysContentTouches = false
		tableView.allowsSelection = false
		tableView.rowHeight = 120
		
		setUpUsersObserver()
		setUpCallingObserver()
    }
	
	private func setUpUsersObserver(){
		var listener: ListenerRegistration?
		
		listener = Networking.Firebase.observeUsers {[weak self] newUsers in
			guard let self = self else {
				listener?.remove()
				return
			}
			self.buddies = newUsers.filter({$0.firebaseID != CurrentUserManager.currentUser?.firebaseID})
			self.tableView.reloadData()
		}
	}
	
	
	
	private func setUpCallingObserver(){
		
		func topMostViewController(on vc: UIViewController) -> UIViewController{
			if let parent = vc.presentedViewController{
				return topMostViewController(on: parent)
			} else {
				return vc
			}
		}
		
		LiveChatBrain.default.someoneIsTryingToCallTheUserNotification.listen(sender: self) {[weak self] in
			guard let self = self else {return}
			let presenter = topMostViewController(on: self)
			
			let alert = UIAlertController(title: "Incoming Call", message: "Someone is trying to call you", preferredStyle: .alert)
			let decline = UIAlertAction(title: "Decline", style: .destructive) { _ in
				LiveChatBrain.default.rejectCall()
			}
			
			let accept = UIAlertAction(title: "Accept", style: .default) { action in
				LiveChatBrain.default.acceptCall()
				self.present(VideoChatViewController(personBeingCalled: nil), animated: true)
			}
			
			[decline, accept].forEach{alert.addAction($0)}
			
			
			presenter.present(alert, animated: true)
			
			
		}
	}
	
    
	
}

extension FitBudyViewController: BuddyTableViewCellDelegate{
	
	func userWantsToCallPerson(person: Networking.User) {
		LiveChatBrain.default.callUser(userId: person.quickBoxId)
		let viewController = VideoChatViewController(personBeingCalled: person)
		self.present(viewController, animated: true)
	}

}


extension FitBudyViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BuddyTableViewCell
		let item = buddies[indexPath.row]
		cell.updateWith(user: item)
		cell.delegate = self
        return cell
    }
    
}



extension FitBudyViewController: UITableViewDelegate{

}




protocol BuddyTableViewCellDelegate: class{
	func userWantsToCallPerson(person: Networking.User)
}



private class BuddyTableViewCell: UITableViewCell{
	
	weak var delegate: BuddyTableViewCellDelegate?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let sides: CGFloat = 20
		stackViewHolder.pinAllSides(addTo: contentView, pinTo: contentView, insets: UIEdgeInsets(top: sides / 2, left: sides, bottom: sides / 2, right: sides), activate: false).forEach{$0.priority = UILayoutPriority(999); $0.isActive = true}
		
	}
	
	private var currentUser: Networking.User?
	
	func updateWith(user: Networking.User){
		self.currentUser = user
		self.nameLabel.text = user.displayName
		self.usernameLabel.text = "@" + user.username
	}
	
	private lazy var stackViewHolder: UIView = {
		let x = UIView()
		let padding: CGFloat = 20
		horizontalStackView.pinAllSides(addTo: x, pinTo: x, insets: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
		x.layer.borderWidth = 1
		x.layer.borderColor = CustomColors.aqua.cgColor
		x.layer.cornerRadius = 10
		x.layer.masksToBounds = true
		return x
	}()
	
	private lazy var horizontalStackView: UIStackView = {
		let x = UIStackView(arrangedSubviews: [customImageView, labelStackView, workoutNowButton])
		x.axis = .horizontal
		x.alignment = .center
		x.spacing = 10
		return x
	}()

	private lazy var customImageView: UIImageView = {
		let x = UIImageView(image: UIImage(named: "_96A3290")!)
		x.contentMode = .scaleAspectFill
		let size: CGFloat = 63
		x.pin(.height == 63, .width == 63)
		x.layer.cornerRadius = size / 2
		x.layer.masksToBounds = true
		return x
	}()
	
	private lazy var labelStackView: UIStackView = {
		let x = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
		x.axis = .vertical
		x.spacing = 3
		x.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		x.setContentHuggingPriority(.defaultLow, for: .horizontal)
		return x
	}()
	
	private lazy var nameLabel: UILabel = {
		let x = UILabel()
		x.font = ThemeFont.regular.getUIFont(size: 17)
		x.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		return x
	}()
	
	private lazy var usernameLabel: UILabel = {
		let x = UILabel()
		x.font = ThemeFont.regular.getUIFont(size: 13)
		x.textColor = UIColor.lightGray
		x.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		return x
	}()
	
	private lazy var workoutNowButton: UIButton = {
		let x = UIButton(type: .system)
		x.setAttributedTitle(NSAttributedString(string: "Workout Now", attributes: [.font: ThemeFont.regular.getUIFont(size: 14), .foregroundColor: UIColor.white]), for: .normal)
		x.backgroundColor = UIColor(red: 0/255, green: 198/255, blue: 149/255, alpha: 1)
		x.layer.cornerRadius = 10
		x.layer.masksToBounds = true
		x.pin(.height == 30)
		x.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		x.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		x.contentEdgeInsets.left = 10
		x.contentEdgeInsets.right = 10
		x.addTarget(self, action: #selector(respondToWorkOutNowButtonPressed), for: .touchUpInside)
		return x
	}()
	
	@objc private func respondToWorkOutNowButtonPressed(){
		guard let user = self.currentUser else {return}
		delegate?.userWantsToCallPerson(person: user)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder has not being implemented")
	}
	
}






