using GLMakie
using Colors
using LinearAlgebra # Pour transpose

function animate_amr_paths(base_rgb_matrix::AbstractMatrix{<:Colorant}, amrs::Vector{AMR}; speed::Real=0.1)
    # 1. On prépare la matrice pour Makie (Transposer pour l'horizontal, Inverser pour le sens haut/bas)
    # On définit une fonction de transformation pour éviter de répéter le code
    prepare(m) = collect(reverse(transpose(m), dims=2))

    display_matrix = Observable(prepare(base_rgb_matrix))
    
    # 2. Configuration de la figure
    fig = Figure(size = (1200, 600)) 
    ax = GLMakie.Axis(fig[1, 1], aspect = DataAspect(), title = "Suivi Flotte AMR - Temps Réel")
    hidedecorations!(ax)
    
    # Correction du flou : interpolate = false
    image!(ax, display_matrix, interpolate = false)
    
    Base.display(fig)
    
    max_steps = maximum(amr.departuretime + length(amr.road) for amr in amrs)
    
    for t in 1:max_steps
        current_frame = copy(base_rgb_matrix)
        
        for amr in amrs
            if amr.departuretime <= t <= length(amr.road) + amr.departuretime
                step_idx = min(t - amr.departuretime +1 , length(amr.road) )
                
                # Correction ici : on extrait directement le tuple (y, x)
                # Si road[step_idx] est déjà (y, x), pas besoin de [1]
                pos = amr.road[step_idx]
                y, x = pos[1], pos[2]
                
                if checkbounds(Bool, current_frame, y, x)
                    current_frame[y, x] = amr.color
                end
            end
        end
        
        # On applique la transformation avant la mise à jour de l'affichage
        display_matrix[] = prepare(current_frame)
        
        sleep(speed)
        
        if !events(fig).window_open[] 
            break 
        end
    end
end

#=
TODO
=#
function displayMap(img::Matrix{RGB{Float64}})

    # Répète chaque élément 20 fois sur les lignes et 20 fois sur les colonnes
    img_large = repeat(img, inner=(20, 20))
    save("labyrinthe_HD.png", img_large)

end