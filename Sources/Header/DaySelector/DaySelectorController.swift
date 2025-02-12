import UIKit

public final class DaySelectorController: UIViewController {
    public private(set) lazy var daySelector = DaySelector()
    
    public var delegate: DaySelectorDelegate? {
        get {
          daySelector.delegate
        }
        set {
          daySelector.delegate = newValue
        }
    }
    
    public var calendar: Calendar {
        get {
          daySelector.calendar
        }
        set(newValue) {
          daySelector.calendar = newValue
        }
    }
    
    public var startDate: Date {
        get {
          daySelector.startDate
        }
        set {
          daySelector.startDate = newValue
        }
    }
    
    public var selectedIndex: Int {
        get {
          daySelector.selectedIndex
        }
        set {
          daySelector.selectedIndex = newValue
        }
    }
    
    public var selectedDate: Date? {
        get {
          daySelector.selectedDate
        }
        set {
          daySelector.selectedDate = newValue
        }
    }
    
    override public func loadView() {
        view = daySelector
    }
    
    func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
      daySelector.transitionToHorizontalSizeClass(sizeClass)
    }
    
    public func updateStyle(_ newStyle: DaySelectorStyle) {
      daySelector.updateStyle(newStyle)
    }
}


class DateDotView: UIView, DaySelectorItemProtocol {
  private var style = DaySelectorStyle()

  
  public var calendar = Calendar.autoupdatingCurrent {
      didSet {
          updateState()
      }
  }

  public var date = Date() {
      didSet {
          labelView.text = String(calendar.dateComponents([.day], from: date).day!)
          updateState()
      }
  }

  private var isToday: Bool {
      calendar.isDateInToday(date)
  }

  public var selected: Bool = false {
      didSet {
          animate()
      }
  }
  
  // A vertical stack view to hold topView and bottomView
  private let stackView: UIStackView = {
    let sv = UIStackView()
    sv.axis = .vertical
    sv.alignment = .center
    sv.distribution = .equalSpacing
    sv.spacing = 2
    sv.translatesAutoresizingMaskIntoConstraints = false
//    sv.backgroundColor = .orange
    return sv
  }()
  
  private let labelView: UILabel = {
      let label = UILabel()
//      label.backgroundColor = .green
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textAlignment = .center
      return label
  }()

  private let bottomView: UIStackView = {
      let view = UIStackView()
      view.axis = .horizontal
      view.alignment = .center
      view.spacing = 1
      view.distribution = .equalCentering
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
  }()
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
  override public var intrinsicContentSize: CGSize {
      CGSize(width: 35, height: 42)
  }
  
  
  private func setupViews() {
//          backgroundColor = .red
          isUserInteractionEnabled = true
          clipsToBounds = true
          
          // Add our main stack view
          addSubview(stackView)
          
          // Create a dot subview and give it explicit size constraints
          let dotView = UIView()
          dotView.backgroundColor = .green
          dotView.layer.cornerRadius = 2.5
          dotView.translatesAutoresizingMaskIntoConstraints = false
          
          NSLayoutConstraint.activate([
              dotView.widthAnchor.constraint(equalToConstant: 5),
              dotView.heightAnchor.constraint(equalToConstant: 5),
              labelView.heightAnchor.constraint(equalToConstant: 35),
              labelView.widthAnchor.constraint(equalToConstant: 35)
          ])
          
          // Add the dot to the horizontal stack (bottomView)
          bottomView.addArrangedSubview(dotView)
          
          // Add top and bottom subviews to the vertical stack
          stackView.addArrangedSubview(labelView)
          stackView.addArrangedSubview(bottomView)
          
          // Center and size the stack view within ourself
          NSLayoutConstraint.activate([
              stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
              stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
              stackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
              stackView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
          ])
      }
  
  private func component(component: Calendar.Component, from date: Date) -> Int {
      calendar.component(component, from: date)
  }
  
  private func isAWeekend(date: Date) -> Bool {
      let weekday = component(component: .weekday, from: date)
      if weekday == 7 || weekday == 1 {
          return true
      }
      return false
  }
  
  private func animate(){
    UIView.transition(with: self,
                      duration: 0.4,
                      options: .transitionCrossDissolve,
                      animations: {
      self.updateState()
    },
                      completion: nil)
  }

  override public func layoutSubviews() {
    labelView.layer.cornerRadius = labelView.bounds.height / 2
    labelView.clipsToBounds = true
  }
  override public func tintColorDidChange() {
      updateState()
  }
  
  public func updateStyle(_ newStyle: DaySelectorStyle) {
      style = newStyle
      updateState()
  }
  
  
  func updateState() {
    labelView.text = String(component(component: .day, from: date))
      let today = isToday
      if selected {
        labelView.font = style.todayFont
        labelView.textColor = today ? style.todayActiveTextColor : style.activeTextColor
        labelView.backgroundColor = today ? style.todayActiveBackgroundColor : style.selectedBackgroundColor
      } else {
          let notTodayColor = isAWeekend(date: date) ? style.weekendTextColor : style.inactiveTextColor
        labelView.font = style.font
        labelView.textColor = today ? style.todayInactiveTextColor : notTodayColor
        labelView.backgroundColor = style.inactiveBackgroundColor
      }
  }
}
