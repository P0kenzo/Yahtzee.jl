function choix_combinaison(combinaisons_possibles::Vector{Int64})
    println("Choisir une combinaison, entrer son ID [plus petit id] :")
    id_choisi = readline()
    if id_choisi == ""
        id_choisi = "0"
    end
    id_choisi = parse.(Int64, id_choisi)
    # check si id_choisi dans combi_possibles, faire un while pour redemander
    while id_choisi ∉ combinaisons_possibles && id_choisi != 0
        println("Mauvais id, réessayez :")
        id_choisi = readline()
        if id_choisi == ""
            id_choisi = "0"
        end
        id_choisi = parse.(Int64, id_choisi)
    end
    if id_choisi == 0
        id_choisi = minimum(combinaisons_possibles)
    end
    return id_choisi
end

Base.occursin(needle::Vector{Int64}, haystack::Vector{Int64}) = occursin(join(needle, ","), join(haystack, ","))

function combinaison(lancer::Vector{Int64}, liste_id::Vector{Int64})
    CompteurDes=[]
    for valeur in range(1,6)
        comptage = 0
        for de in lancer
            if de == valeur
                comptage = comptage + 1
            end
        end
        append!(CompteurDes, comptage)
    end
    
    DePresent = Vector{Int64}()
    for element in CompteurDes
        if element > 0
            append!(DePresent, 1)
        else
            append!(DePresent, 0)
        end
    end

    Points_combinaisons = []
    for id in liste_id
        if id <= 6 # Chiffres de 1 à 6
            append!(Points_combinaisons, CompteurDes[id] * id)
        elseif id == 7 # Brelan
            if 3 in CompteurDes || 4 in CompteurDes || 5 in CompteurDes
                append!(Points_combinaisons, sum(lancer))
            else
                append!(Points_combinaisons, 0)
            end
        elseif id == 8 # Carré
            if 4 in CompteurDes || 5 in CompteurDes
                append!(Points_combinaisons, sum(lancer))
            else
                append!(Points_combinaisons, 0)
            end
        elseif id == 9 # Full
            if (3 in CompteurDes && 2 in CompteurDes) || 5 in CompteurDes
                append!(Points_combinaisons, 25)
            else
                append!(Points_combinaisons, 0)
            end
        elseif id == 10 # Petite suite
            if occursin([1, 1, 1, 1], DePresent)
                append!(Points_combinaisons, 30)
            else
                append!(Points_combinaisons, 0)
            end
        elseif id == 11 # Grande suite
            if occursin([1, 1, 1, 1, 1], DePresent)
                append!(Points_combinaisons, 40)
            else
                append!(Points_combinaisons, 0)
            end
        elseif id == 12 # Yahtzee
            if 5 in CompteurDes
                append!(Points_combinaisons, 50)
            else
                append!(Points_combinaisons, 0)
            end
        elseif id == 13 # Chance
            append!(Points_combinaisons, sum(lancer))
        end
    end
    return Points_combinaisons
end

