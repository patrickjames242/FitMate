//
//  Pins.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/29/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//


import UIKit

public protocol PinnableLayoutAnchor where Self: NSObject{}
extension NSLayoutAnchor: PinnableLayoutAnchor {}

/// The protocol both UIView and UILayoutGuide will comform to, allowing both of them to obtain the pin methods and be 'pinned' to one another.
public protocol Pinnable {

    var leadingAnchor: NSLayoutXAxisAnchor {get}
    var trailingAnchor: NSLayoutXAxisAnchor {get}
    var bottomAnchor: NSLayoutYAxisAnchor {get}
    var topAnchor: NSLayoutYAxisAnchor {get}
    var leftAnchor: NSLayoutXAxisAnchor {get}
    var rightAnchor: NSLayoutXAxisAnchor {get}
    var widthAnchor: NSLayoutDimension {get}
    var heightAnchor: NSLayoutDimension {get}
    var centerXAnchor: NSLayoutXAxisAnchor {get}
    var centerYAnchor: NSLayoutYAxisAnchor {get}
    
}

extension UIView: Pinnable {}
extension UILayoutGuide: Pinnable {}


func +(lhs: PinnableLayoutAnchor, rhs: CGFloat) -> ConstraintExpression.RightSide{
    return ConstraintExpression.RightSide(anchor: lhs, constant: rhs)
}

func +(lhs: ConstraintExpression.RightSide, rhs: CGFloat) -> ConstraintExpression.RightSide{
    return ConstraintExpression.RightSide(anchor: lhs.anchor, constant: lhs.constant.map{$0 + rhs}, multiplier: lhs.multiplier)
}

func -(lhs: PinnableLayoutAnchor, rhs: CGFloat) -> ConstraintExpression.RightSide{
    return ConstraintExpression.RightSide(anchor: lhs, constant: -rhs)
}

func -(lhs: ConstraintExpression.RightSide, rhs: CGFloat) -> ConstraintExpression.RightSide{
    return ConstraintExpression.RightSide(anchor: lhs.anchor, constant: lhs.constant.map{$0 - rhs}, multiplier: lhs.multiplier)
}

func *(lhs: CGFloat, rhs: PinnableLayoutAnchor) -> ConstraintExpression.RightSide{
    return ConstraintExpression.RightSide(anchor: rhs, multiplier: lhs)
}

func ==(lhs: ConstraintExpression.Dimension, rhs: ConstraintExpression.RightSide) -> ConstraintExpression{
    return ConstraintExpression(leftSide: lhs, rightSide: rhs, relation: .equal)
}

func ==(lhs: ConstraintExpression.Dimension, rhs: PinnableLayoutAnchor) -> ConstraintExpression{
    return ConstraintExpression(leftSide: lhs, rightSide: ConstraintExpression.RightSide(anchor: rhs), relation: .equal)
}

func ==(lhs: ConstraintExpression.Dimension, rhs: CGFloat) -> ConstraintExpression{
    return ConstraintExpression(leftSide: lhs, rightSide: ConstraintExpression.RightSide(constant: rhs), relation: .equal)
}

func >=(lhs: ConstraintExpression.Dimension, rhs: ConstraintExpression.RightSide) -> ConstraintExpression{
    return ConstraintExpression(leftSide: lhs, rightSide: rhs, relation: .greaterThanOrEqual)
}

func >=(lhs: ConstraintExpression.Dimension, rhs: PinnableLayoutAnchor) -> ConstraintExpression{
    return ConstraintExpression(leftSide: lhs, rightSide: ConstraintExpression.RightSide(anchor: rhs), relation: .greaterThanOrEqual)
}

func >=(lhs: ConstraintExpression.Dimension, rhs: CGFloat) -> ConstraintExpression{
    return ConstraintExpression(leftSide: lhs, rightSide: ConstraintExpression.RightSide(constant: rhs), relation: .greaterThanOrEqual)
}

func <=(lhs: ConstraintExpression.Dimension, rhs: ConstraintExpression.RightSide) -> ConstraintExpression{
    return ConstraintExpression(leftSide: lhs, rightSide: rhs, relation: .lessThanOrEqual)
}

func <=(lhs: ConstraintExpression.Dimension, rhs: PinnableLayoutAnchor) -> ConstraintExpression{
    return ConstraintExpression(leftSide: lhs, rightSide: ConstraintExpression.RightSide(anchor: rhs), relation: .lessThanOrEqual)
}

func <=(lhs: ConstraintExpression.Dimension, rhs: CGFloat) -> ConstraintExpression{
    return ConstraintExpression(leftSide: lhs, rightSide: ConstraintExpression.RightSide(constant: rhs), relation: .lessThanOrEqual)
}


