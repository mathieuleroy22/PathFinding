#= -----------------------------------------------------------------------------
PROJET : Simulation d'AMR (Autonomous Mobile Robots) | Path Finding
FICHIER : main.jl
DESCRIPTION : 
    Point d'entrée principal du programme. Ce fichier gère l'initialisation 
    de la carte, la planification séquentielle des trajectoires via SIPP/A* et l'exportation des données de simulation.

DÉPENDANCES :
    - datastructures.jl (Structures Case, SafeInterval, AMR)
    - openFile.jl       (Chargement des instances (.map / .txt))
    - shifting.jl       (Algorithme astarAMR et updateInterval)
    - display.jl        (Algorithme animate_amr_paths, exportMap et exportAMR)
    - colors.jl         (Algorithme couleur_aleatoire_unique)


AUTEUR : Mathieu LEROY
DERNIÈRE MODIFICATION : 08 Avril 2026
----------------------------------------------------------------------------- =#

#----- Dépendances -----
include("datastructures.jl")
include("openFile.jl")
include("shifting.jl")
include("display.jl")
include("colors.jl")

#= --------------------------------------------------------------
Fonction principale orchestrant la simulation complète du routage des AMR
Ne retourne rien, affiche une animation du déplacement des AMR et écrit les résultats dans le dossier 'out'
fname | type : String | exemple : "version1-instance1.txt"
=#
function main(fname::String)

    instance::Instance = openInstance(fname)        # importe l'instance de fname

    currentAmr = Vector{AMR}()         
    id = 1                                          # id définissant un AMR et sa priorité par rapport à un autre AMR

    while !(isempty(instance.departureTime))        # tant qu'il y a des AMR en attente
        
        # création d'un AMR
        timeAmr = popfirst!(instance.departureTime)
        dockAmr = popfirst!(instance.dock)
        destinationAmr = popfirst!(instance.destination)
        roadAmr = astarAMR(instance.map, dockAmr, destinationAmr, timeAmr)
        colorAmr = couleur_aleatoire_unique()
        push!(currentAmr,AMR(id,colorAmr,timeAmr,dockAmr,destinationAmr,roadAmr))

        id += 1                                     # change l'id pour le prochain AMR
    end

    # animation visuelle du déplacement des AMR
    animateAMR(instance.displayMap, currentAmr, speed=1)

    # exportation des résultats
    exportMap(instance.displayMap)
    exportAMR(currentAmr)

    return nothing
end

# ----- TEST -----
# println(main("version1-instance1.txt"))
# println(main("version2-instance1.txt"))