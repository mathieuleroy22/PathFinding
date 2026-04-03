# importations des différentes structures
include("datastructures.jl")
include("openFile.jl")
include("shifting.jl")
include("display.jl")

function main(fname::String)

    # importe l'instance dans fname
    instance::Instance = openInstance(fname)

    currentAmr = Vector{AMR}()
    pathAmr = Vector{Solution}()
    time = 0
    id = 1                          # id définissant un AMR et sa priorité par rapport à un autre AMR

    while !(isempty(instance.departureTime))      # tant qu'il y a des AMR en attente
        while !(isempty(instance.departureTime)) && instance.departureTime[1] == time
            
            # création d'un AMR
            timeAmr = popfirst!(instance.departureTime)
            dockAmr = popfirst!(instance.dock)
            destinationAmr = popfirst!(instance.destination)
            roadAmr = algoAstarAMR(instance.map, dockAmr, destinationAmr)
            push!(currentAmr,AMR(id,timeAmr,dockAmr,destinationAmr,roadAmr))

            # création de sa solution
            road::Vector{Tuple{Int64,Int64}} = [dockAmr]
            push!(pathAmr,Solution(id,road,timeAmr))

            # change l'id pour le prochain AMR
            id += 1
        end
        currentAmr = movement(instance.map,currentAmr,pathAmr)
        time += 1
    end

    while !(isempty(currentAmr))                    # tant qu'il y a des AMR sur la map
        currentAmr = movement(instance.map,currentAmr,pathAmr)
        time+=1
    end

    for solution in pathAmr
        println(solution.road)
    end
end

println(main("PathFinding/dat/robot-instance/version1-instance1.txt"))