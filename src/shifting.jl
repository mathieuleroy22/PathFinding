# importations des différentes structures
include("pointWeight.jl")
include("datastructures.jl")
include("openFile.jl")
include("algo.jl")                  # TODO mettre les fonctions dans un autre fichier ???

#=
Fonction affichant le chemin entre D et A sur map en suivant l'algorthme Astar
Renvoie le chemin dans un tableau
map | type : Vector{Vector{Char}} | exemple : [[. . .][@ . @]]
• D | type : Tuple{Int64, Int64} | exemple : (1, 1)
• A | type : Tuple{Int64, Int64} | exemple : (2, 2)"
=#
function algoAstarAMR(map::Vector{Vector{Char}}, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64}) 
    
    # Début du parcours
    permanent = Vector{Tuple{Int64,Int64}}()                        # initialisation d'un tableau contenat les points permanents
    FilePrio = PriorityQueue()                                      # intialisation d'une file de priorité en fonction du poids de chemin pour y parvenir depuis D
    predecessor = Dict(D=>(-1,-1))                                  # initialisation d'un dictionnaire avec le point de départ provenant d'un point non défini
    distance = Dict(D=>0)                                           # initialisation d'un dictionnaire avec le point de départ à une distance de 0 de D
    
    FilePrio[D] = 0                               

    while !(isempty(FilePrio))

        u = dequeue!(FilePrio)

        if !(u in permanent)

            push!(permanent,u)
        
            if u == A

                v = u
                path::Vector{Tuple{Int64,Int64}} = []
                while predecessor[v] != (-1,-1)                        # le chemin s'arrête lorsque l'on retrouve D (son prédécesseur étant (-1,-1) par définition)
                    pushback!(path,predecessor[v])          
                    v = predecessor[v]
                end
                return path
            end

            # Exploration des voisins
            for (neighbor, weight_bow) in successor(u, map)                                      
                if !(neighbor in permanent)
                    new_cost = distance[u] + weight_bow
                    new_prio = new_cost + lenghtToA(neighbor,A) 
                
                    # Si on trouve un chemin plus court vers ce voisin
                    if new_cost < get(distance, neighbor, typemax(Int64))
                        distance[neighbor] = new_cost
                        predecessor[neighbor] = u
                        FilePrio[neighbor] = new_prio # Met à jour ou ajoute
                    end
                end
            end
        end 
    end
    return []
end

#=
Fonciton effectuant les mouvements de tous les amr sur la carte
Retourne la liste des AMR modifiés
map | Vector{Vector{Char}} | exemple : [[. . .][@ . @]]
currentAmr | Vector{AMR} | exemple : TODO
=#
function movement(map::Vector{Vector{Char}},currentAmr::Vector{AMR})
    for amr in currentAmr
        amr.point = popfirst!(amr.road)
        if amr.point == amr.destination
            currentAmr.pop(amr)
            # TODO Ajouter l'amr a la solution
        end
        # TODO vérifier qu'il peut aller sur la case
        # TODO vérifier si la case est la destination
    end
    return currentAmr
end

#=
Fonction réglant la collision entre AMR1 et AMR2
=#
function collision()
    return nothing
end