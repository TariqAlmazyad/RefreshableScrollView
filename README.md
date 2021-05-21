# RefreshableScrollView to add "Pull to refresh" as modifier for ScrollView in SwiftUI.

SwiftUI is very new when it comes to completion like UIKit. Apple has forgotten to include simple idea like "Pull to refresh" in UIScrollView . 
This Swift package is for your to make it up for your ✌🏻😅. 

![refreshableScrollView](https://user-images.githubusercontent.com/34104180/119067744-618cc280-b9eb-11eb-9066-8364f54bddb4.gif)


You can add the package to your project file -> Swift Package -> Add Package Dependcy :

```swift
.package(url: "https://github.com/TariqAlmazyad/RefreshableScrollView.git")
```


Please note thar it is recommanded to place it as last modifier for ScrollView, otherwise , you will have some unexpected errors .

```swift
import SwiftUI
import RefreshableScrollView

struct ContentView: View {
    
    @State private (set) var primaryColor = .white
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            LazyVGrid(columns: [ GridItem(.adaptive(minimum: 100, maximum: 200)), ]) {
                ForEach(0..<100) { num in
                    Text("\(num)")
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .overlay(Circle().stroke(Color.white, lineWidth: 0.2))
                }
            }.padding(.top, 26)
        }).background(primaryColor.ignoresSafeArea())
        // recommanded to place it as last modifier for ScrollView 
        .onRefresh(spinningColor: .white, text: "Pull to refresh", textColor: .white, backgroundColor: primaryColor) { refreshControl in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                refreshControl.endRefreshing()
            }
        }
    }
}

```
