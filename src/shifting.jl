#= -----------------------------------------------------------------------------
PROJET : Simulation d'AMR (Autonomous Mobile Robots) | Path Finding
FICHIER : shifting.jl
DESCRIPTION : 
    Ce fichier permet le calcul du plus court chemin de chaque AMR.

AUTEUR : Mathieu LEROY
DERNIÈRE MODIFICATION : 08 Avril 2026
----------------------------------------------------------------------------- =#

#----- Package -----
using DataStructures

#= --------------------------------------------------------------
Fonction trouvant le plus court chemin entre D et A (à partir du temps time)
sur une carte en suivant l'algorithme SIPP (A* modifié).
Modifie les intervalles de sécurité après chaque passage d'un AMR.
Renvoie le chemin dans un tableau de points
map | type : Dict{Tuple{Int64, Int64}, Case} | exemple : ((5, 19) => Case(1, ...))
D | type : Tuple{Int64, Int64} | exemple : (1, 1)
A | type : Tuple{Int64, Int64} | exemple : (2, 2)
time | type : Int64 | exemple : 0
=#
function astarAMR(map::Dict{Tuple{Int64, Int64}, Case}, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64}, time::Int64) 
    
    # Etat initial, tuple (Point, Temps)
    startState = (D, time)
    
    # Initialisation des structures
    permanent = Set{Tuple{Tuple{Int64, Int64}, Int64}}()                                                                        # Tableau permettant de savoir si un (Point, Temps) a déjà été visité
    FilePrio = PriorityQueue{Tuple{Tuple{Int64, Int64}, Int64}, Float64}()                                                      # File de priorité pour savoir quel (Point, Temps) considéré en premier en fonction d'une heuristique
    predecessor = Dict{Tuple{Tuple{Int64, Int64}, Int64}, Tuple{Tuple{Int64, Int64}, Int64}}(startState => ((-1, -1), -1))      # Dictionnaire donnant le prédécesseur d'un (Point, Temps)
    
    FilePrio[startState] = Float64(time + distancePoint(D, A))          # Ajout du départ avec l'heuristique (temps pour accéder à la case + distance entre la case et A)

    while !(isempty(FilePrio))

        current_state = dequeue!(FilePrio)                              # Défile le (Point, Temps) avec la priorité la plus proche de 0
        (point, t) = current_state 

        if !(current_state in permanent)                                # Si le (Point, Temps) n'a pas déjà été visité, on l'ajoute dans permanent
            push!(permanent, current_state)
        
            if point == A

                # Reconstruction du chemin
                pathWithTime = []
                p = current_state
                while predecessor[p] != ((-1, -1), -1)                  # Cherche les prédécesseurs de chaque (Point, Temps) jusqu'à (D, time) avec un prédécesseur indéfini
                    pushfirst!(pathWithTime, p) 
                    p = predecessor[p]
                end
                pushfirst!(pathWithTime, (D, time))
                
                updateInterval(map, pathWithTime)                    # Modifie les intervalles de sécurité avec le chemin pour les prochains AMR

                return [p[1] for p in pathWithTime]                  # Retourne seulement les points sans leur temps
            end

            # Récupération de l'intervalle pour le point et le temps actuel
            currentIntervalID = getIntervalID(map[point], t)
            currentInterval = map[point].safeInterval[currentIntervalID]

            for (neighbor, neighborTime) in successorSIPP(point, currentInterval, t, map)

                # Si le (Point, Temps) n'a pas déjà été visité et ne pas écraser un chemin valide trouvé plus tôt           
                if !((neighbor, neighborTime) in permanent) && !haskey(predecessor, (neighbor, neighborTime))
                    predecessor[(neighbor, neighborTime)] = current_state      
                    FilePrio[(neighbor, neighborTime)] = Float64(neighborTime + distancePoint(neighbor, A))                 # Ajout à la file de priorité avec l'heuristique         
                end

            end
        end 
    end
    throw(error("Il n'y a pas de chemin entre "*string(D)*" et "*string(A)))
end

#= --------------------------------------------------------------
Fonction retournant la distance entre les points P et A
P | type : Tuple{Int64, Int64} | exemple : (12, 14)
A | type : Tuple{Int64, Int64} | exemple : (11, 13)
=#
function distancePoint(P::Tuple{Int64, Int64}, A::Tuple{Int64,Int64})
    return sqrt((P[2]-A[2])^2 + (P[1]-A[1])^2)
end

