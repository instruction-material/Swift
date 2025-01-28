// Note: Projects only run in Xcode Environment
import SwiftUI

struct ContentView: View {
    var body: some View {
        
       
        ZStack{
            
            VStack{
                CharacterView(name: "Mickey Mouse", theimage: "mickey", tvshow: "Mickey Mouse ClubHouse", description: "One of the main characters of Disney")
                    .padding()
                    .offset(x:0, y: -200);
                
                    
            }
            VStack{
                CharacterView(name: "Minnie Mouse", theimage: "minnie", tvshow: "Mickey Mouse ClubHouse", description: "One of the main characters of Disney")
                    .padding()
                    .offset(x:0, y: 180);
                
                    
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CharacterView: View {
    var name: String
    var theimage: String
    var tvshow: String
    var description: String
    
    var body: some View {
        
        VStack{
            Text(name)
                .font(.system(size:35, weight:.heavy, design:.rounded))
                .padding(10)
            Text("From: " + tvshow)
            Text(description)
            Image(theimage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
            
        }
    }
}
