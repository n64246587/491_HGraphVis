printstyled("Interactive Julia Hypergraph Visualizizer Starting.\n",color=:green)
include("./help.jl")
printstyled("Please look at the Help Menu while you wait.\n",color=:green)
allHelp()
printstyled("Loading Packages...\n",color=:green)
include("./structs/Hypergraph.jl")


debug = false
G = Hypergraph()
input = ""
commands= String[]
graphHistory = Hypergraph[]
intendedExit = false

showTicks = false
showLabels = true


function genericSave(filename::String)
    # Check the extension of filename
    filepath,extension = [String(split(filename, ".")[i]) for i in 1:2]
    if (extension == "png" || extension == "pdf")
        savefig(makePlot(G), filename)
    elseif (extension == "txt")
        outputGraphToTxt(G, filepath)
    else
        printstyled("Graph could not be saved with extention ",extension, color=:red)
    end
end



function displayGraph()
    if (isnothing(G))
        global G = Graph()
        empty!(G.nodes)
        empty!(G.edges)
    end
    display(makePlot(G))
end

function programExited()
    global intendedExit
    if intendedExit
        printgreen("Program Exited Safely. Goodbye.")
    else
        printred("Program Exited Unexpectedly, potentially via Keyboard Interrupt.")
    end
end





function promptLoop()
    global G
    global debug

    while true
        try
            print("Enter a Command: ")
            commands = ssplit(readline())
            commandParts = length(commands)
            if commandParts == 0
                printred("Empty Command, Please Try Again\n")
                continue
            end
            if commands[1] in quitAliases return 
            elseif commands[1] == "help" 
                if commandParts <2 allHelp() else printHelp(commands[2:end]) end

            elseif commands[1] in addAliases
                if commands[2] == "node"
                    if commandParts == 6 && commands[5] == "edge"
                        simpleAddNodetoEdge(G,commands[3],commands[6])
                    elseif commandParts == 2 # add node
                        nodetoadd = addNode(G, commands)
                    elseif commands[3] != "" # add node somethhing
                        nodetoadd = addNode(G, commands[3])
                    else
                        nodetoadd = addNode(G, commands)
                    end
                    
                end
                
            elseif commands[1] in removeAliases
                if commandParts !=3
                    printred("No subject to remove. Please try help remove.")
                elseif commands[2] == "node"
                    removeNode(G,commands[3])
                elseif commands[2] == "edge"
                    removeEdge(G,commands[3])
                end
        

            elseif commands[1] in moveAliases
                moveCoord = 2
                if "node" == commands[2] moveCoord = 3 end
                label = String(commands[moveCoord])
                nodeToMove = findNodeWithLabel(G, label)
                edgeToMove = findEdgeWithLabel(G, label)
                if nodeToMove != false
                    if "to" == commands[moveCoord+1]
                        xUnits = 0.0
                        if commands[moveCoord+2] == "-"
                            xUnits = nodeToMove.xCoord 
                        else
                            xUnits = parse(Float64, commands[moveCoord+2])
                        end
                        yUnits = 0.0
                        if commands[moveCoord+3] == "-"
                            yUnits = nodeToMove.yCoord
                        else
                            yUnits = parse(Float64, commands[moveCoord+3])
                        end
                        
                        moveNode(G, label, xUnits, yUnits)
                    else
                        xOrY = lowercase(commands[moveCoord+1]) 
                        units = parse(Float64, commands[moveCoord+2])
                        moveNode(G, nodeToMove, xOrY, units)
                    end
                elseif edgeToMove != false
                    if "to" == commands[moveCoord+1]
                        xUnits = 0.0
                        if commands[moveCoord+2] == "-"
                            xUnits = edgeToMove.edgeLabelX 
                        else
                            xUnits = parse(Float64, commands[moveCoord+2])
                        end
                        yUnits = 0.0
                        if commands[moveCoord+3] == "-"
                            yUnits = edgeToMove.edgeLabelY
                        else
                            yUnits = parse(Float64, commands[moveCoord+3])
                        end
                        
                        moveEdge(G, label, xUnits, yUnits)
                    else
                        xOrY = lowercase(commands[moveCoord+1]) 
                        units = parse(Float64, commands[moveCoord+2])
                        moveEdge(G, edgeToMove, xOrY, units)
                    end
                    
                end
            elseif commands[1] in layoutAliases
                layoutType = lowercase(commands[2])
                if layoutType in circularAliases
                    applyNewCoords(G, createCircularCoords(G))
    
                elseif layoutType in degreeAliases
                    applyNewCoords(G, createDegreeDependantCoods(G))
    
                elseif layoutType in forceAliases
                    # returns a vector containing [ε, K, rep, attr]
                    forceDirArgs = parseForceDirectedArgs(commands)
                    ε = forceDirArgs[1]
                    K = floor(Int64, forceDirArgs[2])
                    rep = forceDirArgs[3]
                    attr = forceDirArgs[4]
                    println("""Applying force-directed layout with parameters:
                       ⬗ Minimum force magnitude / ε = $ε
                       ⬗ Max Iterations = $K
                       ⬗ Repulsive factor = $rep
                       ⬗ Attractive factor = $attr """)
    
                    forceDirectedCoords(G, ε, K, rep, attr)
    
                elseif layoutType in spectralAliases
                    spectralCoords(G)
                end
            elseif commands[1] in loadAliases
                if commands[2] in loadNodesAliases
                    loadxy(G,commands[3])
                elseif commands[2] in loadEdgesAliases
                    loadhgraph(G,commands[3])
                    #TODO loading edges after nodes loses xy coords
                elseif commands[2] in loadNodeMetaAliases

                elseif commands[2] in loadEdgeMetaAliases

                end
                
                
                    
            elseif commands[1] in toggleAliases
                if commands[2] == "grid"
                    G.showTicks = !G.showTicks
                elseif commands[2] == "labels"
                    G.showLabels = !G.showLabels
                elseif commands[2] == "legend"
                    G.showLegend = !G.showLegend
                elseif commands[2] == "debug"
                    debug = !debug
                end

            elseif commands[1] in edgeModeAliases
                if commandParts == 2
                    if commands[2] in cliqueAliases setAllEdgeMode(G,3)
                    elseif commands[2] in bipartiteAliases setAllEdgeMode(G,2)
                    elseif commands[2] in convexAliases setAllEdgeMode(G,1)
                    elseif commands[2] in noEdgeTypeAliases setAllEdgeMode(G,0)
                    end
                elseif commandParts == 3
                    edge = findEdgeWithLabel(G,commands[2])
                    if edge != false
                        if commands[3] in cliqueAliases edge.displayType = 3
                        elseif commands[3] in bipartiteAliases edge.displayType = 2
                        elseif commands[3] in convexAliases edge.displayType = 1
                        elseif commands[3] in noEdgeTypeAliases edge.displayType = 0
                        end
                    else
                        edge2 = edgeFromMembers(G, commands[2], false)
                        if edge2 != false
                            if commands[3] in cliqueAliases edge2.displayType = 3
                            elseif commands[3] in bipartiteAliases edge2.displayType = 2
                            elseif commands[3] in convexAliases edge2.displayType = 1
                            elseif commands[3] in noEdgeTypeAliases edge2.displayType = 0
                            end
                        end
                    end
                end
            elseif commands[1] in edgeFillAliases
                if commandParts == 2 setAllEdgeFill(G, parse(Float64, commands[2])) 
                elseif commandParts == 3
                    fillValue = parse(Float64, commands[3])
                    edge = findEdgeWithLabel(G,commands[2])
                    if edge != false edge.fill = fillValue
                    else
                        edge2 = edgeFromMembers(G, commands[2], false)
                        if edge2 != false edge2.fill = fillValue end
                    end
                end
                

            elseif commands[1] in setHulllRadiusAliases
                if commandParts == 2 setAllEdgeRad(G,parse(Float64, commands[2]))
                elseif commandParts == 3
                    hullValue = parse(Float64, commands[3])
                    edge = findEdgeWithLabel(G,commands[2])
                    if edge != false edge.hullSize = hullValue
                    else
                        edge2 = edgeFromMembers(G, commands[2], false)
                        if edge2 != false edge2.hullSize = hullValue end
                    end
                end

            elseif commands[1] in edgelistAliases
                if commandParts == 1 printEdgelist(G.edges) 
                elseif contains(commands[2],"[") printEdgelist(edgesWithLabels(G,stringWithinSB(commands[2])))
                else printEdgelist(edgesWithLabels(G,commands[2]))
                end


            elseif commands[1] in setColorAliases
                #figure out the color
                colorString = ""
                colorantRep::RGB{Float64} 
                if "[" in commands[4]
                    #pasrse color
                    r,g,b = [parse(Float64, i) for i in ssplit(stringWithinSB("[255,0,0]"),",")]
                    colorantRep = RGB{}(r,g,b)
                    colorString = getColorName(colorantRep)
                    #convert from rgb to colorstring
                else
                    colorString = commands[4]
                    colorantRep = parse(Colorant{Float64}, commands[4])
                end
                    
                if commands[2] in nodeAlliases
                    nodeToColor = findNodeWithLabel(G, label)
                    nodeToColor.fillColor = colorString

                elseif commands[2] in edgeAlliases
                    
                    edge = findEdgeWithLabel(G,commands[2])
                    if edge != false edge.hullSize = hullValue
                    else
                        edge2 = edgeFromMembers(G, commands[2], false)
                        if edge2 != false edge2.hullSize = hullValue end
                    end
                end

            elseif commands[1] in saveAliases
                genericSave(commands[2])


            else 
                printred("$(join(commands," ")) is not a recognized Command.\nTry `help` for assistance.\n") 
                continue
            end
           
        setGraphLimits(G)
        displayGraph()

        catch e
            printred("Problem in promptLoop of input.jl\nPlease watch your syntax. Try `help` if you need.\n")
            if debug 
                printred("Rethrowing Error due to debug flag.\n")
                rethrow(e)
            end
        end
    end 

end

atexit(programExited)
displayGraph()
printstyled("Finished loading packages.\nWelcome to the Interactive Hypergraph Visualizer.\n",color=:green)
promptLoop() 
intendedExit = true
exit(0)

