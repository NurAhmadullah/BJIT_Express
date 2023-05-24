//
//  ListRowView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 22/5/23.
//

import SwiftUI

struct ListRowView: View {
    let column1: String
    let column2: String?
    let column3: String?
    let column4: String
    var body: some View {
        HStack {
            Text(column1)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let column2 = column2{
                Text(column2)
                    .frame(maxWidth: .infinity)
            }
            if let column3 = column3{
                Text(column3)
                    .frame(maxWidth: .infinity)
            }
            Text(column4)
                .frame(maxWidth: .infinity)
                .frame(alignment: .trailing)
        }
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(column1: "column1", column2: "column2", column3: "column3", column4: "column4")
    }
}
