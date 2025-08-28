import UIKit

open class DayViewController: UIViewController, EventDataSource, DayViewDelegate {
  public var initialDate: Date = Date()

  public lazy var dayView: CKDayView  = CKDayView(initialDate: initialDate)

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

    open func dayView(dayView: CKDayView, didTapTimelineAt date: Date) {}
    open func dayViewDidBeginDragging(dayView: CKDayView) {}
    open func dayViewDidTransitionCancel(dayView: CKDayView) {}

    open func dayView(dayView: CKDayView, willMoveTo date: Date) {}
    open func dayView(dayView: CKDayView, didMoveTo date: Date) {}

    open func dayView(dayView: CKDayView, didLongPressTimelineAt date: Date) {}
    open func dayView(dayView: CKDayView, didUpdate event: EventDescriptor) {}

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
