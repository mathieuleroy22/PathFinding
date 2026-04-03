# importation des différentes structures
include("pointWeight.jl")

# -----------------------------------------------------------------------------
# data structure décrivant une intance

struct Instance

    name::String                                        # nom de l'instance

    dock::Vector{Tuple{Int64,Int64}}                   # points de départ des AMR (exemple: (1,1))
    departureTime::Vector{Int64}                        # temps auquel les AMR démarrent (exemple: t=0)
    destination::Vector{Tuple{Int64,Int64}}             # points d'arrivée des AMR (exemple: (1,5))

    map::Vector{Vector{Char}}                           # map sans aucun AMR

    # Constructeur interne
    function Instance(name, dock, departureTime, destination, map)

        # Vérification de la taille des vecteurs
        n = length(dock)
        if n != length(departureTime) || n != length(destination)
            throw(ArgumentError("Il n'y a pas autant de quai, d'arrivée et de temps de départ"))
        end

        # Vérification des départs et destinations sur la map
        height::Int64 = size(map)[1]
        width::Int64 = size(map[1])[1]
        for (x,y) in dock
            (1 <= x <= height && 1 <= y <= width) || throw(ArgumentError("Un départ n'est pas sur la carte"))
            (pointWeight[map[x][y]] != -1) || throw(ArgumentError("Un départ n'est pas accessible"))
        end
        for (x,y) in destination
            (1 <= x <= height && 1 <= y <= width) || throw(ArgumentError("Une destination n'est pas sur la carte"))
            (pointWeight[map[x][y]] != -1) || throw(ArgumentError("Une destination n'est pas accessible"))
        end

        # Calcul de la permutation (les indices qui trient departureTime)
        p = sortperm(departureTime)

        # Application de la permutation à tous les vecteurs
        new(
            name, 
            dock[p], 
            departureTime[p], 
            destination[p],
            map
        )
    end

end

# -----------------------------------------------------------------------------
# data structure décrivant un AMR convoyeur

struct AMR

    id::Int64                               # id définissant l'AMR

    departuretime::Int64                    # temps auquel l'AMR a commencé sa tâche
    point::Tuple{Int64,Int64}               # point où il se situe
    destination::Tuple{Int64,Int64}         # destination de l'AMR
    road::Vector{Tuple{Int64,Int64}}        # chemin que l'AMR doit parcourir
    
end

# TODO faire un struct solution pour stocker facilement les chemins parcourus

# -----------------------------------------------------------------------------
# data structure décrivant une solution optimale du problème

struct Solution

end