using Images, Colors

#= --------------------------------------------------------------
Dictionnaire associant à chaque caractere son poids
la valeur -1 est donnée pour les caracteres infranchissables =#
pointWeight = Dict( '.' => 1,
                    'G' => 1,
                    'S' => 5,
                    'W' => 8,
                    '@' => -1,
                    '0' => -1,
                    'T' => -1
                )

#= --------------------------------------------------------------
Dictionnaire associant à chaque symbole une couleur pour l'affichage de la carte
=#
colorMapping = Dict('.' => RGB(1.0, 1.0, 1.0),      # Blanc
                    'G' => RGB(1.0, 1.0, 1.0),      # Blanc
                    'S' => RGB(1.0, 1.0, 0.0),      # Jaune
                    'W' => RGB(0.0, 0.0, 1.0),      # Bleu
                    '@' => RGB(0.2, 0.2, 0.2),      # Gris foncé
                    '0' => RGB(0.2, 0.2, 0.2),      # Gris foncé
                    'T' => RGB(0.2, 0.2, 0.2),      # Gris foncé
                )