#= --------------------------------------------------------------
Fonction générant les successeurs valides (états voisins) pour un AMR
à partir d'une position et d'un temps donnés, selon l'algorithme SIPP.
Vérifie la disponibilité des intervalles de sécurité des cases voisines 
et empêche les collisions frontales (swaps) via une condition dynamique.
Renvoie un vecteur de tuples contenant la position et le temps d'arrivée.
P | type : Tuple{Int64, Int64} | exemple : (5, 19)
currentInterval | type : SafeInterval | exemple : SafeInterval(1, 0.0, 100.0)
time | type : Int64 | exemple : 7
map | type : Dict{Tuple{Int64, Int64}, Case} | exemple : ((5, 19) => Case(1, ...))
=#
function successorSIPP(P::Tuple{Int64, Int64}, currentInterval::SafeInterval, time::Int64, map::Dict{Tuple{Int64, Int64}, Case})
    
    succ = Vector{Tuple{Tuple{Int64, Int64}, Int64}}()      # Initialisation d'un vector (Point, Temps)

    # Vérifie si t+1 est toujours dans l'intervalle de sécurité de la case actuelle, si oui on l'ajoute au successeur de (P, time)
    nextTime = time + map[P].weight
    if nextTime <= currentInterval.end_t
        push!(succ, (P, nextTime))
    end

    # Vérifie si les déplacements en à gauche, à droite, en bas et en haut sont possibles
    for neighbor in [(P[1]-1,P[2]), (P[1]+1,P[2]), (P[1],P[2]+1), (P[1],P[2]-1)]           
        
        if haskey(map, neighbor)                # si le voisin est sur la carte
            neighborCase = map[neighbor]
            nextTime = time + neighborCase.weight    # le déplacement entre P et son voisin dépend du poids de son voisin
            
            for neighborInterval in neighborCase.safeInterval
                if neighborInterval.start_t <= nextTime <= neighborInterval.end_t                   # Vérifie si le prochain temps est dans un intervalle de sécurité du voisin
                    
                    # Vérifie un swap est réalisé    
                    if !isInInterval(neighborCase, time) && !isInInterval(map[P], nextTime)         # Si le voisin est bloqué à l'instant 'time' ET que ma case actuelle sera bloquée à l'instant 'nextTime', c'est un croisement frontal !
                        break # Rejette ce mouvement et sort de la boucle neighborInterval
                    end
                    
                    # Si ce n'est pas un swap, le mouvement est valide
                    push!(succ, (neighbor, nextTime))
                    break 
                end
            end
        end
    end
    return succ
end

#= --------------------------------------------------------------
Fonction retournant vrai si interval est compris dans [t_start, t_end]
faux sinon
interval | type : SafeInterval | exemple : SafeInterval(1, 0.0, 100.0)
t_start | type : Int64 | exemple : 7
t_send | type : Int64 | exemple : 8
=#
function isContained(interval::SafeInterval, t_start::Int64, t_end::Int64)
    return interval.start_t <= t_start && t_end <= interval.end_t
end

#= --------------------------------------------------------------
Fonction retournant vrai si un intervalle de sécurité d'une Case
contient time
c | type : Case | exemple : Case(1, ...)
time | type : Int64 | exemple : 7
=#
function isInInterval(c::Case, time::Int64)
    for inv in c.safeInterval
        if isContained(inv, time, time + c.weight -1)
            return true # Un intervalle de sécurité contient time
        end
    end
    return false # Collision inévitable sur cette case à ces temps-là
end

#= --------------------------------------------------------------
Fonction retournant l'ID de l'intervalle de sécurité contenant le temps "time"
Renvoie l'ID sous forme d'Int64, ou -1 si non trouvé
c | type : Case | exemple : Case('.')
time | type : Int64 | exemple : 10
=#
function getIntervalID(c::Case, time::Int64)
    for interval in c.safeInterval
        if interval.start_t <= time <= interval.end_t
            return interval.id
        end
    end
    return -1
end

#= --------------------------------------------------------------
Fonction modifiant la carte pour réserver le passage de cet AMR
map | type : Dict{Tuple{Int64, Int64}, Case} | exemple : ((5, 19) => Case(1, ...))
pathWithTime | type : Vector{Tuple{Tuple{Int64, Int64}, Int64}} | exemple : [((1,1)1),((1,2),2)]
=#
function updateInterval(map, pathWithTime)
    
    for i in 1:length(pathWithTime)
        pos, t_in = pathWithTime[i]
        
        # Pour éviter les échanges de place, on bloque la case actuelle 
        # jusqu'à ce que l'AMR soit totalement arrivé sur la case suivante.
        if i < length(pathWithTime)
            t_out = pathWithTime[i+1][2] - 1
        else
            t_out = typemax(Int64) # Destination finale bloquée
        end

        case = map[pos]
        new_intervals = Vector{SafeInterval}()
        id_count = 1

        for interval in case.safeInterval

            # Si l'intervalle est totalement en dehors de l'occupation
            if interval.end_t < t_in || interval.start_t > t_out
                push!(new_intervals, SafeInterval(id_count, interval.start_t, interval.end_t))
                id_count += 1
            else

                # Découpe en deux (avant et après l'occupation)
                if interval.start_t < t_in
                    push!(new_intervals, SafeInterval(id_count, interval.start_t, Float64(t_in - 1)))
                    id_count += 1
                end
                if interval.end_t > t_out
                    push!(new_intervals, SafeInterval(id_count, Float64(t_out + 1), interval.end_t))
                    id_count += 1
                end
            end
        end
        case.safeInterval = new_intervals
    end
end