precedencegroup LayoutPriorityPrecedence {
    lowerThan: TernaryPrecedence
    higherThan: AssignmentPrecedence
    associativity: left
    assignment: false
}

infix operator <!!>: LayoutPriorityPrecedence

// adds a custom layout priority to the constraint
func <!!>(lhs: ConstraintExpression, rhs: UILayoutPriority) -> ConstraintExpression{
    return ConstraintExpression(leftSide: lhs.leftSide, rightSide: lhs.rightSide, relation: lhs.relation, priority: rhs)
}






struct ConstraintExpression: Hashable{
    
    enum Dimension: Hashable{
        case leading
        case trailing
        case left
        case right
        case centerX
        case centerY
        case top
        case bottom
        case height
        case width
    }
    
    enum Relation: Hashable{
        case equal, greaterThanOrEqual, lessThanOrEqual
    }
    
    struct RightSide{
        
        let anchor: PinnableLayoutAnchor?
        let constant: CGFloat?
        let multiplier: CGFloat?

        init(anchor: PinnableLayoutAnchor? = nil,
             constant: CGFloat? = nil,
             multiplier: CGFloat? = nil){
            self.anchor = anchor
            self.constant = constant
            self.multiplier = multiplier
        }
    }

    let leftSide: Dimension
    let rightSide: RightSide
    let relation: Relation
    let priority: UILayoutPriority?
    
    fileprivate init(leftSide: Dimension, rightSide: RightSide, relation: Relation, priority: UILayoutPriority? = nil){
        self.leftSide = leftSide; self.rightSide = rightSide; self.relation = relation; self.priority = priority
    }
    
    init(dimension: Dimension, relation: Relation, anchor: PinnableLayoutAnchor? = nil, constant: CGFloat? = nil, multiplier: CGFloat? = nil, priority: UILayoutPriority? = nil){
        self.leftSide = dimension
        self.rightSide = RightSide(anchor: anchor, constant: constant, multiplier: multiplier)
        self.relation = relation
        self.priority = priority
    }
}

extension ConstraintExpression.RightSide: Hashable{
    
    static func == (lhs: ConstraintExpression.RightSide, rhs: ConstraintExpression.RightSide) -> Bool {
        let anchorsAreEqual: Bool = {
            let optionalityIsEqual = (lhs.anchor == nil && rhs.anchor == nil) ||
                (lhs.anchor != nil && rhs.anchor != nil)
            return optionalityIsEqual && lhs.anchor?.isEqual(rhs.anchor) ?? true
        }()
        return
            anchorsAreEqual &&
            lhs.constant == rhs.constant &&
            lhs.multiplier == rhs.multiplier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(anchor as NSObject?)
        hasher.combine(constant)
        hasher.combine(multiplier)
    }
}



extension Pinnable{

    /// Adds the current instance to the view, whether it is a UILayoutGuide or another view.
    private func addMyselfTo(view: UIView){
        if let v = self as? UIView{
            view.addSubview(v)
        }
        if let lg = self as? UILayoutGuide{
            view.addLayoutGuide(lg)
        }
    }
    
    @discardableResult func pinAllSides(addTo addToView: UIView? = nil, pinTo pinToView: Pinnable, file: StaticString = #file, line: UInt = #line) -> Pins{
        return self._pinAllSides(addTo: addToView, pinTo: pinToView, insets: .zero, activate: true, file: file, line: line)
    }
    
    @discardableResult func pinAllSides(addTo addToView: UIView? = nil, pinTo pinToView: Pinnable, insets: UIEdgeInsets = .zero, file: StaticString = #file, line: UInt = #line) -> Pins{
        return self._pinAllSides(addTo: addToView, pinTo: pinToView, insets: insets, activate: true, file: file, line: line)
    }
    
    @discardableResult func pinAllSides(addTo addToView: UIView? = nil, pinTo pinToView: Pinnable, activate: Bool, file: StaticString = #file, line: UInt = #line) -> Pins{
        return self._pinAllSides(addTo: addToView, pinTo: pinToView, insets: .zero, activate: activate, file: file, line: line)
    }
    
    @discardableResult func pinAllSides(addTo addToView: UIView? = nil, pinTo pinToView: Pinnable, insets: UIEdgeInsets, activate: Bool, file: StaticString = #file, line: UInt = #line) -> Pins{
        return self._pinAllSides(addTo: addToView, pinTo: pinToView, insets: insets, activate: activate, file: file, line: line)
    }
    
    private func _pinAllSides(addTo addToView: UIView?, pinTo pinToView: Pinnable, insets: UIEdgeInsets, activate: Bool, file: StaticString, line: UInt) -> Pins{
        return self._pin(view: addToView, expressions: [.left == pinToView.leftAnchor + insets.left, .right == pinToView.rightAnchor - insets.right, .top == pinToView.topAnchor + insets.top, .bottom == pinToView.bottomAnchor - insets.bottom], activate: activate, file: file, line: line)
    }
    
