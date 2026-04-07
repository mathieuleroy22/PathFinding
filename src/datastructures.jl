# importation des différentes structures
include("pointWeight.jl")

# -----------------------------------------------------------------------------
# data structure décrivant un intervalle de sécurité

mutable struct SafeInterval

    id::Int64             # Pour distinguer les intervalles sur une même case
    start_t::Float64      # Temps où la case devient libre
    end_t::Float64        # Temps où un obstacle arrive

end

# -----------------------------------------------------------------------------
# data structure décrivant une case de la map

mutable struct Case

    weight::Int64                           # son poids
    safeInterval::Vector{SafeInterval}      # ses intervalles de sécurité

    function Case(weight::Int64)
        new(weight,[SafeInterval(1,0,typemax(Int64))])       # Par défaut, une case a un seul intervalle de sécurité de 0 à l'infini
    end

end

# -----------------------------------------------------------------------------
# data structure décrivant une intance

struct Instance

    name::String                                        # nom de l'instance

    dock::Vector{Tuple{Int64,Int64}}                    # points de départ des AMR (exemple: (1,1))
    departureTime::Vector{Int64}                        # temps auquel les AMR démarrent (exemple: t=0)
    destination::Vector{Tuple{Int64,Int64}}             # points d'arrivée des AMR (exemple: (1,5))

    displayMap::Matrix{RGB{Float64}}                    # matrice de couleur pour l'affichage de la map
    map::Dict{Tuple{Int64, Int64}, Case}                # couple (point,case) pour représenter la map
    height::Int64                                       # hauteur de la map
    width::Int64                                        # longueur de la map

    # Constructeur interne
    function Instance(name, dock, departureTime, destination, displayMap, map, height, width)

        # Vérification de la taille des vecteurs
        n = length(dock)
        (n == length(departureTime) && n == length(destination)) || throw(ArgumentError("Il n'y a pas autant de quai, d'arrivée et de temps de départ"))

        # Vérification des départs et destinations sur la map
        for (x,y) in dock
            (1 <= x <= height && 1 <= y <= width) || throw(ArgumentError("Un départ n'est pas sur la carte"))
            haskey(map, (x, y)) || throw(ArgumentError("Un départ n'est pas accessible"))
        end
        for (x,y) in destination
            (1 <= x <= height && 1 <= y <= width) || throw(ArgumentError("Une destination n'est pas sur la carte"))
            haskey(map, (x, y)) || throw(ArgumentError("Une destination n'est pas accessible"))
        end
        # TODO regrouper le code ???

        # Calcul de la permutation (les indices qui trient departureTime)
        p = sortperm(departureTime)

        # Application de la permutation à tous les vecteurs
        new(
            name, 
            dock[p], 
            departureTime[p], 
            destination[p],
            displayMap,
            map,
            height,
            width
        )
    end

end

# -----------------------------------------------------------------------------
# data structure décrivant un AMR convoyeur

struct AMR

    id::Int64                                           # id définissant l'AMR

    color::RGB{Float64}                                 # couleur qui représentera l'AMR graphiquement
    departuretime::Int64                                # temps auquel l'AMR a commencé sa tâche
    point::Tuple{Int64,Int64}                           # point où il se situe
    destination::Tuple{Int64,Int64}                     # destination de l'AMR
    road::Vector{Tuple{Int64,Int64}}               # chemin que l'AMR

end