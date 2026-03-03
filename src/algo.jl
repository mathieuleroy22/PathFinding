using DataStructures

# TODO nom anglais
#= Dictionnaire associant à chaque caractere son poids
la valeur -1 est donnée pour les caracteres infranchissables =#
poidsCase = Dict(   '.' => 1,
                    'G' => 1,
                    'S' => 5,
                    'W' => 8,
                    '@' => -1,
                    '0' => -1,
                    'T' => -1
                )

# TODO test si file est bien un chemin vers un fichier map
function importFile(file::String)
    return [collect(line) for line in (readlines(file))[5:end]]
end

#=
Fonction booléenne retournant vrai si P est bien un point sur la carte
P | type : Tuple{Int64, Int64} | exemple : (12, 14)
height | type : Int64 | exemple : 49
width | type : Int64 | exemple : 49
=#
function isInMap(P::Tuple{Int64, Int64}, height::Int64, width::Int64)
    return 0 <= P[1] <= width && 0 <= P[2] <= height 
end 

#=
Fonction retournant les successeurs possibles de P 
(ne prend pas en compte les poids)
P | type : Tuple{Int64, Int64} | exemple : (12, 14)
height | type : Int64 | exemple : 49
width | type : Int64 | exemple : 49
=#
function successor(P::Tuple{Int64, Int64}, map)
    succ::Vector{Tuple{Int64,Int64}} = []
    for elem in [(P[1]-1,P[2]), (P[1]+1,P[2]), (P[1],P[2]+1), (P[1],P[2]-1)]
        if isInMap(elem,size(map)[1],size(map[1])[1]) && poidsCase[map[elem[1]][elem[2]]] != -1
            push!(succ,elem)
        end
    end
    return succ
end

function display(length_path::Int64, nb_states::Int64, path::Vector{Tuple{Int64,Int64}}, A::Tuple{Int64, Int64})
    println("Distance D -> A : ", length_path)
    println("Number of states evaluated : ", nb_states)
    print("Path D → A : ")
    for i in 1:length_path
        print(path[length_path-i+1], " -> ")
    end
    println(A)
end

# TODO Expliciter le raisonnement + faire les commentaires

function base0to1(P::Tuple{Int64, Int64})
    return (P[1]+1, P[2]+1)
end

function base1to0(P::Tuple{Int64, Int64})
    return (P[1]-1, P[2]-1)
end

#= 
fname | type : String | exemple : "didactic.map"
• D | type : Tuple{Int64, Int64} | exemple : (12, 14)
• A | type : Tuple{Int64, Int64} | exemple : (4, 5)"
=#
function algoBFS(fname::String, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64})

    # conversion en base (1,1) -> c'est-à-dire que la coordonnée du point en haut à gauche est (1,1)
    D = base0to1(D)
    A = base0to1(A)

    # importe la carte et en déduit ses dimensions
    map = importFile(fname)
    height::Int64 = size(map)[1]
    width::Int64 = size(map[1])[1]

    # vérifie sur D et A sont bien sur la carte
    isInMap(D,height,width) || throw(ArgumentError("Le départ n'est pas sur la carte"))
    isInMap(A,height,width) || throw(ArgumentError("L'arrivée n'est pas sur la carte"))
    
    # Début du parcours
    predecessor = Dict(D=>(-1,-1))                      # initialisation d'un dictionnaire avec le point de départ provenant d'une valeur non définie
    F = Queue{Tuple{Int64, Int64}}()            
    enqueue!(F, D)
    states = 0                                          # nombre d'états parcourus

    while !(isempty(F))
        u = dequeue!(F)
        states += 1

        if u == A
            v = u
            d = 0
            path::Vector{Tuple{Int64,Int64}} = []
            while predecessor[v] != (-1,-1)
                push!(path,base1to0(predecessor[v]))
                v = predecessor[v]
                d += 1
            end
            display(d,states,path,base1to0(A))
            return "Il existe un chemin de D -> A"

        else
            S = successor(u,map)
            for s in S
                if !(haskey(predecessor,s))
                    enqueue!(F,s)
                    predecessor[s] = u
                end
            end
        end    
    end
    return "Il n'existe pas de chemin de D -> A"                                         
end   

println(algoBFS("PathFinding/dat/dao-map/arena.map",(12,12),(15,14)))


