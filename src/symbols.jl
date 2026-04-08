#= -----------------------------------------------------------------------------
PROJET : Simulation d'AMR (Autonomous Mobile Robots) | Path Finding
FICHIER : symbols.jl
DESCRIPTION : 
    Ce fichier permet de traduire les symboles soit en fonction
    de leur poids soit en fonction de leur couleur.

AUTEUR : Mathieu LEROY
DERNIÈRE MODIFICATION : 08 Avril 2026
----------------------------------------------------------------------------- =#

#----- Packages -----
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