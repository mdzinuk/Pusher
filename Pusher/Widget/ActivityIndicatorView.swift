//
//  ActivityIndicatorView.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 4/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import Cocoa
import SwiftUI

struct ActivityIndicatorView: NSViewRepresentable {
    typealias NSViewType = ActivityView
    func makeNSView(context: NSViewRepresentableContext<ActivityIndicatorView>) -> ActivityView {
        let nsView = ActivityView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100)))
        nsView.startAnimating()
        return nsView
    }
    func updateNSView(_ nsView: ActivityView, context: NSViewRepresentableContext<ActivityIndicatorView>) { }
}


protocol ActivityIndicatorAnimationDelegate {
    func setUpAnimation(in layer:CALayer, size: CGSize, color: NSColor)
}
internal enum IndicatorType: Int {
    case circleRipple
    func animation() -> ActivityIndicatorAnimationDelegate {
        return CircleScaleRippleMultiple()
    }
}

enum Circle {
    static func layerWith(size: CGSize, color: NSColor) -> CALayer {
        let layer: CAShapeLayer = CAShapeLayer()
        let path: NSBezierPath = NSBezierPath()
        let lineWidth: CGFloat = 1
        path.appendArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                       radius: size.width / 2,
                       startAngle: 0,
                       endAngle: 360,
                       clockwise: false);
        layer.fillColor = NSColor.orange.withAlphaComponent(0.6).cgColor
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
        layer.backgroundColor = nil
        layer.path = CGPathFromNSBezierPath(nsPath: path)
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return layer
    }
    static func CGPathFromNSBezierPath(nsPath: NSBezierPath) -> CGPath! {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< nsPath.elementCount {
            let type = nsPath.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .lineTo: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .curveTo: path.addCurve(to: CGPoint(x: points[2].x, y: points[2].y),
                                         control1: CGPoint(x: points[0].x, y: points[0].y),
                                         control2: CGPoint(x: points[1].x, y: points[1].y) )
            case .closePath: path.closeSubpath()
            @unknown default:
                path.closeSubpath()
            }
        }
        return path
    }
}

fileprivate class CircleScaleRippleMultiple: ActivityIndicatorAnimationDelegate {
    func setUpAnimation(in layer: CALayer, size: CGSize, color: NSColor) {
        let duration: CFTimeInterval = 1.25
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.0, 0.2, 0.4]
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.21, 0.53, 0.56, 0.8)
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.keyTimes = [0, 0.7]
        scaleAnimation.timingFunction = timingFunction
        scaleAnimation.values = [0, 1.0]
        scaleAnimation.duration = duration
        
        // Opacity animation
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.keyTimes = [0, 0.7, 1]
        opacityAnimation.timingFunctions = [timingFunction, timingFunction]
        opacityAnimation.values = [1, 0.7, 0]
        opacityAnimation.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        for i in 0 ..< 3 {
            let circle = Circle.layerWith(size: size, color: color)
            let frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                               y: (layer.bounds.size.height - size.height) / 2,
                               width: size.width,
                               height: size.height)
            
            animation.beginTime = beginTime + beginTimes[i]
            circle.frame = frame
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }
}
/// Activity indicator view with nice animations
internal final class ActivityView: NSView {
    static var DEFAULT_TYPE: IndicatorType = .circleRipple
    static var DEFAULT_COLOR = NSColor.orange
    static var DEFAULT_PADDING: CGFloat = 2.0
    
    /// Animation type.
    public var type: IndicatorType = ActivityView.DEFAULT_TYPE
    
    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'type' instead.")
    @IBInspectable var typeName: String {
        get {
            return getTypeName()
        }
        set {
            _setTypeName(newValue)
        }
    }
    
    @IBInspectable public var color: NSColor = ActivityView.DEFAULT_COLOR
    @IBInspectable public var padding: CGFloat = ActivityView.DEFAULT_PADDING
    
    /// Current status of animation, read-only.
    @available(*, deprecated)
    public var animating: Bool { return isAnimating }
    public private(set) var isAnimating: Bool = false
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //backgroundColor = NSColor.clear
        isHidden = true
    }
    public init(frame: CGRect, type: IndicatorType? = nil, color: NSColor? = nil, padding: CGFloat? = nil) {
        self.type = type ?? ActivityView.DEFAULT_TYPE
        self.color = color ?? ActivityView.DEFAULT_COLOR
        self.padding = padding ?? ActivityView.DEFAULT_PADDING
        super.init(frame: frame)
        isHidden = true
    }
    public override var intrinsicContentSize : CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }
    
    public final func startAnimating() {
        isHidden = false
        isAnimating = true
        layer?.speed = 1
        setUpAnimation()
    }
    public final func stopAnimating() {
        isHidden = true
        isAnimating = false
        layer?.sublayers?.removeAll()
    }
    
    // MARK: Internal
    func _setTypeName(_ typeName: String) {
        type =  IndicatorType.circleRipple
    }
    func getTypeName() -> String {
        return String(describing: type)
    }
    
    // MARK: Privates
    private final func setUpAnimation() {
        if(layer == nil){
            layer = CALayer()
        }
        self.wantsLayer = true
        let animation: ActivityIndicatorAnimationDelegate = type.animation()
        var animationRect = CGRect(x: padding, y: padding, width: frame.size.width - padding, height: frame.size.height - padding)
        let minEdge = min(animationRect.width, animationRect.height)
        layer?.sublayers = nil
        animationRect.size = CGSize(width: minEdge, height: minEdge)
        animation.setUpAnimation(in: layer!, size: animationRect.size, color: color)
    }
}

