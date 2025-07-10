//
//  UIView+Constraints.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import Foundation
import UIKit

extension UIView {
    func addSubViews(_ views: [UIView]) {
        views.forEach { subView in
            addSubview(subView)
        }
    }
}

@resultBuilder public struct LayoutBuilder {
    public static func buildBlock(_ content: Any?...) -> [Any?] {
        return content
    }
}

public extension NSLayoutConstraint {
    static func activate(@LayoutBuilder content: () -> [Any?]) {
        let values = content()
        activate(values)
    }
    
    static func activate(_ content: [Any?]) {
        for value in content {
            if let constraint = value as? NSLayoutConstraint {
                constraint.isActive = true
            } else if let constraints = value as? [Any?] {
                activate(constraints)
            }
        }
    }
}

public extension UIView {
    @discardableResult
    func size(height: CGFloat, width: CGFloat) -> Self {
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        return self
    }
    
    
    @discardableResult
    func fillContainer(in view: UIView, constant: CGFloat = 0) -> Self {
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: constant).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func top(_ anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) -> Self {
        self.topAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func bottom(_ anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) -> Self {
        self.bottomAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func leading(_ anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) -> Self {
        self.leadingAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func trailing(_ anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) -> Self {
        self.trailingAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func centerX(_ anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) -> Self {
        self.centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func centerY(_ anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) -> Self {
        self.centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func height(
        _ constant: CGFloat
    ) -> Self {
        self.heightAnchor
            .constraint(equalToConstant: constant)
            .isActive = true
        return self
    }
    
    @discardableResult
    func heightMutipler(
        _ anchor: NSLayoutDimension,
        constant: CGFloat = 0,
        multiplier: CGFloat = 1
    ) -> Self {
        self.heightAnchor
            .constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
            .isActive = true
        return self
    }
    
    @discardableResult
    func widthMutipler(
        _ anchor: NSLayoutDimension,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0
    ) -> Self {
        self.widthAnchor.constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
            .isActive = true
        return self
    }
    
    @discardableResult
    func width(
        _ constant: CGFloat
    ) -> Self {
        self.widthAnchor.constraint(equalToConstant: constant)
            .isActive = true
        return self
    }
}

public extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
    
    func with(priority: Float) -> NSLayoutConstraint {
        self.priority = .init(priority)
        return self
    }
}

extension UIView {
    public func constraints(
        insideOrEqualSafeAreaOf otherView: UIView,
        edges: UIRectEdge,
        constant: CGFloat) -> [NSLayoutConstraint] {
            var constraints: [NSLayoutConstraint] = []
            if edges.contains(.top) {
                constraints += [
                    self.topAnchor.constraint(
                        greaterThanOrEqualTo: otherView.topAnchor, constant: constant),
                    self.topAnchor.constraint(
                        greaterThanOrEqualTo: otherView.safeAreaLayoutGuide.topAnchor),
                    self.topAnchor.constraint(
                        equalTo: otherView.safeAreaLayoutGuide.topAnchor)
                    .with(priority: .defaultLow)
                ]
            }
            if edges.contains(.bottom) {
                constraints += [
                    self.bottomAnchor.constraint(
                        lessThanOrEqualTo: otherView.bottomAnchor, constant: -constant),
                    
                    self.bottomAnchor.constraint(
                        lessThanOrEqualTo: otherView.safeAreaLayoutGuide.bottomAnchor),
                    
                    self.bottomAnchor.constraint(
                        equalTo: otherView.safeAreaLayoutGuide.bottomAnchor)
                    .with(priority: .defaultLow)
                ]
            }
            if edges.contains(.left) {
                constraints += [
                    self.leadingAnchor.constraint(
                        greaterThanOrEqualTo: otherView.leadingAnchor, constant: constant),
                    
                    self.leadingAnchor.constraint(
                        greaterThanOrEqualTo: otherView.safeAreaLayoutGuide.leadingAnchor),
                    
                    self.leadingAnchor.constraint(
                        equalTo: otherView.safeAreaLayoutGuide.leadingAnchor)
                    .with(priority: .defaultLow)
                ]
            }
            if edges.contains(.right) {
                constraints += [
                    self.trailingAnchor.constraint(
                        lessThanOrEqualTo: otherView.trailingAnchor, constant: -constant),
                    
                    self.trailingAnchor.constraint(
                        lessThanOrEqualTo: otherView.safeAreaLayoutGuide.trailingAnchor),
                    
                    self.trailingAnchor.constraint(
                        equalTo: otherView.safeAreaLayoutGuide.trailingAnchor)
                    .with(priority: .defaultLow)
                ]
            }
            
            return constraints
        }
}
