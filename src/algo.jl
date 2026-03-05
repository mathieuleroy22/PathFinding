using DataStructures

# TODO nom anglais

#= Dictionnaire associant à chaque caractere son poids
la valeur -1 est donnée pour les caracteres infranchissables =#
pointWeight = Dict(   '.' => 1,
                    'G' => 1,
                    'S' => 5,
                    'W' => 8,
                    '@' => -1,
                    '0' => -1,
                    'T' => -1
                )

#=
Fonction retournant un tableau de lignes constituant la carte
fname | type : String | exemple : "didactic.map"
=#
function importFile(fname::String)
    return [collect(line) for line in (readlines(fname))[5:end]]    # les 5 premières lignes ne sont pas des éléments de la carte
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
Fonction retournant la carte si les entrées sont correctes
sinon renvoie une erreur
fname | type : String | exemple : "didactic.map"
• D | type : Tuple{Int64, Int64} | exemple : (12, 14)
• A | type : Tuple{Int64, Int64} | exemple : (4, 5)"
=#
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
    pointWeight[map[D[2]][D[1]]] != -1 || throw(ArgumentError("Le départ n'est pas accessible"))
    pointWeight[map[A[2]][A[1]]] != -1 || throw(ArgumentError("L'arrivée n'est pas accessible"))

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
        p = pointWeight[map[elem[2]][elem[1]]]
        if isInMap(elem,size(map)[1],size(map[1])[1]) && p != -1     
            push!(succ,(elem,p))
        end
    end
    return succ
end

#=
Fonction réalisant l'affichage du résultat
weightPath | type : Int64 | exemple : 2
nbStates | type : Int64 | exemple : 10
path | type : Vector{Tuple{Int64,Int64}} | exemple : [(12,13),(12,12)]
A | type : Tuple{Int64, Int64} | exemple : (12,14)
=#
function display(weightPath::Int64, nbStates::Int64, path::Vector{Tuple{Int64,Int64}}, A::Tuple{Int64, Int64})
    println("Distance D -> A : ", weightPath)
    println("Number of nbStates evaluated : ", nbStates)
    print("Path D → A : ")
    l = length(path)
    for i in 1:l
        print(path[l-i+1], " -> ")                   # le départ est le dernier élément de path      
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

#=
Fonction passant de la base (0,0) à la base (1,1)
-> voir documentation pour les explications
=#
function base0to1(P::Tuple{Int64, Int64})
    return (P[1]+1, P[2]+1)
end

#=
Fonction passant de la base (1,1) à la base (0,0)
-> voir documentation pour les explications
=#
function base1to0(P::Tuple{Int64, Int64})
    return (P[1]-1, P[2]-1)
end

#=
Fonction affichant le chemin entre D et A sur la map de fname en suivant l'algorthme BFS et affiche le résultat
fname | type : String | exemple : "didactic.map"
• D | type : Tuple{Int64, Int64} | exemple : (12, 14)
• A | type : Tuple{Int64, Int64} | exemple : (4, 5)"
=#
function algoBFS(fname::String, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64})

    # conversion en base (1,1)
    D = base0to1(D)
    A = base0to1(A)

    # vérification des entrées
    map = verificationInput(fname, D, A)        
    
    # Début du parcours
    predecessor = Dict(D=>(-1,-1))                      # initialisation d'un dictionnaire avec le départ provenant d'un point non définie
    F = Queue{Tuple{Int64, Int64}}()                    # initialisation d'une file pour stocker les points à visiter
    enqueue!(F, D)                              
    nbStates = 0                                          # nombre de points visité lors du parcours

    while !(isempty(F))

        u = dequeue!(F)
        nbStates += 1

        if u == A

            v = u
            weightPath = 0
            path::Vector{Tuple{Int64,Int64}} = [A]
            while predecessor[v] != (-1,-1)                         # le chemin s'arrête lorsque l'on retrouve D (son prédécesseur étant (-1,-1) par définition)
                push!(path,base1to0(predecessor[v]))                # conversion en base (0,0) pour l'affichage
                weightPath += pointWeight[map[v[2]][v[1]]]       
                v = predecessor[v]
            end
            display(weightPath,nbStates,path,base1to0(A))             # conversion en base (0,0) pour l'affichage
            return "Il existe un chemin de D -> A"

        else
            Succ = successor(u,map)                                    # récupère tous les successeurs de u
            for succ in Succ                            
                if !(haskey(predecessor,succ[1]))                       # si le successeur n'a pas déjà été vu
                    enqueue!(F,succ[1])
                    predecessor[succ[1]] = u
                end
            end
        end    
    end
    return "Il n'existe pas de chemin de D -> A"                                         
