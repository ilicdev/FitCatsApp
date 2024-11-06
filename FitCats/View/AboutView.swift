//
//  AboutView.swift
//  FitCats
//
//  Created by Milos Ilic on 28.10.24..
//

import Foundation
import SwiftUI

struct AboutView: View {
    @State private var showInfoAlert = false
    @State private var selectedAnimal: String = ""
    @State private var animalDescription: String = ""
    
    // Updated rank data with hardcoded images in the desired order
    let ranks = [
        ("Cat", "0 steps", "House cats are domesticated members of the feline family, known for their companionship.", "rank1"),
        ("Cheetah", "21,000 steps", "Cheetahs are the fastest land animals and are known for their incredible speed.", "rank2"),
        ("Jaguar", "42,000 steps", "Jaguars are powerful and elusive animals, primarily found in dense forests.", "rank3"),
        ("Leopard", "63,000 steps", "Leopards are known for their strength and adaptability in various environments.", "rank4"),
        ("Tiger", "84,000 steps", "Tigers are the largest members of the cat family and are known for their powerful builds.", "rank5"),
        ("Lion", "105,000 steps", "Lions are known as the 'kings of the jungle' and live in family groups called prides.", "rank6")
    ]
    
    var body: some View {
        VStack {
            Text("Fitness Cats")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Cats are one of the most popular pets in the world. The cat family includes over 40 different species of cats.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 8)
            
            List(ranks, id: \.0) { rank in
                HStack {
                    Image(rank.3) // Display the hardcoded image for each rank
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle()) // Optional: makes the image circular
                    
                    VStack(alignment: .leading) {
                        Text(rank.0)
                            .font(.headline)
                        Text(rank.1)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {
                        selectedAnimal = rank.0
                        animalDescription = rank.2
                        showInfoAlert.toggle()
                    }) {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
            }
            .listStyle(PlainListStyle())
        }
        .alert(isPresented: $showInfoAlert) {
            Alert(
                title: Text(selectedAnimal),
                message: Text(animalDescription),
                dismissButton: .default(Text("Close"))
            )
        }
        .padding(.bottom, 8)
    }
}

