#= -----------------------------------------------------------------------------
PROJET : Simulation d'AMR (Autonomous Mobile Robots) | Path Finding
FICHIER : openFile.jl
DESCRIPTION : 
    Ce fichier permet d'ouvrir des fichiers '.map' et des fichiers '.txt'.
    Cependant, les fichiers '.txt' doivent contenir des instances d'un fichier '.map'.

DÉPENDANCE :
    - symbols.jl (Dictionnaire des poids et des couleurs)

AUTEUR : Mathieu LEROY
DERNIÈRE MODIFICATION : 08 Avril 2026
----------------------------------------------------------------------------- =#

#----- Dépendance -----
include("symbols.jl")

#= --------------------------------------------------------------
Fonction permettant d'ouvir un fichier '.map' et retourne :
- une matrice de couleur de la carte pour l'affichage
- un dictionnaire point -> (poids, intervalle de sécurité) pour le calcul de plus court chemin
- la hauteur et la longueur
fname | type : String | exemple : "version1.map"
=#
function openMap(fname::String)

    lines = readlines(fname)[5:end]                         # la carte commence à partir de la 5ème ligne
    
    # dimensions pour la structure Instance
    height = length(lines)
    width = length(lines[1])

    dict_map = Dict{Tuple{Int64, Int64}, Case}()
       
    img = Matrix{RGB{Float64}}(undef, height, width)

    for (i, line) in enumerate(lines)
        for (j, char) in enumerate(line)
            weight = get!(pointWeight,char,nothing)                 
            img[i, j] = get(colorMapping, char, RGB(0,0,0))                                 # donne la couleur noir au point si le symbole n'est pas reconnu
            weight !== nothing || throw(error("Le symbole '$symbol' n'est pas reconnu."))
            if weight != -1
                dict_map[(i, j)] = Case(weight)
            end
        end
    end

    return img, dict_map, height, width
end

#= --------------------------------------------------------------
Fonction permettant d'ouvir un fichier '.txt' contenant une instance
Retourne une Instance avec la carte et les AMR données
fname | type : String | exemple : "version1-instance1.map"
=#
function openInstance(fname::String)
    
    # Initialisation des paramètres d'une Instance
    departureTimes = Int64[]
    dock = Tuple{Int64, Int64}[]
    destinations = Tuple{Int64, Int64}[]
    local map
    local displayMap
    height = 0
    width = 0

    open("dat/robot-instance/"*fname, "r") do file

        readline(file)                                              # passe les commentaires
        mname = readline(file)
        (displayMap, map, height, width) = openMap("dat/robot-map/"*string(mname))
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
    return Instance(fname, dock, departureTimes, destinations, displayMap, map, height, width)
end

# ----- TEST -----
# println(openInstance("version1-instance1.txt"))
# println(openInstance("version2-instance1.txt"))