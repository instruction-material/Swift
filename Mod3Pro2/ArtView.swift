import SwiftUI

struct ArtView: View {
    var image: String
    var description: String
    var title: String
    var artist: String
    
    var body: some View {
            VStack {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            
                HStack {
                    VStack(alignment: .leading){
                        Text(title)
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.primary)
                            .lineLimit(3)
                        Text("Painted by \(artist)".uppercased())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(description)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                    }
                    Spacer()
                }
                .padding()
            }
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius:10)
                        .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1))
            .padding([.top, .horizontal])
        }
        
    
}

struct ArtView_Previews: PreviewProvider {
    static var previews: some View {
        ArtView(image: "monaLisa", description: "This painting was painted in the 1500s in Italy.", title: "Mona Lisa", artist: "Leonardo da Vinci")
    }
}
