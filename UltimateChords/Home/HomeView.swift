//
//  ContentView.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 15/3/22.
//

import SwiftUI
import IRLPDFScanContent
struct HomeView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Lyric.lastViewed, ascending: false)], animation: .default)
    private var lyrics: FetchedResults<Lyric>
    
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    
    var body: some View {
        List {
            ForEach(lyrics) {
                HomeCell(lyric: $0)
            }
            .onDelete(perform: self.deleteItems)
        }
        .onChange(of: viewModel.documentString) { newValue in
            guard let newValue = newValue else { return }
            viewModel.save(string: newValue)
        }
        .overlay(SearchContent().environmentObject(searchViewModel))
        .searchable(text: $searchViewModel.searchText, prompt: Text("Title or Artist"))
        .navigationTitle("Home")
        .navigationBarItems(trailing: navTrailing())
    }
    
    private func navTrailing() -> some View {
        HStack {
            Text("Scanner").tapToPush(PDFScannerView())
            XIcon(.doc_text_viewfinder)
                .tapToPresent(CameraView(), .Sheet)
            XIcon(.doc_text_viewfinder)
                .tapToPresent(DocumentPicker(fileContent: $viewModel.documentString))
            XIcon(.square_and_pencil)
                .tapToPush(LyricsCreaterView())
        }
    }
    
   
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { lyrics[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                fatalError()
            }
        }
    }
}

