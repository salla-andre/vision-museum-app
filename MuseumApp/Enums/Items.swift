//
//  Items.swift
//  MuseumApp
//
//  Created by André Salla on 14/06/24.
//

import Foundation

enum Items: String, CaseIterable {
    case ballot
    case vase
    case bust
    
    var entityGroupName: String {
        "\(self.rawValue.capitalized)Group"
    }
    
    var title: String {
        switch self {
            case .ballot: "Ballot box"
            case .vase: "Hydria apothecary vase"
            case .bust: "Bust of woman"
        }
    }
    
    var description: String {
        switch self {
            case .ballot: 
"""
The richly-decorated box was made in the neo-Gothic style. It has a base in the shape of an eight-pointed star with corners highlighted with intersecting mouldings. The main part is cylindrical, narrowed in the middle of its height and covered with carved decorative traceries. The belly is vase-shaped and divided by columns into four sections. It is decorated with traceries, coats of arms of the Jagiellonian University as well as a coat of arms featuring the White Eagle, along with a half-length figure of St. Stanislaus. The lid is flat, divided into four sections and decorated with floral motifs and traceries. It is crowned with a fleuron handle.

The ballot box was used to vote during the election of the rector of the Jagiellonian University.

The creator of the box, Józef Korwin Brzostowski, was a sculptor associated with Kraków. He prepared a detailed description of the altar made by Veit Stoss in St. Mary’s church, taking into account the state of its preservation. He also carried out a number of conservation works in the sacral buildings of Kraków, including the Wawel cathedral. He made sculptures, furniture and church furnishings.
"""
            case .vase:
"""
A hydria-type apothecary maiolica vase created in Savona (Italy) in the late 17th century. Handles in the shape of (fantastic) animal heads on massive bent necks. At the front, towards the bottom of the vase, a gargoyle in relief. Plugged with regular cork, its mouth doubles as an opening for pouring out the contents of the vase. Smaller gargoyles, without any openings, located under the handles, alongside the vase. At the front, above an inscription, a hand-painted decoration: a human figure keeping a two-headed dragon on a leash. A centaur slaying a dragon adorns the back of the vase. Colours: shades of blue. Inscription on the banderole: "Aquæ. Plantag:s" (Aquæ Plantaginis). Aqua Plantaginis is a water distillate of broadleaf plantain (Plantago major L.)

“Plantago water is good for wounds, and because it is pungent, it is also good for any diarrhoea, especially if one suffers from intestinal pain. It should be consumed often, and it is also recommended as enema, which opens any clogged liver or spleen, cools down inflamed blood, and allows the healthy body to grow over fistulas, as it is conducive to tissue regeneration, especially of old wounds. It stops haemorrhoidal bleeding, as long as one thoroughly washes their rectum, that is, the final part of the large intestine, with it. It also soothes toothache, provided one washes their oral cavity with it”.

Source: Marcin Siennik, Herbarz [Herbarium], Kraków, 1568, p. 235.

Exhibit from the collection of apothecary ceramics donated to the Museum in 1976 by Mateusz Bronisław Grabowski, a Polish-British, London-based pharmacist.
"""
            case .bust: 
"""
The sculpture presents a classicist bust of a young woman with a slightly bent head turned to the right. The base for the bust is a profiled pedestal.
On the back of the bust, a signature of the author and the year are visible: “C. Schlüter. 1880”. For a long time, it was believed that it depicted Róża Loewenfeld, who rendered great service to Chrzanów. Admittedly, a faint resemblance of the artistic vision of the German sculptor to the actual figure raised doubts, but how many times have images been idealised, beautifying the portrayed individuals and making them look younger? However, during conservation works in 2013 and archival research performed at the same time, it was discovered that the doubts had been justified. After all, it turned out that the bust did not present the doyenne of the Loewenfeld family, even if this was very much wanted because of the huge importance of this Jewish family to the history of Chrzanów. Well, the classic beauty portrayed by Carl Schlüter was his wife rather than Róża née Asher, who came to Chrzanów with her husband, Emanuel Loewenfeld and later went down in the history of the town.
"""
        }
    }
    
    static func itemByEntity(named name: String) -> Self? {
        Self.allCases.first(where: { $0.entityGroupName == name })
    }
}
