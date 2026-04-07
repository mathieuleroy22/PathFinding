using Colors

# On crée un ensemble vide pour stocker les couleurs déjà utilisées
const COULEURS_UTILISEES = Set{String}()

function couleur_aleatoire_unique()
    while true
        h = rand() * 360
        s = 0.6 + rand() * 0.4  # Évite le blanc/gris
        v = 0.6 + rand() * 0.4  # Évite le noir/gris foncé
        
        # Filtres de teintes
        est_jaune = 45 < h < 75
        est_bleu  = 180 < h < 270
        
        if !est_jaune && !est_bleu
            c = HSV(h, s, v)
            # On convertit en Hexadécimal pour une comparaison stricte et facile
            code_hex = hex(c)
            
            if !(code_hex in COULEURS_UTILISEES)
                push!(COULEURS_UTILISEES, code_hex)
                return c
            end
        end
    end
end

# Tests
# println(couleur_aleatoire_unique())
# println(couleur_aleatoire_unique())