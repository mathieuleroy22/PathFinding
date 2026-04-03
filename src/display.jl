using Plots

#=
Fonction réalisant l'affichage du résultat
weightPath | type : Int64 | exemple : 2
nbStates | type : Int64 | exemple : 10
path | type : Vector{Tuple{Int64,Int64}} | exemple : [(12,13),(12,12)]
A | type : Tuple{Int64, Int64} | exemple : (12,14)
=#
function algoDisplay(lengthPath::Int64, nbStates::Int64, path::Vector{Tuple{Int64,Int64}}, A::Tuple{Int64, Int64})
    println("Distance D -> A : ", lengthPath)
    println("Number of nbStates evaluated : ", nbStates)
    print("Path D → A : ")
    l = length(path)
    for i in 1:l
        print(path[l-i+1], " -> ")                   # le départ est le dernier élément de path      
    end
    println(A)
end


# TODO ATTENTION PAS VERIFIER
function amrDisplay(carte_matrice, chemin, D, A)
    # 1. On crée une copie de la carte (en Float pour gérer les couleurs)
    # Imaginons que carte_matrice contient : 0 = Mur, 1 = Vide
    grille_affichage = float.(carte_matrice)

    # 2. On dessine le chemin (on lui donne la valeur 0.5 par exemple)
    for (x, y) in chemin
        grille_affichage[x, y] = 0.5
    end

    # 3. On marque le Départ (D) et l'Arrivée (A)
    grille_affichage[D[1], D[2]] = 0.25 # Valeur arbitraire pour une couleur distincte
    grille_affichage[A[1], A[2]] = 0.75 

    # 4. On génère l'image avec une heatmap
    # yflip=true met (1,1) en haut à gauche (standard pour les matrices/cartes)
    # aspect_ratio=:equal garantit que les cases sont carrées
    p = heatmap(grille_affichage, 
                color=:viridis, # Vous pouvez tester :grays, :inferno, etc.
                yflip=true, 
                legend=false, 
                aspect_ratio=:equal,
                title="Solution Pathfinding")
    
    # 5. On affiche la fenêtre
    display(p)
end