end

#=
Fonction affichant le chemin entre D et A sur la map de fname en suivant l'algorthme de Dijkstra et affiche le résultat
fname | type : String | exemple : "didactic.map"
• D | type : Tuple{Int64, Int64} | exemple : (12, 14)
• A | type : Tuple{Int64, Int64} | exemple : (4, 5)"
=#
function algoDijkstra(fname::String, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64}) 
    
    # conversion en base (1,1) -> c'est-à-dire que la coordonnée du point en haut à gauche est (1,1) 
    D = base0to1(D) 
    A = base0to1(A) 
    
    # vérification des entrées
    map = verificationInput(fname, D, A) 
    
    # Début du parcours
    
    FilePrio = PriorityQueue()                             # intialisation d'une file de priorité en fonction du poids de chemin pour y parvenir depuis D
    predecessor = Dict(D=>((-1,-1),0))              # initialisation d'un dictionnaire avec le point de départ provenant d'un point non définie et d'un poids de 0 entre D et D 
    FilePrio[D] = 0                               
    nbStates = 0                                    # nombre de points visité lors du parcours

    while !(isempty(FilePrio))

        u = dequeue!(FilePrio) 
        nbStates += 1 
        
        if u == A

            v = u
            weightPath = 0
            path::Vector{Tuple{Int64,Int64}} = [A]
            while predecessor[v] != ((-1,-1),0)                         # le chemin s'arrête lorsque l'on retrouve D (son prédécesseur étant (-1,-1) par définition)
                push!(path,base1to0(predecessor[v][1]))                # conversion en base (0,0) pour l'affichage
                weightPath += pointWeight[map[v[2]][v[1]]]       
                v = predecessor[v][1]
            end
            display(weightPath,nbStates,path,base1to0(A))             # conversion en base (0,0) pour l'affichage
            return "Il existe un chemin de D -> A" 

        else 
            Succ = successor(u,map) 
            for succ in Succ
                cost = succ[2] + predecessor[u][2]                                                                  # coût de succ devient son poids + le poids du chemin pour arriver à u
                if !(haskey(predecessor,succ[1])) && (!(haskey(FilePrio,succ[1])) || FilePrio[succ[1]] > cost)      # si succ n'a pas déjà un chemin (plus court) pour y arriver dans predecessor et si il n'est pas dans la file de priorité ou alors que sa priorité est plus grande que celle calculée
                    FilePrio[succ[1]] = cost                                                                        
                    predecessor[succ[1]] = (u,cost) 
                end
            end 
        end
    end
    return "Il n'existe pas de chemin de D -> A" 
end

