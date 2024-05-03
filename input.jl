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
    global showHullWarnings

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
                    if commandParts == 6 && commands[4] == "edge" # add node `nodelabel` to edge 'edgelabel'
                        simpleAddNodetoEdge(G,commands[3],commands[6])
                    elseif commandParts == 2 # add node
                        nodetoadd = addNode(G)
                    end
                    
                end
                
            elseif commands[1] in removeAliases
                if commands[2] == "node"
                    if commandParts == 3 removeNode(G,commands[3]) #remove node `nodelabel`
                    elseif commandParts == 6 removeNodeFromEdge(G,commands[3],commands[6])#remove node [node] from edge [edge]
                    end
                elseif commands[2] == "edge"
                    removeEdge(G,commands[3])
                end
        

            elseif commands[1] in moveAliases
                moveCoord = 2
                if "node" == commands[2] moveCoord = 3 end
                label = String(commands[moveCoord])
                nodeCoord = parse(Int64,commands[moveCoord])
                nodeToMove = 0
                if nodeCoord > length(G.nodes)
                    nodeToMove = false
                else
                    nodeToMove = G.nodes[nodeCoord]
                end
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
                if commandParts == 2 loadAll(G,commands[2]) 
                elseif commands[2] in loadNodesAliases loadnodes(G,commands[3])
                elseif commands[2] in loadEdgesAliases loadedges(G,commands[3])
                elseif commands[2] in loadNodeMetaAliases loadnodesmeta(G,commands[3])
                elseif commands[2] in loadEdgeMetaAliases loadedgesmeta(G,commands[3])
                elseif commands[2] in loadAllAliases loadAll(G,commands[3])
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
                elseif contains(commands[2] ,"warn") || contains(commands[2] ,"hull")
                    showHullWarnings = !showHullWarnings
                elseif contains(commands[2] ,"dash")
                    edge = findEdgeWithLabel(G,commands[3])
                    if edge != false edge.displayType *= -1 
                    else
                        edge2 = edgeFromMembers(G, commands[3], false)
                        if edge2 != false edge2.displayType *= -1 end 
                    end
                    
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
                elseif '[' in commands[2] printEdgelist(edgesWithLabels(G,stringWithinSB(commands[2])))
                else printEdgelist(edgesWithLabels(G,commands[2]))
                end
            elseif commands[1] in nodeSizeAliases 
                if commandParts == 2 setAllNodeSize(G, parse(Float64, commands[2])) 
                elseif commandParts == 3 
                    node = G.nodes[parse(Int64,commands[2])]
                    node.size = parse(Float64, commands[3])
                end
            


            elseif commands[1] in setColorAliases
                #figure out the color
                colorString = ""
                colorantRep = RGB{}
                if '[' in commands[4]
                    #pasrse color
                    r,g,b = [parse(Float64, i) for i in ssplit(stringWithinSB(commands[4]),",")]
                    colorantRep = RGB{}(r,g,b)
                    colorString = getColorName(colorantRep)
                    #convert from rgb to colorstring
                else
                    colorString = commands[4]
                    colorantRep = parse(Colorant{Float64}, commands[4])
                end
                    
                if commands[2] in nodeAliases
                    # nodeToColor = findNodeWithLabel(G, commands[3])
                    # nodeToColor.fillColor = colorString
                    ind = findNodeIndexfromLabel(G,commands[3])
                    if (ind != -1) updateNodeColor(G.nodes[ind], colorString, colorString) end

                elseif commands[2] in edgeAliases
                    
                    edge = findEdgeWithLabel(G,commands[3])
                    if edge != false edge.color = colorantRep
                    else
                        println("Did not find edge with label")
                        edge2 = edgeFromMembers(G, commands[3], false)
                        println(edge2)
                        if edge2 != false edge2.color = colorantRep 
                        else
                            printyellow("Edge with label $(commands[3]) not found.\n")
                        end
                    end
                elseif commands[2] in nodeLabelAliases
                    ind = findNodeIndexfromLabel(G,commands[3])
                    if (ind != -1) updateNodeLabelColor(G.nodes[ind], colorString) end
                end
            elseif commands[1] in swapNodesAliases
                n1 =  findNodeIndexfromLabel(G,commands[2])
                n2 = findNodeIndexfromLabel(G,commands[3])
                if n1 == -1 
                    printyellow("Node with label $(commands[2]) could not be found.\n")
                elseif n2 == -1 
                    printyellow("Node with label $(commands[3]) could not be found.\n")
                else
                    swapnodes(G.nodes[n1],G.nodes[n2])
                end
            elseif commands[1] in clearAliases
                if commandParts == 2 && commands[2] == "YES"
                    emptyGraph!(G)
                else
                    printyellow("ARE YOU SURE YOU WOULD LIKE TO DELETE THIS GRAPH? REPLY WITH YES TO CONFIRM: ")
                    if strip(readline()) == "YES"
                        emptyGraph!(G)
                        printyellow("Graph Cleared.\n")
                    else
                        printyellow("Aborted.\n")
                    end
                end
            elseif commands[1] in saveAliases
                genericSave(commands[2])

            elseif commands[1] in backgroundAliases
                global bgPath
                global bgSet
                if commandParts == 1 
                    bgPath = ""
                elseif commandParts == 2
                    bgPath = commands[2]
                end

                bgSet = false


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
#TODO leaves a window behind until that repl is Exited
#maybe fork and exec vp could work
if isinteractive() run(`julia.exe`) end
exit(0)

