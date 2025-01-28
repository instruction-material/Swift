// Note: Projects only run in Xcode Environment
import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView(.horizontal){
            VStack(alignment: .leading) {
                HStack{
                    VStack(alignment: .leading){
                        Text("Monday, May 17".uppercased())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Your Art Gallery")
                            .font(.title)
                            .fontWeight(.black)
                    }
                    Spacer()
                    
                }
                .padding([.top, .horizontal])
                ScrollView(.vertical, showsIndicators: false){
                    VStack{
                        Group{
                            ArtView(image: "monaLisa", description: "This painting was painted in the 1500s in Italy.", title: "Mona Lisa", artist: "Leonardo da Vinci")
                                
                            ArtView(image: "waterLilyPond", description: "This painting was painted in 1899.", title: "The Water Lily Pond",artist: "Claude Monet")
                                
                            ArtView(image: "starryNight", description: "This oil-based painting was painted in 1889.", title: "The Starry Night", artist: "Vincent Van Gogh")
                                
                            ArtView(image: "pearlEarring", description: "This oil-based painting was painted by a Dutch painter in the later 1600s.", title: "Girl With a Pearl Earring", artist: "Johannes Vermeer")
                                
                        }
                        .frame(width: 400)
                        .minimumScaleFactor(0.5)
                        
                    }
                    Spacer()
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
