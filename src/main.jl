# importations des différentes structures
include("datastructures.jl")
include("openFile.jl")
include("shifting.jl")
include("display.jl")
include("colors.jl")

function main(fname::String)

    # importe l'instance dans fname
    instance::Instance = openInstance(fname)

    currentAmr = Vector{AMR}()
    time = 0
    id = 1                          # id définissant un AMR et sa priorité par rapport à un autre AMR

    while !(isempty(instance.departureTime))      # tant qu'il y a des AMR en attente
        
        # création d'un AMR
        timeAmr = popfirst!(instance.departureTime)
        dockAmr = popfirst!(instance.dock)
        destinationAmr = popfirst!(instance.destination)
        roadAmr = astarAMR(instance.map, dockAmr, destinationAmr, timeAmr)
        push!(currentAmr,AMR(id,couleur_aleatoire_unique(),timeAmr,dockAmr,destinationAmr,roadAmr))

        # change l'id pour le prochain AMR
        id += 1
    end
    for amr in currentAmr
        println(amr.road)
    end

    # Exemple d'appel direct
    animate_amr_paths(instance.displayMap, currentAmr, speed=1)
end

println(main("PathFinding/dat/robot-instance/version2-instance1.txt"))