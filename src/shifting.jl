using DataStructures

# importations des différentes structures
include("pointWeight.jl")
include("datastructures.jl")
include("openFile.jl")

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
                path::Vector{Tuple{Int64,Int64}} = [A]
                while predecessor[v] != (-1,-1)                        # le chemin s'arrête lorsque l'on retrouve D (son prédécesseur étant (-1,-1) par définition)
                    pushfirst!(path,predecessor[v])          
                    v = predecessor[v]
                end
                return path
            end

            # Exploration des voisins
            for (neighbor, weight_bow) in successorAMR(u, map)                                    
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
    throw(error("Il n'y a pas de chemin entre "*string(D)*" et "*string(A)))
end

#=
Fonction retournant la distance entre les points P et A
P | type : Tuple{Int64, Int64} | exemple : (12, 14)
A | type : Tuple{Int64, Int64} | exemple : (11, 13)
=#
function lenghtToA(P::Tuple{Int64, Int64}, A::Tuple{Int64,Int64})
    return sqrt((P[2]-A[2])^2 + (P[1]-A[1])^2)
end

#=
Fonction retournant les successeurs possibles de P avec leur poids
P | type : Tuple{Int64, Int64} | exemple : (12, 14)
height | type : Int64 | exemple : 49
width | type : Int64 | exemple : 49
=#
function successorAMR(P::Tuple{Int64, Int64}, map)

    height::Int64 = size(map)[1]
    width::Int64 = size(map[1])[1]
    succ::Vector{Tuple{Tuple{Int64,Int64},Int64}} = []

    for (x,y) in [(P[1]-1,P[2]), (P[1]+1,P[2]), (P[1],P[2]+1), (P[1],P[2]-1)]           
        if (1 <= x <= height && 1 <= y <= width)
            p = pointWeight[map[x][y]] 
            if p != -1
                push!(succ,((x,y),p))
            end
        end
    end
    return succ
end

#=
Fonciton effectuant les mouvements de tous les amr sur la carte
Retourne la liste des AMR modifiés
map | Vector{Vector{Char}} | exemple : [[. . .][@ . @]]
currentAmr | Vector{AMR} | exemple : TODO
pathAMR | Vector{Solution} | exemple : TODO
=#
function movement(map::Vector{Vector{Char}},currentAmr::Vector{AMR},pathAmr::Vector{Solution})
    for amr in currentAmr

        # avance de un point sur la map
        amr.point = popfirst!(amr.road)
        push!(pathAmr[amr.id].road,amr.point)           # ajoute le déplacement dans la solution

        if amr.point == amr.destination
            # On trouve l'index de l'objet 'amr' dans la liste 'currentAmr'
            idx = findfirst(x -> x === amr, currentAmr)
            
            # Si on l'a trouvé, on le supprime
            if idx !== nothing
                deleteat!(currentAmr, idx)
            end
            # TODO ajouter l'AMR a la solution
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