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

function verificationInput(fname::String, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64})

    # TODO vérifier si le fname est bien un fichier

    # importe la carte et en déduit ses dimensions
    map = importFile(fname)
    height::Int64 = size(map)[1]
    width::Int64 = size(map[1])[1]

    # vérifie sur D et A sont bien sur la carte et qu'ils ne sont pas infranchissables
    isInMap(D,height,width) || throw(ArgumentError("Le départ n'est pas sur la carte"))
    isInMap(A,height,width) || throw(ArgumentError("L'arrivée n'est pas sur la carte"))

    # vérifie si D et A sont des points accessibles
    poidsCase[map[D[2]][D[1]]] != -1 || throw(ArgumentError("Le départ n'est pas accessible"))
    poidsCase[map[A[2]][A[1]]] != -1 || throw(ArgumentError("L'arrivée n'est pas accessible"))

    return map
end

#=
Fonction retournant les successeurs possibles de P avec leur poids
P | type : Tuple{Int64, Int64} | exemple : (12, 14)
height | type : Int64 | exemple : 49
width | type : Int64 | exemple : 49
=#
function successor(P::Tuple{Int64, Int64}, map)
    succ::Vector{Tuple{Tuple{Int64,Int64},Int64}} = []
    for elem in [(P[1]-1,P[2]), (P[1]+1,P[2]), (P[1],P[2]+1), (P[1],P[2]-1)]
        p = poidsCase[map[elem[2]][elem[1]]]
        if isInMap(elem,size(map)[1],size(map[1])[1]) && p != -1     
            push!(succ,(elem,p))
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

#=
Fonction retournant la distance entre les points P et A
P | type : Tuple{Int64, Int64} | exemple : (12, 14)
A | type : Tuple{Int64, Int64} | exemple : (11, 13)
=#
function lenghtToA(P::Tuple{Int64, Int64}, A::Tuple{Int64,Int64})
    return sqrt((P[2]-A[2])^2 + (P[1]-A[1])^2)
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

    map = verificationInput(fname, D, A)
    
    # Début du parcours
    predecessor = Dict(D=>(-1,-1))                      # initialisation d'un dictionnaire avec le point de départ provenant d'un point non définie
    F = Queue{Tuple{Int64, Int64}}()            
    enqueue!(F, D)
    states = 0                                          # nombre d'états parcourus

    while !(isempty(F))
        u = dequeue!(F)
        states += 1

        if u == A
            v = u
            c = 0
            path::Vector{Tuple{Int64,Int64}} = []
            while predecessor[v] != (-1,-1)
                push!(path,base1to0(predecessor[v]))
                c += poidsCase[map[v[2]][v[1]]]
                v = predecessor[v]
            end
            display(c,states,path,base1to0(A))
            return "Il existe un chemin de D -> A"

        else
            S = successor(u,map)
            for s in S
                if !(haskey(predecessor,s[1]))
                    enqueue!(F,s[1])
                    predecessor[s[1]] = u
                end
            end
        end    
    end
    return "Il n'existe pas de chemin de D -> A"                                         
end

#= 
fname | type : String | exemple : "didactic.map"
• D | type : Tuple{Int64, Int64} | exemple : (12, 14)
• A | type : Tuple{Int64, Int64} | exemple : (4, 5)"
=#
function algoDijkstra(fname::String, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64}) 
    
    # conversion en base (1,1) -> c'est-à-dire que la coordonnée du point en haut à gauche est (1,1) 
    D = base0to1(D) 
    A = base0to1(A) 
    
    map = verificationInput(fname, D, A) 
    
    # Début du parcours
    
    L = PriorityQueue()                             # intialisation d'une file de priorité en fonction du poids pour au point 
    predecessor = Dict(D=>((-1,-1),-1))             # initialisation d'un dictionnaire avec le point de départ provenant d'un point et d'un chemin non définie 
    enqueue!(L, D, 0)                               # enfile le départ avec un poids de 0 
    states = 0                                      # nombre d'états parcourus 
    while !(isempty(L)) 
        u = dequeue!(L) 
        states += 1 
        
        if u == A 
            v = u 
            c = 0 
            path::Vector{Tuple{Int64,Int64}} = [] 
            while predecessor[v] != ((-1,-1),-1) 
                push!(path,base1to0(predecessor[v][1])) 
                c += poidsCase[map[v[2]][v[1]]] 
                v = predecessor[v][1] 
            end
            display(c,states,path,base1to0(A)) 
            return "Il existe un chemin de D -> A" 
        else S = successor(u,map) 
            for s in S 
                cost = s[2] + predecessor[u][2] 
                if !(haskey(predecessor,s[1])) && (!(haskey(L,s[1])) || L[s[1]] > cost) 
                    L[s[1]] = cost 
                    predecessor[s[1]] = (u,cost) 
                end
            end 
        end
    end
    return "Il n'existe pas de chemin de D -> A" 
