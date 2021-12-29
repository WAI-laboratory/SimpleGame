//
//  MineView.swift
//  OpenGames
//
//  Created by yjlee12 on 2021/12/29.
//

import Foundation
import SwiftUI

struct CellView: View {
    @EnvironmentObject var game: Game
    var cell: Cell

    var body: some View {
        cell.image
            .resizable()
            .scaledToFill()
            .frame(width: game.settings.squareSize,
                   height: game.settings.squareSize,
                   alignment: .center)
            .onTapGesture(count: 2, perform: {
                game.toggleFlag(on: cell)
            })
            .onTapGesture {
                game.click(on: cell)
            }
            .onLongPressGesture {
                game.toggleFlag(on: cell)
            }
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(cell: Cell(row: 0, column: 0))
            .environmentObject(Game(from: GameSettings())) // Add the env object so that our CellView can access it.
    }
}
