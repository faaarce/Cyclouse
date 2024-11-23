//
//  CyclouseButtonStack.swift
//  NKButton
//
//  Created by yoga arie on 8/23/2024.
//  Updated to remove FrameLayoutKit dependency.
//

import UIKit

public struct CyclouseButtonItem {
    public var title: String?
    public var image: UIImage?
    public var selectedImage: UIImage?
    public var userInfo: Any?
    
    public init(title: String?, image: UIImage? = nil, selectedImage: UIImage? = nil, userInfo: Any? = nil) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.userInfo = userInfo
    }
}

public enum CyclouseButtonStackSelectionMode {
    case momentary
    case singleSelection
    case multiSelection
}

public typealias CyclouseButtonCreationBlock<T> = (CyclouseButtonItem, Int) -> T
public typealias CyclouseButtonSelectionBlock<T> = (T, CyclouseButtonItem, Int) -> Void

open class CyclouseButtonStack<T: UIButton>: UIControl {
    
    open var items: [CyclouseButtonItem]? = nil {
        didSet {
            updateLayout()
            setNeedsLayout()
        }
    }
    
    public var buttons: [T] { stackView.arrangedSubviews.compactMap { $0 as? T } }
    public var firstButton: T? { buttons.first }
    public var lastButton: T? { buttons.last }
    
    open var spacing: CGFloat {
        get { stackView.spacing }
        set {
            stackView.spacing = newValue
            setNeedsLayout()
        }
    }
    
    open var contentEdgeInsets: UIEdgeInsets {
        get { stackView.layoutMargins }
        set {
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = newValue
            setNeedsLayout()
        }
    }
    