#=
Fonction affichant le chemin entre D et A sur la map de fname en suivant l'algorthme Glouton et affiche le résultat
fname | type : String | exemple : "didactic.map"
• D | type : Tuple{Int64, Int64} | exemple : (12, 14)
• A | type : Tuple{Int64, Int64} | exemple : (4, 5)"
=#
function algoGlouton(fname::String, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64})

    # conversion en base (1,1) -> c'est-à-dire que la coordonnée du point en haut à gauche est (1,1)
    D = base0to1(D)
    A = base0to1(A)

    # vérification des entrées
    map = verificationInput(fname, D, A)

    # Début du parcours 
    FilePrio = PriorityQueue()                                          # intialisation d'une file de priorité en fonction du poids pour au point
    predecessor = Dict(D=>((-1,-1)))                                    # initialisation d'un dictionnaire avec le point de départ provenant d'un point non défini   
    FilePrio[D] = lenghtToA(D,A)                                        # enfile le départ avec sa distance par rapport à l'arrivée
    nbStates = 0                                                        # nombre de points visité lors du parcours

    while !(isempty(FilePrio))

        u = dequeue!(FilePrio)
        nbStates += 1

        if u == A

            v = u
            weightPath = 0
            path::Vector{Tuple{Int64,Int64}} = [A]
            while predecessor[v] != (-1,-1)                               # le chemin s'arrête lorsque l'on retrouve D (son prédécesseur étant (-1,-1) par définition)
                push!(path,base1to0(predecessor[v]))                   # conversion en base (0,0) pour l'affichage
                weightPath += pointWeight[map[v[2]][v[1]]]       
                v = predecessor[v]
            end
            display(weightPath,nbStates,path,base1to0(A))             # conversion en base (0,0) pour l'affichage
            return "Il existe un chemin de D -> A"

        else
            Succ = successor(u,map)
            for succ in Succ
                lenght = lenghtToA(succ[1],A)
                if !(haskey(predecessor,succ[1]))                           # si le successeur n'a pas déjà été vu
                    FilePrio[succ[1]] = lenght
                    predecessor[succ[1]] = u
                end
            end
        end   
    end
    return "Il n'existe pas de chemin de D -> A" 
end

#=
Fonction affichant le chemin entre D et A sur la map de fname en suivant l'algorthme Astar et affiche le résultat
fname | type : String | exemple : "didactic.map"
• D | type : Tuple{Int64, Int64} | exemple : (12, 14)
• A | type : Tuple{Int64, Int64} | exemple : (4, 5)"
=#
function algoAstar(fname::String, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64})

    # conversion en base (1,1) -> c'est-à-dire que la coordonnée du point en haut à gauche est (1,1) 
    D = base0to1(D) 
    A = base0to1(A) 
    
    # vérification des entrées
    map = verificationInput(fname, D, A) 
    
    # Début du parcours
    FilePrio = PriorityQueue()                                             # intialisation d'une file de priorité en fonction du poids pour au point 
    predecessor = Dict(D=>((-1,-1),0))                             # initialisation d'un dictionnaire avec le point de départ provenant d'un point non définie et d'un poids de 0 entre D et D
    FilePrio[D] = lenghtToA(D,A) + 0                                 
    nbStates = 0                                                    # nombre d'états parcourus

    while !(isempty(FilePrio))

        u = dequeue!(FilePrio) 
        nbStates += 1 
        
        if u == A

            v = u
            weightPath = 0
            path::Vector{Tuple{Int64,Int64}} = [A]
            while predecessor[v] != ((-1,-1),0)                         # le chemin s'arrête lorsque l'on retrouve D (son prédécesseur étant (-1,-1) par définition)
                push!(path,base1to0(predecessor[v][1]))                # conversion en base (0,0) pour l'affichage
                weightPath += pointWeight[map[v[2]][v[1]]]       
                v = predecessor[v][1]
            end
            display(weightPath,nbStates,path,base1to0(A))             # conversion en base (0,0) pour l'affichage
            return "Il existe un chemin de D -> A"

        else 
            Succ = successor(u,map) 
            for succ in Succ
                cost = succ[2] + predecessor[u][2]
                prio = cost + lenghtToA(succ[1],A)                           # 
                if !(haskey(predecessor,succ[1])) && (!(haskey(FilePrio,succ[1])) || FilePrio[succ[1]] > prio) 
                    FilePrio[succ[1]] = prio 
                    predecessor[succ[1]] = (u,cost)
                end
            end 
        end
    end
    return "Il n'existe pas de chemin de D -> A" 
end

println(algoBFS("PathFinding/dat/dao-map/lak100c.map",(172,462),(201,446)),"\n")
println(algoDijkstra("PathFinding/dat/dao-map/lak100c.map",(172,462),(201,446)),"\n")
println(algoGlouton("PathFinding/dat/dao-map/lak100c.map",(172,462),(201,446)),"\n")
println(algoAstar("PathFinding/dat/dao-map/lak100c.map",(172,462),(201,446)),"\n")