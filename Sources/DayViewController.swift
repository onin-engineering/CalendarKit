import UIKit

open class DayViewController: UIViewController, EventDataSource, DayViewDelegate {
  public var initialDate: Date = Date()
  let tomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
  public lazy var dayView: CalendarDayView  = CalendarDayView(initialDate: initialDate)

    public var dataSource: EventDataSource? {
        get {
            dayView.dataSource
        }
        set(value) {
            dayView.dataSource = value
        }
    }

    public var delegate: DayViewDelegate? {
        get {
            dayView.delegate
        }
        set(value) {
            dayView.delegate = value
        }
    }
  
  public func setInitialDate(_ date: Date) {
//    dayView.setInitialDate(date)
  }
  
//  public var selectedDate = Date() {
//    didSet {
//      for client in clients {
//        client.move(from: selectedDate, to: selectedDate)
//      }
//    }
//  }

    public var calendar = Calendar.autoupdatingCurrent {
        didSet {
            dayView.calendar = calendar
        }
    }

    public var eventEditingSnappingBehavior: EventEditingSnappingBehavior {
        get {
            dayView.eventEditingSnappingBehavior
        }
        set {
            dayView.eventEditingSnappingBehavior = newValue
        }
    }

    open override func loadView() {
        view = dayView
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.tintColor = SystemColors.systemRed
        dataSource = self
        delegate = self
        dayView.reloadData()

        let sizeClass = traitCollection.horizontalSizeClass
        configureDayViewLayoutForHorizontalSizeClass(sizeClass)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dayView.scrollToFirstEventIfNeeded()
    }

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        configureDayViewLayoutForHorizontalSizeClass(newCollection.horizontalSizeClass)
    }

    open func configureDayViewLayoutForHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
        dayView.transitionToHorizontalSizeClass(sizeClass)
    }

    // MARK: - CalendarKit API

    open func move(to date: Date) {
        dayView.move(to: date)
    }

    open func reloadData() {
        dayView.reloadData()
    }

    open func updateStyle(_ newStyle: CalendarStyle) {
        dayView.updateStyle(newStyle)
    }

    open func eventsForDate(_ date: Date) -> [EventDescriptor] {
        [Event]()
    }

    // MARK: - DayViewDelegate

    open func dayViewDidSelectEventView(_ eventView: EventView) {}
    open func dayViewDidLongPressEventView(_ eventView: EventView) {}

    open func dayView(dayView: CalendarDayView, didTapTimelineAt date: Date) {}
    open func dayViewDidBeginDragging(dayView: CalendarDayView) {}
    open func dayViewDidTransitionCancel(dayView: CalendarDayView) {}

    open func dayView(dayView: CalendarDayView, willMoveTo date: Date) {}
    open func dayView(didMoveTo date: Date) {}

    open func dayView(dayView: CalendarDayView, didLongPressTimelineAt date: Date) {}
    open func dayView(dayView: CalendarDayView, didUpdate event: EventDescriptor) {}

    // MARK: - Editing

    open func create(event: EventDescriptor, animated: Bool = false) {
        dayView.create(event: event, animated: animated)
    }

    open func beginEditing(event: EventDescriptor, animated: Bool = false) {
        dayView.beginEditing(event: event, animated: animated)
    }

    open func endEventEditing() {
        dayView.endEventEditing()
    }
}