    @discardableResult func pin(addTo view: UIView? = nil, _ expressions: ConstraintExpression..., file: StaticString = #file, line: UInt = #line) -> Pins{
        return self._pin(view: view, expressions: expressions, activate: true, file: file, line: line)
    }
    
    @discardableResult func pin(addTo view: UIView? = nil, _ expressions: ConstraintExpression..., activate: Bool, file: StaticString = #file, line: UInt = #line) -> Pins{
        return self._pin(view: view, expressions: expressions, activate: activate, file: file, line: line)
    }
    
    private func _pin(view: UIView?, expressions: [ConstraintExpression], activate: Bool, file: StaticString, line: UInt) -> Pins{
        view.map{addMyselfTo(view: $0)}

        if let view = self as? UIView{
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let pinSetter = PinSetter(currentView: self, file: file, line: line)
        
        var constraintDict = [ConstraintExpression: [NSLayoutConstraint]]()
        
        // we convert it to a set to remove any duplicates
        for expression in Set(expressions){
            let constraint = pinSetter.getConstraintFor(expression: expression)
            
            if let priority = expression.priority{
                constraint.priority = priority
            }
            
            if var array = constraintDict[expression]{
                array.append(constraint)
                constraintDict[expression] = array
            } else {
                constraintDict[expression] = [constraint]
            }
        }
        
        let pins = Pins(constraintDict: constraintDict)
        if activate{
            pins.activateAll()
        }
        return pins
    }

    
    
}




private class PinSetter{
    
    private static let defaultConstant: CGFloat = 0
    private static let defaultMultiplier: CGFloat = 1
    
    private let file: StaticString
    private let line: UInt
    private let currentView: Pinnable
    
    init(currentView: Pinnable, file: StaticString, line: UInt){
        self.currentView = currentView
        self.file = file
        self.line = line
    }
    
    func getConstraintFor(expression: ConstraintExpression) -> NSLayoutConstraint{
        let function = getAppropriateConstraintFunctionFor(dimension: expression.leftSide)
        return function(expression)
    }
    
    private func throwFatalError(message: String) -> Never{
        return fatalError(message, file: self.file, line: self.line)
    }
    
    private func throwAnchorMismatchError(anchorType: String) -> Never{
        return throwFatalError(message: "You are trying to constrain an \(anchorType) to another anchor of a different type")
    }
    
    private func throwAnchorRequiredError(anchorType: String) -> Never{
        return throwFatalError(message: "Pinning an \(anchorType) requires another anchor to pin it to")
    }
    
    private func throwMultiplierHasNoEffectError() -> Never{
        return throwFatalError(message: "Multipliers have no effect when setting constraints on NSLayoutXAxisAnchors and NSLayoutYAxisAnchors")
    }
    
    private func getAppropriateConstraintFunctionFor(dimension: ConstraintExpression.Dimension) -> (_ expression: ConstraintExpression) -> NSLayoutConstraint{
        switch dimension{
        case .leading, .trailing, .left, .right, .centerX:
            return setXAxisConstraint(expression:)
        case .top, .bottom, .centerY:
            return setYAxisConstraint(expression:)
        case .height, .width:
            return setLayoutDimensionConstraint(expression:)
        }
    }
    
    private func setXAxisConstraint(expression: ConstraintExpression) -> NSLayoutConstraint{
        let anchorType = "NSLayoutXAxisAnchor"
        guard expression.rightSide.anchor != nil else {
            throwAnchorRequiredError(anchorType: anchorType)
        }
        guard expression.rightSide.multiplier == nil else {
            throwMultiplierHasNoEffectError()
        }
        guard let anchor2 = expression.rightSide.anchor as? NSLayoutXAxisAnchor else {
            throwAnchorMismatchError(anchorType: anchorType)
        }
        let anchor1 = currentViewsAnchorFor(dimension: expression.leftSide) as! NSLayoutXAxisAnchor
        let constraintFunction: (NSLayoutAnchor<NSLayoutXAxisAnchor>, CGFloat) -> NSLayoutConstraint = {
            switch expression.relation{
            case .equal: return anchor1.constraint(equalTo:constant:)
            case .greaterThanOrEqual: return anchor1.constraint(greaterThanOrEqualTo:constant:)
            case .lessThanOrEqual: return anchor1.constraint(lessThanOrEqualTo:constant:)
            }
        }()
        return constraintFunction(anchor2, expression.rightSide.constant ?? PinSetter.defaultConstant)
    }
    