end

function algoGlouton(fname::String, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64})

    # conversion en base (1,1) -> c'est-à-dire que la coordonnée du point en haut à gauche est (1,1)
    D = base0to1(D)
    A = base0to1(A)

    map = verificationInput(fname, D, A)

    # Début du parcours 
    FilePrio = PriorityQueue()                                         # intialisation d'une file de priorité en fonction du poids pour au point
    predecessor = Dict(D=>((-1,-1)))                            # initialisation d'un dictionnaire avec le point de départ provenant d'un point non définie avec sa distance en vol d'oiseau jusque FilePrio'arrivée      
    enqueue!(FilePrio, D, lenghtToA(D,A))                              # enfile le départ avec sa distance par rapport à FilePrio'arrivée
    states = 0                                                  # nombre d'états parcourus

    while !(isempty(FilePrio))
        u = dequeue!(FilePrio)
        states += 1

        if u == A
            v = u
            c = 0
            path::Vector{Tuple{Int64,Int64}} = []
            while predecessor[v] != (-1,-1)
                push!(path,base1to0(predecessor[v]))
                c += poidsCase[map[v[2]][v[1]]]
                v = predecessor[v]
            end
            display(c,states,path,base1to0(A))
            return "Il existe un chemin de D -> A"

        else
            S = successor(u,map)
            for s in S
                lenght = lenghtToA(s[1],A)
                if !(haskey(predecessor,s[1])) && (!(haskey(FilePrio,s[1])) || FilePrio[s[1]] > lenght)
                    FilePrio[s[1]] = lenght
                    predecessor[s[1]] = u
                end
            end
        end   
    end
    return "Il n'existe pas de chemin de D -> A" 
end

function algoAstar(fname::String, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64})

    # conversion en base (1,1) -> c'est-à-dire que la coordonnée du point en haut à gauche est (1,1) 
    D = base0to1(D) 
    A = base0to1(A) 
    
    map = verificationInput(fname, D, A) 
    
    # Début du parcours
    
    L = PriorityQueue()                             # intialisation d'une file de priorité en fonction du poids pour au point 
    predecessor = Dict(D=>((-1,-1),-1))             # initialisation d'un dictionnaire avec le point de départ provenant d'un point et d'un chemin non définie 
    enqueue!(L, D, lenghtToA(D,A))                               # enfile le départ avec un poids de 0 
    states = 0                                      # nombre d'états parcourus 
    while !(isempty(L)) 
        u = dequeue!(L) 
        states += 1 
        
        if u == A 
            v = u 
            c = 0 
            path::Vector{Tuple{Int64,Int64}} = [] 
            while predecessor[v] != ((-1,-1),-1) 
                push!(path,base1to0(predecessor[v][1])) 
                c += poidsCase[map[v[2]][v[1]]] 
                v = predecessor[v][1] 
            end
            display(c,states,path,base1to0(A)) 
            return "Il existe un chemin de D -> A" 
        else S = successor(u,map) 
            for s in S 
                cost = s[2] + predecessor[u][2] + lenghtToA(s[1],A)
                if !(haskey(predecessor,s[1])) && (!(haskey(L,s[1])) || L[s[1]] > cost) 
                    L[s[1]] = cost 
                    predecessor[s[1]] = (u,s[2] + predecessor[u][2])
                end
            end 
        end
    end
    return "Il n'existe pas de chemin de D -> A" 
end

# println(algoBFS("PathFinding/dat/dao-map/arena.map",(14,18),(22,18)),"\n")
println(algoDijkstra("PathFinding/dat/dao-map/lak100c.map",(172,462),(201,446)),"\n")
# println(algoGlouton("PathFinding/dat/dao-map/lak100c.map",(172,462),(201,446)),"\n")
println(algoAstar("PathFinding/dat/dao-map/lak100c.map",(172,462),(201,446)),"\n")

# test ssh