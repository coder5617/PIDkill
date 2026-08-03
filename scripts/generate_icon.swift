import Foundation
import AppKit

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

guard let ctx = NSGraphicsContext.current?.cgContext else {
    exit(1)
}

// 1. Dark Gradient Background Squircle
let cornerRadius: CGFloat = 224.0
let rect = CGRect(origin: .zero, size: size).insetBy(dx: 32, dy: 32)
let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)

let colorSpace = CGColorSpaceCreateDeviceRGB()
let bgColors = [
    NSColor(calibratedRed: 0.12, green: 0.12, blue: 0.18, alpha: 1.0).cgColor,
    NSColor(calibratedRed: 0.06, green: 0.06, blue: 0.10, alpha: 1.0).cgColor
] as CFArray
if let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0]) {
    ctx.saveGState()
    path.addClip()
    ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 512, y: 1024), end: CGPoint(x: 512, y: 0), options: [])
    ctx.restoreGState()
}

// 2. Glowing Accent Border
ctx.saveGState()
let borderPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
borderPath.lineWidth = 12.0
NSColor(calibratedRed: 0.95, green: 0.30, blue: 0.30, alpha: 0.8).setStroke()
borderPath.stroke()
ctx.restoreGState()

// 3. Draw Terminal Icon & PID Text
let textFont = NSFont.monospacedSystemFont(ofSize: 220, weight: .bold)
let textAttributes: [NSAttributedString.Key: Any] = [
    .font: textFont,
    .foregroundColor: NSColor(calibratedRed: 0.95, green: 0.35, blue: 0.35, alpha: 1.0)
]
let pidStr = NSString(string: ">_ PID")
let textSize = pidStr.size(withAttributes: textAttributes)
let textRect = CGRect(
    x: (1024 - textSize.width) / 2,
    y: (1024 - textSize.height) / 2 + 30,
    width: textSize.width,
    height: textSize.height
)
pidStr.draw(in: textRect, withAttributes: textAttributes)

// 4. Draw Port Badge
let badgeFont = NSFont.monospacedSystemFont(ofSize: 110, weight: .bold)
let badgeAttributes: [NSAttributedString.Key: Any] = [
    .font: badgeFont,
    .foregroundColor: NSColor(calibratedRed: 0.4, green: 0.85, blue: 1.0, alpha: 1.0)
]
let portStr = NSString(string: ":PORT")
let badgeSize = portStr.size(withAttributes: badgeAttributes)
let badgeRect = CGRect(
    x: (1024 - badgeSize.width) / 2,
    y: (1024 - badgeSize.height) / 2 - 140,
    width: badgeSize.width,
    height: badgeSize.height
)
portStr.draw(in: badgeRect, withAttributes: badgeAttributes)

image.unlockFocus()

// Save to PNG
guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    exit(1)
}

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon1024.png"
try pngData.write(to: URL(fileURLWithPath: outputPath))
print("Successfully generated 1024x1024 icon at \(outputPath)")
