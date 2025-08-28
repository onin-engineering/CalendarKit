import UIKit

public protocol DaySelectorItemProtocol: UIView {
  var date: Date {get set}
  var selected: Bool {get set}
  var calendar: Calendar {get set}
  var events: [any EventDescriptor] { get set }
  
  func updateStyle(_ newStyle: DaySelectorStyle)
}

public protocol DaySelectorDelegate: AnyObject {
  func dateSelectorDidSelectDate(_ date: Date)
}

public final class DaySelector: UIView {
  public weak var delegate: DaySelectorDelegate?
  public weak var dataSource: EventDataSource? {
    didSet {
      configureDotEvents()
    }
  }
  
  func configureDotEvents() {
    if items.isEmpty { return }
    
    for (index, view) in items.enumerated() {
      let dayOffset = index
      let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate ?? Date()) ?? Date()
      let events = dataSource?.eventsForDate(date) ?? []
      view.events = events
    }
  }
  
  public func reloadData() {
    configureDotEvents()
  }
  
  public var calendar = Calendar.autoupdatingCurrent {
    didSet {
      updateItemsCalendar()
    }
  }
  
  private func updateItemsCalendar() {
    items.forEach { (item) in
      item.calendar = calendar
    }
  }
  
  private var style = DaySelectorStyle()
  
  private var daysInWeek = 7
  public var startDate: Date! {
    didSet {
      configure()
    }
  }
  
  public var selectedIndex = -1 {
    didSet {
      items.filter {$0.selected == true}
        .first?.selected = false
      if selectedIndex < items.count && selectedIndex > -1 {
        let label = items[selectedIndex]
        label.selected = true
      }
    }
  }
  
  public var selectedDate: Date? {
    get {
      items.filter{$0.selected == true}.first?.date as Date?
    }
    set(newDate) {
      if let newDate {
        selectedIndex = calendar.dateComponents([.day], from: startDate, to: newDate).day!
      }
    }
  }
  
  private var items = [UIView & DaySelectorItemProtocol]()
  
  public init(startDate: Date = Date(), daysInWeek: Int = 7) {
    self.startDate = startDate.dateOnly(calendar: calendar)
    self.daysInWeek = daysInWeek
    super.init(frame: CGRect.zero)
    initializeViews(viewType: DateDotView.self)
    configure()
  }
  
  override public init(frame: CGRect) {
    startDate = Date().dateOnly(calendar: calendar)
    super.init(frame: frame)
    initializeViews(viewType: DateDotView.self)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    startDate = Date().dateOnly(calendar: calendar)
    super.init(coder: aDecoder)
    initializeViews(viewType: DateDotView.self)
  }
  
  private func initializeViews<T: DaySelectorItemProtocol>(viewType: T.Type) where T: DaySelectorItemProtocol {
    // Store last selected date
    let lastSelectedDate = selectedDate
    // Remove previous Items
    items.forEach{$0.removeFromSuperview()}
    items.removeAll()
    
    // Create new with corresponding class
    for _ in 1...daysInWeek {
      let view = T()
      items.append(view)
      addSubview(view)
      
      let recognizer = UITapGestureRecognizer(target: self,
                                              action: #selector(DaySelector.dateLabelDidTap(_:)))
      view.addGestureRecognizer(recognizer)
    }
    configure()
    updateItemsCalendar()
    // Restore last date
    selectedDate = lastSelectedDate
  }
  
  private func configure() {
    for (increment, label) in items.enumerated() {
      label.date = calendar.date(byAdding: .day, value: increment, to: startDate)!
    }
  }
  
  public func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle
    items.forEach{$0.updateStyle(style)}
  }
  
  public func prepareForReuse() {
    items.forEach {$0.selected = false}
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    let itemCount = Double(items.count)
    let size = items.first?.intrinsicContentSize ?? .zero
    
    let parentWidth = bounds.size.width
    
    var per = parentWidth - size.width * itemCount
    per /= itemCount
    let minX = per / 2
    
    for (i, item) in items.enumerated() {
      
      var x = minX + (size.width + per) * Double(i)
      
      let rightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
      if rightToLeft {
        x = parentWidth - x - size.width
      }
      
      let origin = CGPoint(x: x,
                           y: 0)
      let frame = CGRect(origin: origin,
                         size: size)
      item.frame = frame
    }
  }
  
  public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    switch sizeClass {
    case .regular:
      initializeViews(viewType: DayDateCell.self)
    default:
      initializeViews(viewType: DateDotView.self)
    }
  }
  
  @objc private func dateLabelDidTap(_ sender: UITapGestureRecognizer) {
    if let item = sender.view as? DaySelectorItemProtocol {
      delegate?.dateSelectorDidSelectDate(item.date)
    }
  }
}


protocol DayCellProtocol: UIView {
  var events: [any EventDescriptor] { get set }
}


// ---------------------------
// ---------------------------
// ---------------------------
// ---------------------------


class DateDotView: UIView, DaySelectorItemProtocol {
  private var style = DaySelectorStyle()
  private let dotHeight = 5.0
  
  public var events: [any EventDescriptor] = [] {
    didSet {
      addDotsToView()
    }
  }
  
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
    sv.distribution = .fillProportionally
    sv.spacing = 2
    sv.translatesAutoresizingMaskIntoConstraints = false
    return sv
  }()
  
  private let labelView: UILabel = {
    let label = UILabel()
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
    isUserInteractionEnabled = true
    clipsToBounds = true
    
    addSubview(stackView)
    NSLayoutConstraint.activate([
      labelView.heightAnchor.constraint(equalToConstant: 35),
      labelView.widthAnchor.constraint(equalToConstant: 35),
      bottomView.heightAnchor.constraint(equalToConstant: dotHeight),
    ])
    
    // Add the dot to the horizontal stack (bottomView)
    
    
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
    // FIXME: Hardcoding this since labelView has no frame height?
    labelView.layer.cornerRadius = 35 / 2
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
  
  
  private func addDotsToView() {
    // Clear old dots
    bottomView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    // We'll track unique colors in order
    var seenColors: [UIColor] = []
    
    // Loop once over events
    for event in events {
      // Stop if we already have 3 unique colors
      if seenColors.count == 3 { break }
      
      // Only act if it's a new color
      if !seenColors.contains(event.color) {
        seenColors.append(event.color)
        
        // Create dot for this new color
        let dotView = UIView()
        dotView.backgroundColor = event.color
        dotView.layer.cornerRadius = dotHeight / 2
        dotView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          dotView.widthAnchor.constraint(equalToConstant: dotHeight),
          dotView.heightAnchor.constraint(equalToConstant: dotHeight)
        ])
        
        bottomView.addArrangedSubview(dotView)
      }
    }
  }
}