    private func setYAxisConstraint(expression: ConstraintExpression) -> NSLayoutConstraint{
        let anchorType = "NSLayoutYAxisAnchor"
        guard expression.rightSide.anchor != nil else {
            throwAnchorRequiredError(anchorType: anchorType)
        }
        guard expression.rightSide.multiplier == nil else {
            throwMultiplierHasNoEffectError()
        }
        guard let anchor2 = expression.rightSide.anchor as? NSLayoutYAxisAnchor else {
            throwAnchorMismatchError(anchorType: anchorType)
        }
        let anchor1 = currentViewsAnchorFor(dimension: expression.leftSide) as! NSLayoutYAxisAnchor
        let constraintFunction: (NSLayoutAnchor<NSLayoutYAxisAnchor>, CGFloat) -> NSLayoutConstraint = {
            switch expression.relation{
            case .equal: return anchor1.constraint(equalTo:constant:)
            case .greaterThanOrEqual: return anchor1.constraint(greaterThanOrEqualTo:constant:)
            case .lessThanOrEqual: return anchor1.constraint(lessThanOrEqualTo:constant:)
            }
        }()
        return constraintFunction(anchor2, expression.rightSide.constant ?? PinSetter.defaultConstant)
    }
    
    private func setLayoutDimensionConstraint(expression: ConstraintExpression) -> NSLayoutConstraint{
        let anchor1 = currentViewsAnchorFor(dimension: expression.leftSide) as! NSLayoutDimension
        if expression.rightSide.anchor == nil{
            let constraintFunction: (CGFloat) -> NSLayoutConstraint = {
                switch expression.relation{
                case .equal: return anchor1.constraint(equalToConstant:)
                case .greaterThanOrEqual: return anchor1.constraint(greaterThanOrEqualToConstant:)
                case .lessThanOrEqual: return anchor1.constraint(lessThanOrEqualToConstant:)
                }
            }()
            return constraintFunction(expression.rightSide.constant ?? PinSetter.defaultConstant)
        } else if let anchor2 = expression.rightSide.anchor as? NSLayoutDimension{
            let constraintFunction: (NSLayoutDimension, _ multiplier: CGFloat, _ constant: CGFloat) -> NSLayoutConstraint = {
                switch expression.relation{
                case .equal: return anchor1.constraint(equalTo:multiplier:constant:)
                case .greaterThanOrEqual: return anchor1.constraint(greaterThanOrEqualTo:multiplier:constant:)
                case .lessThanOrEqual: return anchor1.constraint(lessThanOrEqualTo:multiplier:constant:)
                }
            }()
            return constraintFunction(anchor2, expression.rightSide.multiplier ?? PinSetter.defaultMultiplier, expression.rightSide.constant ?? PinSetter.defaultConstant)
        } else {
            throwAnchorMismatchError(anchorType: "NSLayoutDimension")
        }
    }
    
    private func currentViewsAnchorFor(dimension: ConstraintExpression.Dimension) -> AnyObject{
        let c = currentView
        switch dimension{
        case .leading: return c.leadingAnchor
        case .trailing: return c.trailingAnchor
        case .left: return c.leftAnchor
        case .right: return c.rightAnchor
        case .centerX: return c.centerXAnchor
        case .centerY: return c.centerYAnchor
        case .top: return c.topAnchor
        case .bottom: return c.bottomAnchor
        case .height: return c.heightAnchor
        case .width: return c.widthAnchor
        }
    }

}


struct Pins{
    
    private let constraintDict: [ConstraintExpression: [NSLayoutConstraint]]
    
    fileprivate init(constraintDict: [ConstraintExpression: [NSLayoutConstraint]]){
        self.constraintDict = constraintDict
    }
    
    func constraintFor(expression: ConstraintExpression) -> NSLayoutConstraint?{
        return constraintDict[expression]?.first
    }
    
    func constraintsFor(expression: ConstraintExpression) -> [NSLayoutConstraint]{
        return constraintDict[expression] ?? []
    }
    
    func constraintFor(dimension: ConstraintExpression.Dimension) -> NSLayoutConstraint?{
        return constraintDict.first{$0.key.leftSide == dimension}?.value.first
    }
    
    func constraintsFor(dimension: ConstraintExpression.Dimension) -> [NSLayoutConstraint]{
        return constraintDict.filter{$0.key.leftSide == dimension}.flatMap{$0.value}
    }
    
    func getAll() -> [NSLayoutConstraint]{
        return constraintDict.values.flatMap{$0}
    }
    
    func activateAll(){
        iterateOverAll{$0.isActive = true}
    }
    
    func deactivateAll(){
        iterateOverAll{$0.isActive = false}
    }
    
    private func iterateOverAll(action: (NSLayoutConstraint) -> ()){
        for array in constraintDict.values{
            array.forEach{action($0)}
        }
    }
    
}

extension Pins: Sequence{
    typealias Iterator = Array<NSLayoutConstraint>.Iterator
    __consuming func makeIterator() -> Iterator {
        return getAll().makeIterator()
    }
}

