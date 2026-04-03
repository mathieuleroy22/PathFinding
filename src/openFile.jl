# importations des différentes structures
include("datastructures.jl")

# TODO CHOISIR OU ON SE SITUE DANS L'ARBORESENCE POUR FAIRE LES PATHS

#=
Fonction retournant un tableau de lignes constituant la carte
fname | type : String | exemple : "didactic.map"
=#
function openMap(fname::String)
    return [collect(line) for line in (readlines(fname))[5:end]]    # les 5 premières lignes ne sont pas des éléments de la carte
end

#=
Fonction retournant une instance en fonction du fichier choisi
fname | type : String | exemple : "didactic.map"
=#
function openInstance(fname::String)

    # TODO vérifier si le fname est bien défini
    fullPath = joinpath(fname)
    
    departureTimes = Int64[]
    dock = Tuple{Int64, Int64}[]
    destinations = Tuple{Int64, Int64}[]
    local map

    open(fullPath, "r") do file

        readline(file)                                              # passe les commentaires
        mname = readline(file)
        map = openMap("PathFinding/dat/robot-map/"*string(mname))
        readline(file)                                              # passe les commentaires

        for line in eachline(file)
            
            if isempty(strip(line)) continue end        # ignore les lignes vides

            # Extraction des chiffres : t, x1, y1, x2, y2
            nums = [parse(Int64, m.match) for m in eachmatch(r"-?\d+", line)]

            if length(nums) >= 5
                push!(departureTimes, nums[1])
                push!(dock, (nums[2], nums[3]))
                push!(destinations, (nums[4], nums[5]))
            end
        end
    end

    # Création de l'objet (le constructeur interne s'occupe du tri par temps)
    return Instance(fname, dock, departureTimes, destinations, map)
end

# println(openInstance("PathFinding/dat/robot-instance/version1-instance1.txt"))