    open var cornerRadius: CGFloat = 0 {
        didSet {
            guard cornerRadius != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    /** Shadow color */
    open var shadowColor: UIColor? = nil {
        didSet {
            guard shadowColor != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    /** Shadow radius */
    open var shadowRadius: CGFloat = 0 {
        didSet {
            guard shadowRadius != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    /** Shadow opacity */
    open var shadowOpacity: Float = 0.5 {
        didSet {
            guard shadowOpacity != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    /** Shadow offset */
    open var shadowOffset: CGSize = .zero {
        didSet {
            guard shadowOffset != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    /** Border color */
    open var borderColor: UIColor? = nil {
        didSet {
            guard borderColor != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    /** Size of border */
    open var borderSize: CGFloat = 0 {
        didSet {
            guard borderSize != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    /** Border dash pattern */
    open var borderDashPattern: [NSNumber]? = nil {
        didSet {
            guard borderDashPattern != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    /** Border color */
    private var _backgroundColor: UIColor? = nil
    open override var backgroundColor: UIColor?{
        get { _backgroundColor }
        set {
            _backgroundColor = newValue
            setNeedsDisplay()
            super.backgroundColor = .clear
        }
    }
    
    open var isRounded: Bool = false {
        didSet {
            guard isRounded != oldValue else { return }
            setNeedsLayout()
        }
    }
    
    override open var frame: CGRect {
        didSet { setNeedsLayout() }
    }
    
    override open var bounds: CGRect {
        didSet { setNeedsLayout() }
    }
    
    public var selectedIndex: Int = -1 {
        didSet {
            buttons.forEach { $0.isSelected = selectedIndex == $0.tag }
        }
    }
    
    public var selectedIndexes: [Int] {
        get { buttons.filter { $0.isSelected }.map { $0.tag } }
        set { buttons.forEach { $0.isSelected = newValue.contains($0.tag) } }
    }
    
    public var axis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            stackView.axis = axis
            setNeedsLayout()
        }
    }
    
    public var selectionMode: CyclouseButtonStackSelectionMode = .singleSelection
    public var creationBlock: CyclouseButtonCreationBlock<T>? = nil
    public var configurationBlock: CyclouseButtonSelectionBlock<T>? = nil
    public var selectionBlock: CyclouseButtonSelectionBlock<T>? = nil
    
    public let stackView = UIStackView()
    
    fileprivate let shadowLayer     = CAShapeLayer()
    fileprivate let backgroundLayer = CAShapeLayer()
    
    // MARK: -
    
    convenience public init(items: [CyclouseButtonItem], axis: NSLayoutConstraint.Axis = .horizontal) {
        self.init()
        
        self.axis = axis
        self.items = items
    }
    
    public init() {
        super.init(frame: .zero)
        
        layer.addSublayer(shadowLayer)
        layer.addSublayer(backgroundLayer)
        
        stackView.spacing = 1.0
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = axis
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return stackView.systemLayoutSizeFitting(size)
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let backgroundFrame = bounds
        let fillColor       = backgroundColor
        let strokeColor     = borderColor
        let strokeSize      = borderSize
        let roundedPath     = UIBezierPath(roundedRect: backgroundFrame, cornerRadius: cornerRadius)
        let path            = roundedPath.cgPath
        
        backgroundLayer.path            = path
        backgroundLayer.fillColor       = fillColor?.cgColor
        backgroundLayer.strokeColor     = strokeColor?.cgColor
        backgroundLayer.lineWidth       = strokeSize
        backgroundLayer.miterLimit      = roundedPath.miterLimit
        backgroundLayer.lineDashPattern = borderDashPattern
        
        if let shadowColor = shadowColor {
            shadowLayer.isHidden        = false
            shadowLayer.path            = path
            shadowLayer.shadowPath      = path
            shadowLayer.fillColor       = shadowColor.cgColor
            shadowLayer.shadowColor     = shadowColor.cgColor
            shadowLayer.shadowRadius    = shadowRadius
            shadowLayer.shadowOpacity   = shadowOpacity
            shadowLayer.shadowOffset    = shadowOffset
        }
        else {
            shadowLayer.isHidden = true
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        shadowLayer.frame = bounds
        backgroundLayer.frame = bounds
        
        let viewSize = bounds.size
        
        if isRounded {
            cornerRadius = viewSize.height / 2
            setNeedsDisplay()
        }
        
        if cornerRadius > 0 {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
        else {
            layer.cornerRadius = 0
            layer.masksToBounds = false
        }
    }
    
    // MARK: -
    
    public func button(at index: Int) -> T? {
        guard index >= 0 && index < buttons.count else { return nil }
        return buttons[index]
    }
    
    open func setShadow(color: UIColor?, radius: CGFloat, opacity: Float = 1.0, offset: CGSize = .zero) {
        self.shadowColor = color
        self.shadowOpacity = opacity
        self.shadowRadius = radius
        self.shadowOffset = offset
    }
    
    @discardableResult
    public func creation(_ block: @escaping CyclouseButtonCreationBlock<T>) -> Self {
        creationBlock = block
        return self
    }
    
    @discardableResult
    public func configuration(_ block: @escaping CyclouseButtonSelectionBlock<T>) -> Self {
        configurationBlock = block
        return self
    }
    
    @discardableResult
    public func selection(_ block: @escaping CyclouseButtonSelectionBlock<T>) -> Self {
        selectionBlock = block
        return self
    }
    
    // MARK: -
    
    fileprivate func updateLayout() {
        stackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
        
        guard let buttonItems = items else {
            return
        }
        
        for (index, buttonItem) in buttonItems.enumerated() {
            let button = creationBlock?(buttonItem, index) ?? T()
            button.tag = index
            button.addTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
            
            if let configurationBlock = configurationBlock {
                configurationBlock(button , buttonItem, index)
            } else {
                button.setTitle(buttonItem.title, for: .normal)
                button.setImage(buttonItem.image, for: .normal)
                
                if buttonItem.selectedImage != nil {
                    button.setImage(buttonItem.selectedImage, for: .highlighted)
                    button.setImage(buttonItem.selectedImage, for: .selected)
                }
            }
            
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc fileprivate func onButtonSelected(_ sender: UIButton) {
        let index = sender.tag
        
        if selectionMode == .singleSelection {
            selectedIndex = index
        }
        else if selectionMode == .multiSelection {
            sender.isSelected = !sender.isSelected
        }
        
        if let item = items?[index], let button = sender as? T {
            selectionBlock?(button, item, index)
        }
        
        sendActions(for: .valueChanged)
    }
}
