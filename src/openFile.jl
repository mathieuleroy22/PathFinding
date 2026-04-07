# importations des différentes structures
include("datastructures.jl")

# TODO CHOISIR OU ON SE SITUE DANS L'ARBORESENCE POUR FAIRE LES PATHS

#=
Fonction retournant un tableau de lignes constituant la carte
fname | type : String | exemple : "didactic.map"
=#
function openMap(fname::String)

    lines = readlines(fname)[5:end]                         # la carte commence à partir de la 5ème ligne
    
    dict_map = Dict{Tuple{Int64, Int64}, Case}()
    
    # dimensions pour la structure Instance
    height = length(lines)
    width = length(lines[1])
    
    img = Matrix{RGB{Float64}}(undef, height, width)

    for (i, line) in enumerate(lines)
        for (j, char) in enumerate(line)
            weight = get!(pointWeight,char,nothing)
            weight !== nothing || throw(error("Le symbole '$symbol' n'est pas reconnu."))
            img[i, j] = get(colorMapping, char, RGB(0,0,0))
            if weight != -1
                dict_map[(i, j)] = Case(weight)
            end
        end
    end

    return img, dict_map, height, width
end

#=
Fonction retournant une instance en fonction du fichier choisi
fname | type : String | exemple : "didactic.map"
=#
function openInstance(fname::String)

    # TODO vérifier si le fname est bien défini
    
    departureTimes = Int64[]
    dock = Tuple{Int64, Int64}[]
    destinations = Tuple{Int64, Int64}[]
    local map
    local displayMap
    height = 0
    width = 0

    open(fname, "r") do file

        readline(file)                                              # passe les commentaires
        mname = readline(file)
        (displayMap, map, height, width) = openMap("PathFinding/dat/robot-map/"*string(mname))
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
            # TODO expliquer l'inversion des x y
        end
    end

    # Création de l'objet (le constructeur interne s'occupe du tri par temps)
    return Instance(fname, dock, departureTimes, destinations, displayMap, map, height, width)
end

# println(openInstance("PathFinding/dat/robot-instance/version1-instance1.txt"))