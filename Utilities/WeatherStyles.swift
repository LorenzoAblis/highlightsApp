import SwiftUI
import Foundation

struct WeatherWidget: ViewModifier {
    func randomGradientPoints() -> (UnitPoint, UnitPoint) {
        let startPoints: [UnitPoint] = [.top, .leading, .topLeading, .topTrailing]
        let endPoints: [UnitPoint] = [.bottom, .trailing, .bottomLeading, .bottomTrailing]
        
        let randomStartPoint = startPoints.randomElement()!
        let randomEndPoint = endPoints.randomElement()!
        
        return (randomStartPoint, randomEndPoint)
    }
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(width:110, height: 130, alignment: .leading)
            .font(.system(size:20, design: .rounded))
            .background(
                LinearGradient(colors: [
                    Color(red: 0.333, green: 0.569, blue: 0.965),
                    Color(red: 0.659, green: 0.518, blue: 0.965)],
                               startPoint: randomGradientPoints().0, 
                               endPoint: randomGradientPoints().1)
            )
            .cornerRadius(20)
    }
}
