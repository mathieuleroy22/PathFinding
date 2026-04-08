#= -----------------------------------------------------------------------------
PROJET : Simulation d'AMR (Autonomous Mobile Robots) | Path Finding
FICHIER : display.jl
DESCRIPTION : 
    Ce fichier permet l'affichage des résultats. Une animation avec
    animateAMR et deux exportations de fichiers avec exportMAp et exportAMR.

AUTEUR : Mathieu LEROY
DERNIÈRE MODIFICATION : 08 Avril 2026
----------------------------------------------------------------------------- =#

#----- Packages -----
using GLMakie
using LinearAlgebra         # Pour transpose

#= --------------------------------------------------------------
Fonction affichant une animation des AMR sur la carte au fur et à mesure
du temps grâce aux packages GLMakie et LinearAlgebra. 
baseRGBmatrix | type : AbstractMatrix{<:Colorant} | exemple : instance.displayMap (Matrice RGB de la grille)
amrs | type : Vector{AMR} | exemple : [amr1, amr2, amr3] (Liste des robots planifiés)
speed | type : Real | exemple : 1.0 (vitesse normale), 0.5 (ralenti), 2.0 (rapide)
=#
function animateAMR(baseRGBmatrix::AbstractMatrix{<:Colorant}, amrs::Vector{AMR}; speed::Real=0.1)

    # Prépare la matrice pour Makie (Transposer pour l'horizontal, Inverser pour le sens haut/bas)
    # Définition d'une fonction de transformation pour éviter de répéter le code
    prepare(m) = collect(reverse(transpose(m), dims=2))                    
    display_matrix = Observable(prepare(baseRGBmatrix))
    
    # Configuration de la figure
    fig = Figure(size = (1200, 600)) 
    ax = GLMakie.Axis(fig[1, 1], aspect = DataAspect(), title = "Déplacements AMR - Temps Réel")
    hidedecorations!(ax)
    
    # Correction du flou : interpolate = false
    image!(ax, display_matrix, interpolate = false)
    
    Base.display(fig)
    
    # Temps auquel le dernier AMR arrive à destination
    max_steps = maximum(amr.departuretime + length(amr.road) for amr in amrs)
    
    for t in 1:max_steps

        # Carte sans AMR
        current_frame = copy(baseRGBmatrix)
        
        for amr in amrs
            if amr.departuretime <= t <= length(amr.road) + amr.departuretime           # si l'AMR se déplace sur la carte
                step_idx = min(t - amr.departuretime +1 , length(amr.road) )
                
                (y,x) = amr.road[step_idx]
                
                if checkbounds(Bool, current_frame, y, x)                               # si le point (y,x) est bien situé à l'intérieur de la carte
                    current_frame[y, x] = amr.color
                end
            end
        end
        
        # Transformation avant la mise à jour de l'affichage
        display_matrix[] = prepare(current_frame)
        
        # Attente avant le temps t+1
        sleep(speed)
        
        # Arrete l'affichage si la fenêtre est fermée
        if !events(fig).window_open[]                           
            break 
        end
    end
end

#= --------------------------------------------------------------
Fonction exportant l'image de la carte dans le dossier out
avec un agrandissement des pixels pour une meilleure visibilité.
img | type : Matrix{RGB{Float64}} | exemple : instance.displayMap (La matrice RGB de la grille)
=#
function exportMap(img::Matrix{RGB{Float64}})

    # Répète chaque élément 20 fois sur les lignes et 20 fois sur les colonnes
    img_large = repeat(img, inner=(20, 20))
    save("out/colorMap.png", img_large)

    println("L'exportation est terminée. Fichier généré : colorMap.png")
end

#= --------------------------------------------------------------
Fonction exportant les AMR dans un fichier 'resultatsAmr.txt' 
contenant le départ, la destination, le temps d'arrivée, le coût
et le chemin de chaque AMR.
amrs | type : Vector{AMR} | exemple : [amr1, amr2, amr3] (Liste des robots planifiés)
=#
function exportAMR(amrs::Vector{AMR})
    
    open("out/resultatsAmr.txt", "w") do file                          # mode écriture (écrase s'il existe déjà)
        for amr in amrs

            # Extraction des informations basées sur le format ((x, y), t)
            start_pos = amr.road[1]
            start_time = amr.departuretime
            
            end_pos = amr.road[end]
            arrival_time = start_time + length(amr.road) - 1
            
            cost = arrival_time - start_time

            id = amr.id

            # Formatage et écriture dans le fichier
            println(file, "=== AMR $id ===")
            println(file, "- Départ : $start_pos (à t=$start_time)")
            println(file, "- Destination : $end_pos")
            println(file, "- Temps d'arrivée : $arrival_time")
            println(file, "- Coût du trajet : $cost")
            println(file, "- Chemin complet : $(amr.road)")
            println(file, "") # Ligne vide pour séparer les AMRs
        end
    end
    
    println("L'exportation est terminée. Fichier généré : resultatsAmr.txt")
end