function Deroule_manche!(partie::DataFrame, manche::Int64, combi_possibles::DataFrame)
    lancer = rand(1:6,5)
    essai = DataFrame(Manche = manche, Tour = 1, De_1 = lancer[1], De_2 = lancer[2], De_3 = lancer[3], De_4 = lancer[4], De_5 = lancer[5])
    append!(partie, essai)

    println("Tour nº 1 :")
    println(lancer)
    id_possibles = Vector{Int64}(combi_possibles[:,1])
    for num_relance in range(1,2)
        println("Total des combinaisons possibles :")

        points = combinaison(lancer, id_possibles)
        TAB_possible = DataFrame(ID = combi_possibles[:,1], Combinaison = combi_possibles[:,2], Points = points)
        println(TAB_possible)
        println("Voulez-vous relancer des dés ? Y/N [Y]")
        reponse = readline()
        if reponse == ""
            reponse = "Y"
        elseif reponse == "N"
            id_choisi = choix_combinaison(id_possibles)
            points_choisis = points[findfirst(id_possibles.==id_choisi)]
            return id_choisi, points_choisis
        end
        println("Choisissez les dés à relancer : (lister la position des dés séparés par des virgules, taper X pour annuler) [Tout relancer]")
        liste_relance = readline()
        if liste_relance == ""
            liste_relance = "1, 2, 3, 4, 5"
        elseif liste_relance == "X"
            id_choisi = choix_combinaison(id_possibles)
            points_choisis = points[findfirst(id_possibles.==id_choisi)]
            return id_choisi, points_choisis
        end
        liste_relance = split(liste_relance,",")
        liste_relance = parse.(Int, liste_relance)
        nb_des_relances = length(liste_relance)
        lancer2 = rand(1:6, nb_des_relances)
        for i = eachindex(liste_relance)
            lancer[liste_relance[i]] = lancer2[i]
        end

        essai = DataFrame(Manche = manche, Tour = num_relance+1, De_1 = lancer[1], De_2 = lancer[2], De_3 = lancer[3], De_4 = lancer[4], De_5 = lancer[5])
        append!(partie, essai)

        println("Tour nº ", num_relance + 1, " :")
        println(lancer)
    end
    println("Total des combinaisons possibles :")
    points = combinaison(lancer, id_possibles)
    TAB_possible = DataFrame(ID = combi_possibles[:,1], Combinaison = combi_possibles[:,2], Points = points)
    println(TAB_possible)
    id_choisi = choix_combinaison(id_possibles)
    points_choisis = points[findfirst(id_possibles.==id_choisi)]
    return id_choisi, points_choisis
end

function Yahtzee!(combinaisons, partie, manche, n)
    combi_possibles = DataFrame(IdCombinaison = [], NomCombinaison = [])
    for i in 1:n
        if combinaisons[i, 3] == false
            possibilite = combinaisons[i,[1,2]]
            push!(combi_possibles, possibilite)
        end
    end
    manche += 1
    println("Manche nº ", manche, " :")
    combi_choisie = Deroule_manche!(partie, manche, combi_possibles)
    combinaisons[combi_choisie[1], 3] = true
    combinaisons[combi_choisie[1], 4] = combi_choisie[2]
    
    if manche != 13
        Yahtzee!(combinaisons, partie, manche, n)
    else
        compte_yahtzee = 0
        for i in 1:size(partie)[1]
            if partie[i, 3] == partie[i, 4] == partie[i, 5] == partie[i, 6] == partie[i, 7]
                compte_yahtzee += 1
            end
        end
        if combinaisons[12, 4] == 50
            bonus = (compte_yahtzee - 1) * 50
        else 
            bonus = 0
        end
        if sum(combinaisons[1:6,4]) >= 63
            bonus += 35
        end
        println("Vous avez fait un score de : ", sum(combinaisons[:,4]) + bonus)
        println("Résumé de la partie : ")
        println(combinaisons[:,[2, 4]])
    end

end

function Jouer()
    n = 13
    liste_ID = collect(1:n)
    liste_nom = ["Dés 1","Dés 2","Dés 3","Dés 4","Dés 5","Dés 6","Brelan","Carré","Full","Petite Suite","Grande Suite","Yahtzee","Chance"]
    combi_bloquees = fill(false, n)
    combi_score = fill(0, n)

    combinaisons = DataFrame(IdCombinaison = liste_ID, NomCombinaison = liste_nom, Bloquees = combi_bloquees, Score = combi_score)
    partie = DataFrame(Manche = Int64[], Tour = Int64[], De_1 = Int64[], De_2 = Int64[], De_3 = Int64[], De_4 = Int64[], De_5 = Int64[])

    manche = 0

    Yahtzee!(combinaisons, partie, manche, n)
end

# A lancer dans la console :
# Jouer()