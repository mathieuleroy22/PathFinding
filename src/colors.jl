#= -----------------------------------------------------------------------------
PROJET : Simulation d'AMR (Autonomous Mobile Robots) | Path Finding
FICHIER : colors.jl
DESCRIPTION : 
    Ce fichier gère les couleurs uniques des AMR. 

AUTEUR : Mathieu LEROY
DERNIÈRE MODIFICATION : 08 Avril 2026
----------------------------------------------------------------------------- =#

#----- Package -----
using Colors

#= --------------------------------------------------------------
Ensemble stockant les couleurs déjà utilisées (initialisé vide)
=# 
const COULEURS_UTILISEES = Set{String}()

#= --------------------------------------------------------------
Fonction retournant une couleur RGB
Evite les couleurs déjà présentes sur la carte et les couleurs déjà données à un autre AMR
=#
function couleur_aleatoire_unique()
    while true
        h = rand() * 360
        s = 0.6 + rand() * 0.4          # Évite le blanc/gris
        v = 0.6 + rand() * 0.4          # Évite le noir/gris foncé
        
        est_jaune = 45 < h < 75         
        est_bleu  = 180 < h < 270 
        
        if !est_jaune && !est_bleu      # Évite le jaune et le bleu
            c = HSV(h, s, v)
            
            code_hex = hex(c)           # Conversion en Hexadécimal pour une comparaison stricte et facile
            
            if !(code_hex in COULEURS_UTILISEES)
                push!(COULEURS_UTILISEES, code_hex)
                return c
            end
        end
    end
end

# ----- TEST -----
# println(couleur_aleatoire_unique())
# println(couleur_aleatoire_unique())