import SwiftUI

struct ContentView: View {
    @State private var layoutType = LayoutType.h

    // This contains a case for each supported layout.
    enum LayoutType: Int, CaseIterable {
        case h, v, z, alt

        var index: Int {
            Self.allCases.firstIndex(where: { $0 == self })!
        }

        var layout: any Layout {
            switch self {
            case .h: return HStackLayout(alignment: .top, spacing: 0)
            case .v: return VStackLayout(alignment: .leading, spacing: 0)
            case .z: return ZStackLayout(alignment: .topLeading)
            case .alt: return AlternateStackLayout()
            }
        }
    }

    struct Box {
        let color: Color
        let width: CGFloat
        let height: CGFloat
    }

    private let boxes = [
        Box(color: .indigo, width: 100, height: 100),
        Box(color: .teal, width: 80, height: 80),
        Box(color: .purple, width: 60, height: 60),
        Box(color: .red, width: 40, height: 40)
    ]

    var body: some View {
        NavigationStack {
            AnyLayout(layoutType.layout) {
                ForEach(boxes, id: \.color) { box in
                    box.color.frame(
                        width: box.width,
                        height: box.height
                    )
                }
            }
            .padding()
            .navigationTitle("AnyLayout Demo Develop 2")
            .animation(.default, value: layoutType)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: {
                            let cases = LayoutType.allCases
                            layoutType =
                                cases[(layoutType.index + 1) % cases.count]
                        },
                        label: {
                            Image(systemName: "circle.grid.3x3.circle.fill")
                                .imageScale(.large)
                        }
                    )
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
