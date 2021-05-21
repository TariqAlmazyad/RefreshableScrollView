import SwiftUI

@available(iOS 14.0, *)
@available(macOS 10.15, *)

public extension View {
    /// ViewModifier mainly for ScrollView to add UIRefreshControl on top and perform action when refreshing is finishing
    /// - Parameters:
    ///   - spinningColor: pass your desired color for the spinning wheel
    ///   - text: pass your desired . e,g "Pull to refresh"
    ///   - textColor: pass your desired text color
    ///   - backgroundColor: pass your desired background color
    ///   - onRefresh: you have the ability to control what action your app should perform when you do refreshControl.endRefreshing()
    /// - Returns: modified your current ScrollView
    func onRefresh(spinningColor: Color, text: String , textColor: Color,
                   backgroundColor: Color, onRefresh: @escaping (UIRefreshControl) -> ()) -> some View {
        RefreshableScrollView(content: {self},spinningColor: spinningColor, text: text,
                              textColor: textColor,backgroundColor: backgroundColor,  onRefresh: onRefresh)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .ignoresSafeArea()
    }
}

@available(iOS 14.0, *)
@available(macOS 10.15, *)
public struct RefreshableScrollView<Content: View>: UIViewRepresentable {
    
    var content: Content
    var onRefresh: (UIRefreshControl) -> ()
    var refreshControl = UIRefreshControl()
    var backgroundColor: Color
    var spinningColor: Color
    var textColor: Color
    var text: String

    init(@ViewBuilder content: @escaping () -> Content, spinningColor: Color,
                      text: String , textColor: Color , backgroundColor: Color ,
                      onRefresh: @escaping (UIRefreshControl) -> ()) {
        self.content = content()
        self.onRefresh = onRefresh
        self.backgroundColor = backgroundColor
        self.spinningColor = spinningColor
        self.textColor = textColor
        self.text = text
    }

    public func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()

        let hostView = UIHostingController(rootView: AnyView(content.frame(maxHeight: .infinity, alignment: .top)))
        hostView.view.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(hostView.view)
        NSLayoutConstraint.activate([
            hostView.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostView.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostView.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            hostView.view.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor, constant: 1)
        ])

        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear

        let attributes = [NSAttributedString.Key.foregroundColor: textColor.uiColor()]
        refreshControl.attributedTitle = NSAttributedString(string: text, attributes: attributes)
        refreshControl.tintColor = spinningColor.uiColor()
        refreshControl.addTarget(context.coordinator, action: #selector(context.coordinator.onRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl

        return scrollView
    }

    
    public func updateUIView(_ uiView: UIScrollView, context: Context) {
        uiView.backgroundColor = backgroundColor.uiColor()
        context.coordinator.parent.backgroundColor = backgroundColor
    }
    

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public class Coordinator: NSObject {
        var parent: RefreshableScrollView
        init(parent: RefreshableScrollView) {
            self.parent = parent
        }
        @objc func onRefresh(){
            parent.onRefresh(parent.refreshControl)
        }
    }
}

// MARK:- Color -> uiColor()
@available(iOS 14.0, *)
@available(macOS 10.15, *)
extension Color {
    func uiColor() -> UIColor {
       
        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {

        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
}

