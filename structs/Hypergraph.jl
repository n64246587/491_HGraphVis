include("./Edge.jl")

cp = palette(:seaborn_colorblind,10)

printred(s::String) = printstyled(s,color=:red)
printgreen(s::String) = printstyled(s,color=:green)
printyellow(s::String) = printstyled(s,color=:yellow)
ssplit(s::String,delim::String=" ")::Vector{String} = [lowercase(String(i)) for i in split(strip(s), delim)] 
stringWithinSB(s::String)::String = String(s[findfirst('[',s)+1:findfirst(']',s)-1])

showHullWarnings = false
mutable struct Hypergraph
    edges::Vector{Edge}
    nodes::Vector{Node}

    nextInt::Int64
    showTicks::Bool
    showLabels::Bool
    showLegend::Bool

    xMin::Float64
    xMax::Float64
    yMin::Float64
    yMax::Float64



    Hypergraph() = new(Edge[],Node[],1,false,true,false,Inf,-Inf,Inf,-Inf)
    Hypergraph(e,n,nI,sT,sLa,sLe,xm,xM,ym,yM) = new(e,n,nI,sT,sLa,sLe,xm,xM,ym,yM)
    Hypergraph(;edges::Vector{Edge}=Edge[],nodes::Vector{Node}=Node[],nextInt::Int64=1,showTicks=false,showLabels=true,showLegend=false,xMin::Float64=Inf,xMax::Float64=-Inf,yMin::Float64=Inf,yMax::Float64=-Inf) = new(edges,nodes,nextInt,showTicks,showLabels,showLegend,xMin,xMax,yMin,yMax) 
    
end
function unnessesarryNodes(edge::Edge, allNodes::Vector{Node}, r=.25)
    # r controls how much of a border to put around nodes
    # Output: a convex hull object that defines the hyperedge
        p = Vector{Vector{Float64}}()
        for node in edge.members
            println("Node Size is $(node.size)")
            if node.size == 0 continue end
            append!(p, circlepoints(node.xCoord, node.yCoord ,r))
        end 
        println("Before V polygon")
        H = VPolygon(convex_hull(p))
        println("Before V polygon UN")

        for node in allNodes
            if node.size == 0 continue end
            if node ∉ edge.members
                for point in circlepoints(node.xCoord, node.yCoord,r/10,8)
                    if Singleton(point) ⊆ H
                        printyellow("Node $(node.label) may be visually within or near edge $(edge.label), though it is not a member.\n")
                        break
                    end
                end
            end
        end
        return H
    end
function swapnodes(node1::Node,node2::Node)
    n1x = node1.xCoord
    n1y = node1.yCoord
    node1.xCoord = node2.xCoord
    node1.yCoord = node2.yCoord
    node2.xCoord = n1x
    node2.yCoord = n1y
end

function setAllEdgeMode(g::Hypergraph,edgemode::Int64)
    for edge in g.edges edge.displayType = edgemode end
    if edgemode == 2
        for currEdge in g.edges 
            xCenter::Float64 = 0.0
            yCenter::Float64 = 0.0
            for node in currEdge.members
                xCenter += node.xCoord
                yCenter += node.yCoord
            end
            xCenter /= length(currEdge.members)
            yCenter /= length(currEdge.members)
            currEdge.edgeLabelX = xCenter
            currEdge.edgeLabelY = yCenter
        end
    end
end
function setAllNodeSize(g::Hypergraph, hs::Float64)
    for node in g.nodes 
        if node.size > 0 node.size = hs end
    end
end
function setAllEdgeFill(g::Hypergraph,edgefill::Float64)
    for edge in g.edges edge.fill = edgefill end
end
function setAllEdgeRad(g::Hypergraph,hullSize::Float64)
    for edge in g.edges edge.hullSize = hullSize end
end
#TODO this function should no longer be needed
function findNodeIndexfromLabel(g::Hypergraph,label::Int64)
    for node in 1:length(g.nodes) if node == label return node end end
    return false
end
function findEdgeIndexfromLabel(g::Hypergraph,label::String)
    for edge in 1:length(g.edges) if lowercase(g.edges[edge].label) == label return edge end end
    return false
end

function doesEdgeColorExist(g::Hypergraph,color::RGB{Float64})::Bool
    for edge in g.edges if edge.color == color return true end end
    return false
    end

function findEdgeWithColor(g::Hypergraph,color::RGB{Float64})
    for edge in g.edges if edge.color == color return edge end end
    return false
    end

#TODO function should not be needed
function findNodeWithLabel(g::Hypergraph,label::String)
    for node in g.nodes if lowercase(node.label) == label return node end end
    return false
    end

function findEdgeWithLabel(g::Hypergraph,label::String)
    for edge in g.edges if lowercase(edge.label) == label return edge end end
    return false
    end

# returns the true if an edge with this label is found
function doesEdgeLabelExist(g::Hypergraph,label::String)::Bool
    for edge in g.edges if edge.label == label return true end end
    return false
    end

# returns the true if a node with this label is found
#TODO this should not be needed either
function doesNodeLabelExist(g::Hypergraph,label::Int64)
    for node in g.nodes if node.label == label return true end end
    return false
    end

# returns the first index of a string in a vector. Returns -1 if not found
function findIndex(lineArgs, substr)
    numArgs = length(lineArgs)
    for i in 1:numArgs
        if lineArgs[i] == substr return i end
    end
    return -1
    end
function findAllIndex(lineArgs, substr)::Vector{Int64}
    numArgs = length(lineArgs)
    ret = Int64[]
    for i in 1:numArgs
        if lineArgs[i] == substr push!(ret,i) end
    end
    return ret
    end
function moveNode(g::Hypergraph, node::Node, xUnits::Float64, yUnits::Float64)
    node.xCoord = xUnits
    node.yCoord = yUnits
    setGraphLimits(g)
    end
function moveEdge(g::Hypergraph, edge::Edge, dir::String, units::Float64)
    if dir in leftAlliases edge.edgeLabelX -= units 
    elseif dir in rightAlliases edge.edgeLabelX += units
    elseif dir in upAlliases edge.edgeLabelY += units
    elseif dir in downAlliases edge.edgeLabelY -= units
    else 
        xVal = units*cos(pi/4)
        yVal = units*sin(pi/4)
        if dir in upRightAliases 
            edge.edgeLabelX += xVal 
            edge.edgeLabelY += yVal
        elseif dir in downRightAliases 
            edge.edgeLabelX += xVal 
            edge.edgeLabelY -= yVal
        elseif dir in upLeftAliases 
            edge.edgeLabelX -= xVal 
            edge.edgeLabelY += yVal
        elseif dir in downLeftAliases 
            edge.edgeLabelX -= xVal 
            edge.edgeLabelY -= yVal
        else
         print("Invalid Direction in moveEdge") 
        end
    end
    setGraphLimits(g)
end
function moveNode(g::Hypergraph, node::Node, dir::String, units::Float64)
    if dir in leftAliases node.xCoord -= units 
    elseif dir in rightAliases node.xCoord += units
    elseif dir in upAliases node.yCoord += units
    elseif dir in downAliases node.yCoord -= units
    else 
        xVal = units*0.7071067811865476
        yVal = units*0.7071067811865475
        if dir in upRightAliases 
            node.xCoord += xVal 
            node.yCoord += yVal
        elseif dir in downRightAliases 
            node.xCoord += xVal
            node.yCoord -= yVal
        elseif dir in upLeftAliases 
            node.xCoord -= xVal 
            node.yCoord += yVal
        elseif dir in downLeftAliases 
            node.xCoord -= xVal 
            node.yCoord -= yVal
        else
            print("Invalid Direction in moveEdge") 
        end
    end
    setGraphLimits(g)
end

function moveNode(g::Hypergraph, label::String, xUnits::Float64, yUnits::Float64)
    node = g.nodes[parse(Int64, label)]    
    node.xCoord = xUnits
    node.yCoord = yUnits
    setGraphLimits(g)
end

function moveEdge(g::Hypergraph, label::String, xUnits::Float64, yUnits::Float64)
    edge = findEdgeWithLabel(g, label)
    edge.edgeLabelX = xUnits
    edge.edgeLabelY = yUnits
    setGraphLimits(g)
end

function moveNode(g::Hypergraph, label::String, dir::String, units::Float64)
    index = parse(Int64,label)
    println("Moving node $label $dir by $units units")
    if (dir == "left" || dir == "l") g.nodes[index].xCoord -= units 
    elseif (dir == "right" || dir == "x" ||  dir == "r") g.nodes[index].xCoord += units
    elseif (dir == "up" || dir == "y" ||  dir == "u") g.nodes[index].yCoord += units
    elseif (dir == "down" || dir == "d") g.nodes[index].yCoord -= units
    else print("Invalid Direction in moveNode") end
    setGraphLimits(g)
end

function moveEdge(g::Hypergraph, label::String, dir::String, units::Float64)
    index = findEdgeIndexFromLabel(g, label)
    if (dir == "left" || dir == "l") g.edges[index].edgeLabelX -= units 
    elseif (dir == "right" || dir == "x" ||  dir == "r") g.edges[index].edgeLabelX += units
    elseif (dir == "up" || dir == "y" ||  dir == "u") g.edges[index].edgeLabelY += units     
    elseif (dir == "down" || dir == "d") g.edges[index].edgeLabelY -= units
    else print("Invalid Direction in moveNode")
    end
    setGraphLimits(g)
end

function setGraphLimits(g::Hypergraph)
    g.xMin = Inf
    g.xMax = -Inf
    g.yMin = Inf
    g.yMax = -Inf
    if (isempty(g.nodes))
        g.xMax = 1
        g.yMax = 1
        g.xMin = -1
        g.yMin = -1
        return 
    end
    for node ∈ g.nodes
        if (node.xCoord < g.xMin) g.xMin = node.xCoord end
        if (node.xCoord > g.xMax) g.xMax = node.xCoord end
        if (node.yCoord < g.yMin) g.yMin = node.yCoord end
        if (node.yCoord > g.yMax) g.yMax = node.yCoord end
    end
    # There may be cases where coordinates are not well defined
    # Check that the xCoordinates are not the same
    if (g.xMax == g.xMin)
        g.xMax += 1
        g.xMin -= 1
    end
    if (g.yMax == g.yMin)
        g.yMax += 1
        g.yMin -= 1
    end
end


function applyView(g::Hypergraph, centerX::Float64, centerY::Float64, radius::Float64)
    g.xMax = centerX + radius
    g.yMax = centerY + radius
    g.xMin = centerX - radius
    g.yMin = centerY - radius
end

function applyView(g::Hypergraph, label::String, radius::Float64)
    centerX = Inf
    centerY = Inf
    for node ∈ g.nodes
        if node.label == label
            centerX = node.xCoord
            centerY = node.yCoord
            break
        end
    end
    if (centerX != Inf)
        return applyView(g, centerX, centerY, radius)
    else
        printred("No node with label $label was found.")
    end
end



# This function returns a plot object containing the visualization of the graph object g
function makePlot(g::Hypergraph)::Plots.Plot{Plots.GRBackend} 
    global showHullWarnings
    graphPlot = plot()
    k = 0.25
    changeinX = g.xMax - g.xMin
    changeinY = g.yMax - g.yMin
    deltaX = changeinX * k
    deltaY = changeinY * k
    halfSideLength =  changeinX>changeinY ? (changeinX+deltaX)/2 : (changeinY+deltaY)/2
    centerX = (g.xMax + g.xMin) / 2
    centerY = (g.yMax + g.yMin) / 2
    
    plot!(graphPlot, xlim = [centerX - halfSideLength,centerX + halfSideLength], ylim = [centerY- halfSideLength, centerY + halfSideLength])
    plot!(graphPlot, aspect_ratio=:equal) #let the aspect ratio always be equal, requested by Dr. Veldt
    plot!(graphPlot, grid = g.showTicks, legend = g.showLegend)
    plot!(graphPlot, axis = g.showTicks, xticks = g.showTicks, yticks = g.showTicks) 
    
    
    if isempty(g.nodes)
        return graphPlot
    end
    n = length(g.nodes)
    xy = zeros(n,2)
    #edges = Vector{Vector{Int64}}()
    labels = Int64[]
    plot_font = "computer modern"
    txtsize = 12

    # Populate the xy 2-dimmensional vector
    allZeroes = true # Boolean that checks if the xy coordinates are all 0s
    
    for currNode in 1:n
        thisNode = g.nodes[currNode]
        if thisNode.size == 0 continue  end
        if (!allZeroes) || (thisNode.xCoord != 0) || (thisNode.yCoord != 0)  allZeroes = false end
        xy[currNode,:] = [thisNode.xCoord, thisNode.yCoord]
        push!(labels, thisNode.label)
    end
    # Populate the edges vector and plot the edges
    for currEdge in g.edges
        la = 1
        ms = 10
        #ms = 1
        
        if currEdge.displayType == 1 #hull mode
            H = showHullWarnings ? unnessesarryNodes(currEdge, g.nodes, currEdge.hullSize) : hyperedgehull(currEdge, currEdge.hullSize)
            plot!(graphPlot,H,alpha = currEdge.fill,linewidth = currEdge.lineWidth, markerstrokewidth = ms, linecolor = currEdge.color,linealpha =la, label=currEdge.label, fillcolor =currEdge.color, linestyle = :solid )
        elseif currEdge.displayType == -1 #hull mode
            H = hyperedgehull(currEdge, currEdge.hullSize)
            plot!(graphPlot,VPolygon(H),alpha = currEdge.fill,linewidth = currEdge.lineWidth, markerstrokewidth = ms, linecolor = currEdge.color,linealpha =la, label=currEdge.label, fillcolor =currEdge.color, linestyle = :dash )
        elseif currEdge.displayType == 2 #bipartite mode
            #find centroid of poiints
            if currEdge.edgeLabelX == Inf && currEdge.edgeLabelY == Inf 
                xCenter::Float64 = 0.0
                yCenter::Float64 = 0.0
                len = 0
                for node in currEdge.members
                    if node.size == 0 continue end
                    xCenter += node.xCoord
                    yCenter += node.yCoord
                    len += 1
                end
                xCenter /= len
                yCenter /= len
                currEdge.edgeLabelX = xCenter
                currEdge.edgeLabelY = yCenter
            end
            #println("$(currEdge.label) $(currEdge.edgeLabelX) $(currEdge.edgeLabelY)")

            for node in currEdge.members
                if node.size == 0 continue end
                plot!(graphPlot,[currEdge.edgeLabelX; node.xCoord], [currEdge.edgeLabelY; node.yCoord],color = currEdge.color, linewidth = currEdge.lineWidth)
            end
            
            annotate!(graphPlot, currEdge.edgeLabelX, currEdge.edgeLabelY, text(currEdge.label, plot_font, txtsize, color="black"))
            scatter!(graphPlot, [currEdge.edgeLabelX], [currEdge.edgeLabelY], alpha = 1.0, markersize =10, markershape = :rect, color = currEdge.color, markerstrokecolor = currEdge.color)
            
        elseif currEdge.displayType == 3 # clique mode
            for S in 1:length(currEdge.members)-1
                nodeS = currEdge.members[S]
                if nodeS.size == 0 continue end
                for D in S+1:length(currEdge.members)
                    nodeD = currEdge.members[D]
                    if nodeD.size == 0 continue end
                    plot!(graphPlot,[nodeS.xCoord; nodeD.xCoord], [nodeS.yCoord; nodeD.yCoord],color = currEdge.color, linewidth = currEdge.lineWidth)
                end
            end
        end
    end
    #Plot the xy circles and node labels
    #graphPlot = plot()
    # all nodes are updating if and only if the last node is updating
    for currNode in g.nodes
        if currNode.size == 0 continue end
        scatter!(graphPlot, [currNode.xCoord], [currNode.yCoord] ,markershape = :circle ,  markersize = currNode.size, color = currNode.fillColor , markerstrokecolor = currNode.outlineColor,ma=1.0)
        if (g.showLabels == true)
            annotate!(graphPlot, currNode.xCoord, currNode.yCoord, text(currNode.label, plot_font, txtsize, color=currNode.labelColor))
        end 
    end
    return graphPlot
end

function updateNextInt(g::Hypergraph, maybe::Int64 = 9223372036854775807 )::Int64
    if maybe < g.nextInt return maybe end
    n = length(g.nodes)
    for node in 1:n
        if g.nodes[node].size == 0 return node end
    end
    return n+1
end
function getNextInt(g::Hypergraph, maybe::Int64 = 9223372036854775807 )::Int64
    ret = g.nextInt
    updateNextInt(g,maybe)
    return ret
end

"""
Adds a new Node object to the graph from the provided parameters
"""
function addNode(g::Hypergraph, label = -1, size=10, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.)
    if label == -1 label = g.nextInt end
    if label <= length(g.nodes)
        setNode(g.nodes[label],label, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
        return g.nodes[label]
    end
    newNode = Node(label, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
    push!(g.nodes, newNode)
    g.nextInt = updateNextInt(g)
    return newNode
end


"""
Adds a new node constructed from the arguments in `commands`.
Assumes commands is of the form:
\t\t add node -l label -s size - oc outlineColor -fc fillColor -lc labelColor -x xCoord -y yCoord

"""
function addNode(g::Hypergraph, commands::Vector{String})
    newNode = parseNode(commands)
    # We need some way for the user to interact with the node
    # Give it a label equal to its number in the node vector
    NodeLabel = newNode.label
    badNodeLabel = false
    i = 0
    while (newNode.label == "") || doesNodeLabelExist(g,newNode.label)
        i = i+1 
        newNode.label = string(i)
        badNodeLabel = true
    end

    # Check if a node with the same label is already in the graph
    if (badNodeLabel)
        printyellow("Provided node label \"$NodeLabel\" is empty or already exists in the graph. The node was given the label $(newNode.label)\n")
    end
    push!(g.nodes, newNode)
    return newNode
end

function removeNode(g::Hypergraph, label::String)
    # Iterate through all the nodes in the graph and modify appropriately
    nodeIndex = parse(Int64, label)
    if nodeIndex > length(g.nodes)
        printyellow("No node with label $label.\n")
        return
    end
    g.nodes[nodeIndex].size = 0
    g.nextInt = updateNextInt(g,nodeIndex)    


    # Iterate through all of the edges in the graph and modify appropriately
    deleteEdges = [] 
  
    for edgeNum in 1:length(g.edges)
        deleteIndex = -1
        for nodeNum in 1:length(g.edges[edgeNum].members)
            if g.edges[edgeNum].members[nodeNum].label == nodeIndex
                deleteIndex = nodeNum
                break
            end
        end
        if (deleteIndex != -1) deleteat!(g.edges[edgeNum].members, deleteIndex) end
        if length(g.edges[edgeNum].members) == 0 pushfirst!(deleteEdges,edgeNum) end # adds them to front to evaluate backwards
    end

    #delete all empty edges
    for edgeNo in deleteEdges
        deleteat!(g.edges, edgeNo)
    end

end

function addEdge(g::Hypergraph, label::String, mems = Node[],color = RGB{Float64}(0.0,0.0,0.0) ,linew = 1.0, displayT=1, hullS = 0.25,eX =Inf, eY = Inf, fill =0.0)
    newEdge = Edge(label, mems, color,linew,displayT,hullS,eX,eY,fill)
    #check for duplicate labels
    badEdgeLabel = false
    i = 64
    while (newEdge.label == "") || doesEdgeLabelExist(g,newEdge.label)
        i = i+1 
        newEdge.label = string(Char(i))
        badEdgeLabel = true
    end

    # Check if a node with the same label is already in the graph
    if (badEdgeLabel)
        printyellow("Provided edge label \"$label\" is empty or already exists in the graph. The edge was given the label $(newEdge.label)\n")
    end
    i = 0
    while (newEdge.color == RGB{Float64}(0.0,0.0,0.0)) || doesEdgeColorExist(g,newEdge.color)
        i = i+1 
        newEdge.color = cp[i]
    end


    push!(g.edges, newEdge)
    return newEdge
end
function removeNodeFromEdge(g::Hypergraph, nodelabel::String, edgeLabel::String)
    nodeIndex = parse(Int64, nodelabel)
    if nodeIndex > length(g.nodes)
        printyellow("No node with label $label.\n")
        return
    end

    if contains(edgeLabel,'[')
        maybeedge = edgeFromMembers(g,edgeLabel,false)
        if maybeedge != false
            edgeLabel = maybeedge.label
        else
            printyellow("Provided edge label \"$edgeLabel\"  does not exist in the graph. No edges nodes.\n")
            return
        end
    end
    removeEdgeIndex = -1
    for edgeNum in 1:length(g.edges)
        if g.edges[edgeNum].label == edgeLabel
            removeEdgeIndex = edgeNum
            break
        end
    end

    if removeEdgeIndex == -1
        printyellow("Provided edge label \"$edgeLabel\"  does not exist in the graph. No nodes removed from.\n")
        return
    end


    deleteNodeIndex = -1
    for nodeNum in 1:length(g.edges[removeEdgeIndex].members)
        if g.edges[removeEdgeIndex].members[nodeNum].label == nodeIndex
            deleteNodeIndex = i
            break
        end  
    end

    if deleteNodeIndex == -1
        printyellow("Provided node label \"$nodelabel\"  does not exist in the graph. No nodes removed from edges.\n")
        return
    end

    deleteat!(g.edges[removeEdgeIndex].members,deleteNodeIndex )

end


function removeEdge(g::Hypergraph, label::String)
    #Removes the first edge it finds with the appropriate label
    if contains(label,'[')
        maybeedge = edgeFromMembers(g,label,false)
        if maybeedge != false
            label = maybeedge.label
        end
    end
    i = 1
    removeIndex = 0
    for edge in g.edges
        if edge.label == label
            removeIndex = i
            break
        end
        i+=1
    end

    if removeIndex != 0
        deleteat!(g.edges, removeIndex)
    else
        
        printyellow("Provided edge label \"$label\"  does not exist in the graph. No edges deleted.\n")
    end

end

# function addNodetoEdge(g::Hypergraph, commands::Vector{String})
#     wordEdgeAt = findIndex(commands,"edge") #cannot possibly be -1, checked before calling function
#     if 
#     for node in g.nodes
#         if node.label == nodeLabel
#             push!(edge.members,node)
#             return
#         end
#     end
#     printyellow("No node with label $edgeLabel found in the graph\nMaking a new Node with label $edgeLabel\n")

    
#     for edge in g.edges
#         if edge.label == edgeLabel
#             push!(edge.members,node)
#             return
#         end
#     end
#     printyellow("No edge with label $edgeLabel found in the graph\nMaking a new Edge with label $edgeLabel\n")
#     newEdge = parseEdge(commands[wordEdgeAt+1:end])
#     badEdgeLabel = false
#     i = 64
#     while (newEdge.label == "") || doesEdgeLabelExist(g,newEdge.label)
#         i = i+1 
#         newEdge.label = string(Char(i))
#         badEdgeLabel = true
#     end

#     # Check if a node with the same label is already in the graph
#     if (badEdgeLabel)
#         printyellow("Provided node label \"$label\" is empty or already exists in the graph. The node was given the label $(newNode.label)\n")
#     end

#     push!(g.edges,newEdge)


# end

function simpleAddNodetoEdge(g::Hypergraph,nodeLabel::String,edgeLabel::String)

    #check if node and edge exist
    #if either doesn't exist, then create it
    nodeNum = parse(Int64,nodeLabel)
    if nodeNum > length(g.nodes) && nodeNum >= g.nextInt #are we trying create a node
        if nodeNum != g.nextInt
            printyellow("Node $nodeLabel is not already within the graph. Creating node $(g.nextInt) instead.\n")
        end
        nodeNum = g.nextInt
        addNode(g,nodeNum)
    end


    #does edge exist
    for edge in g.edges
        if edge.label == edgeLabel || edge.label == uppercase(edgeLabel)
            push!(edge.members, g.nodes[nodeNum])
            return
        end
    end

    #try edge parsing
    maybeEdge = edgeFromMembers(g,edgeLabel)
    if maybeEdge != false 
        push!(maybeEdge.members, g.nodes[nodeNum]) 
        return 
    end

    #edge does not exist then add it
    addEdge(g,edgeLabel)
    push!(g.edges[end].members, g.nodes[nodeNum])
end


#Layout
function getTotalDegrees(g::Hypergraph)::Matrix{Float64}
    degree = zeros(n,1)
    for nodeNum in 1:length(g.nodes) for edge in g.edges if g.nodes[nodeNum] in edge degree[nodeNum] += 1 end end end
    return degree 
end

function applyNewCoords(g::Hypergraph, xy::Matrix{Float64})
    if length(g.nodes) != (size(xy)[1])
        printred("Number of nodes in graph ", g.nodes, " != ", (size(xy)[1]),"\n")
        return
    end
    for nodeIndex in 1:length(g.nodes)
        g.nodes[nodeIndex].xCoord = xy[nodeIndex,1]
        g.nodes[nodeIndex].yCoord = xy[nodeIndex,2]
    end
    setGraphLimits(g)
end

function createCircularCoords(g::Hypergraph)::Matrix{Float64}
    n = length(g.nodes)
    r = 1.5 * n
    xy = zeros(n,2)
    
    # Places nodes in a circle:
    for j in 1:n
        angle = (2π / n) * j;
        x = round(cos(angle); digits = 5)
        y = round(sin(angle); digits = 5)
        xy[j,:] = [(x * r) (y * r)]
    end

    return xy
end

function createDegreeDependantCoods(g::Hypergraph)::Matrix{Float64}
    n = length(g.nodes)
    r = .9 * n
    degree = getTotalDegrees(g) .+ 1
    xy = zeros(n,2)
    # Updates xy to be degree-dependant
    for j in 1:n
        angle = (2π / n) * j;
        x = round(cos(angle); digits = 5)
        y = round(sin(angle); digits = 5)
        xy[j,:] = [(x * r /(degree[j] * 0.5)) (y * r /(degree[j] * 0.5))]
    end
    return xy
end


# The following functions are used to create a Force-Directed Layout

function magnitude(f::Vector{Float64})::Float64
    return sqrt(f[1]^2 + f[2]^2)
end

# u is the node experiencing the force
# v is the node exerting the force
function f_rep(u::Node, v::Node, k::Float64 = 2.0)::Vector{Float64}
    uPos = [u.xCoord, u.yCoord]
    vPos = [v.xCoord, v.yCoord]

    dir = (uPos - vPos)
    dist = magnitude(dir)

    rep = k .* dir ./ (dist)

    return rep
end

function f_attr(u::Node, v::Node, k::Float64 = 1.25)::Vector{Float64}
    uPos = [u.xCoord, u.yCoord]
    vPos = [v.xCoord, v.yCoord]

    dir = (uPos - vPos)
    dist = magnitude(dir)

    att = k .* dir ./ (dist)

    return -1 .* att
end

function getCoolingFactor(t)::Float64
    # Note: This is just an arbitrary function. Could be tweaked later
    return (200 / Float64(t))
end

# Returns a COPY of the Node in the graph with the specified index/key
#TODO cannot use key


# Returns a vector of Nodes that are adjacent to the Node v
# - If g is directed, it will return only nodes of the form (v,u)
# - If g is undirected, it will return nodes of the form (v,u) and (u,v)
function getAdjacentNodes(g::Hypergraph, v::Node)
    adjacentNodes = Vector{Node}()
    for edge in g.edges
        if v in edge
            for node in edge
                if node != v
                    push!(adjacentNodes, Node(node))
                end
            end
        
        end

    end

    println("the adjacent nodes are ", adjacentNodes)

    return adjacentNodes
end

function parseForceDirectedArgs(commands::Vector{String})
    # ε::Float64, K::Int64, kRep::Float64 = 1.5, kAttr::Float64 = 3.0
    ε = 1e-2
    K = 20
    rep = 1.5
    attr = 2.0

    for str in commands
        str = lowercase(str)
    end
    
    # epsilon
    i = findIndex(commands, "-e")
    if i != -1
        ε = parse(Float64, commands[i + 1])
    end

    # K
    i = findIndex(commands, "-iters")
    if i != -1
        K = parse(Int64, commands[i + 1])
    end

    i = findIndex(commands, "-rep")
    if i != -1
        rep = parse(Float64, commands[i + 1])
    end

    i = findIndex(commands, "-attr")
    if i != -1
        attr = parse(Float64, commands[i + 1])
    end
    
    return [ε, K, rep, attr]
end


# The following function updates the coordinates of the nodes to meet a force-directed layout
# g is the graph object containing the initial layout
# ε is the threshold. ε > 0. Once forces get smaller than epsilon, we stop the algorithm
# K is the maximum number of iterations
function forceDirectedCoords(g::Hypergraph, ε::Float64, K::Int64, kRep::Float64 = 1.5, kAttr::Float64 = 3.0)
    t = 1
    n = length(g.nodes)

    # Store the positions and forces of each node in a matrix of size nx2
    #positions = [(n .* rand(2) .- (n / 2.0)) for i in 1:n]
    positions = [(n .* rand(2) .- n) for i in 1:n] 
    nodeForces = [zeros(2) for i in 1:n]
    maxForce = -Inf

    # Condition 1: the number of iterations so far is less than K
    # Condition 2: The maximum force we computed in the previous iteration is greater than epsilon
    while (t < K) && (maxForce > ε)
        uNum = 0
        for u ∈ g.nodes
            uNum +=1
            adjacentNodes = getAdjacentNodes(g,u)
            # Repellent force must be computed with all vertices
            for v ∈ g.nodes
                if (u == v)
                    continue # we are in the same node
                end

                nodeForces[uNum] += f_rep(u, v, kRep)

            end
            # Attractive force must ONLY be computed with adjacent vertices
            for v ∈ adjacentNodes
                if (u == v)
                    continue # we are in the same node
                end
                nodeForces[uNum] += f_attr(u, v, kAttr)
            end

            if (magnitude(nodeForces[uNum]) > maxForce)
                maxForce = f_u
            end
        end

        for u ∈ 1:n
            positions[u] += (getCoolingFactor(t) .* nodeForces[u])

        end

        t = t + 1
    end

    # Apply the new coordinates
    nodeNum = 0
    for node ∈ g.nodes
        nodeNum+=1
        node.xCoord = positions[nodeNum][1]
        node.yCoord = positions[nodeNum][2]
    end
end

# The following functions enable spectral layout

# The following function will create a sparse matrix representing the graph
function createSparseMatrix(g::Hypergraph)::SparseArrays.SparseMatrixCSC{Float64, Int64}
    ei = []
    ej = []
    w = []
    for edge in g.edges
        for node1 in edge.members
            i1 = findNodeIndexfromLabel(g,node1.label) 
            for node2 in edge.members
                if node1 != node2
                    i2 = findNodeIndexfromLabel(g,node2.label)
                    push!(ei, i1)
                    push!(ej, i2)
                    push!(w, 1.0) 

                end
            end
        end
    end

    A = sparse(ei, ej, w)
    
    return A
end


# The following function will take in a Matrix and return a set of xy coordinates representing the nodes' spectral layout
function spectral_layout(A)
    d = vec(sum(A,dims = 2))
    Dhalf = Diagonal(d.^(-1/2))
    L = I - Dhalf*A*Dhalf
    sc = size(L,1)
    Vl,Vc,convinfo = eigsolve(L + sc*LinearAlgebra.I, 3, :SR; tol = 1e-8, maxiter = 1000, verbosity = 0)
    lam2 = Real(Vl[2])-sc
    E = [Vc[2] Vc[3]] 
    return E
end

# The following function takes in a 
function makeRealMatrix(xy::Matrix{ComplexF64})
    rows = size(xy,1)
    cols = size(xy,2)

    M = zeros(rows, cols)
    
    for i in 1:rows
        for j in 1:cols
            M[i, j] = real(xy[i, j])
        end
    end

    return M
end


function spectralCoords(g::Hypergraph)
    A = createSparseMatrix(g)

    try
        printgreen("Starting Spectral layout\n")
        xy = spectral_layout(A)

        if (typeof(xy) == Matrix{ComplexF64})
            xy = makeRealMatrix(xy)
        end
    
        applyNewCoords(g, xy)

    catch e
        printred("Could not create a spectral layout due to a failed eigenvalue computation.\n")
        return
    end
end
function emptyGraph!(g::Hypergraph)
    empty!(g.nodes)
    empty!(g.edges)
end

##loaders
function loadnodes(g::Hypergraph,filepath::String)
    #xy::Matrix{Float64} = zeros(Float64)
    numNodes = length(g.nodes)
    #xy::Matrix{Float64} = zeros(Float64,numNodes,2)
    lines = []
    try 
        open(filepath) do file 
            lines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(filepath, " could not be loaded.")  
        return 
    end
    numLines = length(lines) 
    if numNodes != 0 && numNodes != length(lines) 
        printyellow("There are $numNodes nodes and $numLines lines in the file.\nCannot assigne nodes xy values from this file. \n")  
        return
    end
    if numNodes == 0
        for i in 1:numLines
            coords = [parse(Float64,j) for j in split(lines[i],",")]
            newNode = Node(label=i,xCoord=coords[1],yCoord=coords[2])

            push!(g.nodes,newNode)
        end
        g.nextInt = numLines+1
    else
        for nodeNum in 1:numNodes
            g.nodes[nodeNum].xCoord,g.nodes[nodeNum].yCoord = [parse(Float64,j) for j in split(lines[nodeNum],",")]
        end

    end
end
function loadedges(g::Hypergraph,filepath::String)
    #emptyGraph!(g)

    lines = []
    try 
        open(filepath) do file 
            lines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(filepath, " could not be loaded.")  
        return 
    end
    for edge in lines
        newEdge = Edge()
        #check for duplicate labels
        badEdgeLabel = false
        i = 64
        while (newEdge.label == "") || doesEdgeLabelExist(g,newEdge.label)
            i = i+1 
            newEdge.label = string(Char(i))
            badEdgeLabel = true
        end
        #check for duplicate colors
        i = 0
        while (newEdge.color == RGB{Float64}(0.0,0.0,0.0)) || doesEdgeColorExist(g,newEdge.color)
            i = i+1 
            newEdge.color = cp[i]
        end
        #looks for nodes by label (node is actually a node label here)
        for nodeNum in [parse(Int64,i) for i in split(edge,",")]
            if nodeNum > length(g.edges)
                push!(newEdge.members,addNode(g,nodeNum))
            else
                push!(newEdge.members,g.nodes[nodeNum])
            end
        end
        push!(g.edges,newEdge)
    end

end
function loadnodesmeta(g::Hypergraph,filepath::String)
    numNodes = length(g.nodes)
    lines = []
    try 
        open(filepath) do file 
            lines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(filepath, " could not be loaded.")  
        return 
    end
    numLines = length(lines) 
    if numNodes != 0 && numNodes != length(lines) 
        printyellow("There are $numNodes nodes and $numLines lines in the file.\nCannot assigne nodes metadate from this file. \n")  
        return
    end
    #if there are no nodes create the nodes at 0,0 with this metadata
    if numNodes == 0
        for i in 1:numLines
            #$(node.label) $(node.size) $(node.outlineColor) $(node.fillColor) $(node.labelColor)"
            lineArgs = ssplit(lines[i])
            nodeSize = parse(Int64,lineArgs[1])
            newNode = Node(label=i,size=nodeSize, outlineColor=lineArgs[2], fillColor=lineArgs[3], labelColor=lineArgs[4])
            push!(g.nodes,newNode)
        end
    else
        for nodeNum in 1:numNodes
            lineArgs = ssplit(lines[nodeNum])
            nodeSize = parse(Int64,lineArgs[2])
            g.nodes[nodeNum].label = i
            g.nodes[nodeNum].size = nodeSize
            g.nodes[nodeNum].outlineColor=lineArgs[2]
            g.nodes[nodeNum].fillColor=lineArgs[3]
            g.nodes[nodeNum].labelColor=lineArgs[4]
        end

    end


end

function loadedgesmeta(g::Hypergraph,filepath::String)
    lines = []
    try 
        open(filepath) do file 
            lines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(filepath, " could not be loaded.")  
        return 
    end

    numEdges = length(g.edges)
    if numEdges != 0 && numEdges != length(lines) 
        printyellow("There are $numEdges edges and $numLines lines in the file.\nCannot assigne edges metadate from this file. \n")  
        return
    end

    if numEdges == 0
        for edge in lines
            newEdge = Edge()
            lArgs = ssplit(edge)
            newEdge.label = lArgs[1]
            r,gr,b = [parse(Float64, i) for i in ssplit(lArgs[2],",")]
            colorantRep = RGB{}(r,gr,b)
            newEdge.color = parse(Colorant{Float64},colorantRep)
            newEdge.lineWidth = parse(Float64,lArgs[3])
            newEdge.displayType = parse(Int64,lArgs[4])
            newEdge.hullSize = parse(Float64,lArgs[5])
            newEdge.edgeLabelX = parse(Float64,lArgs[6])
            newEdge.edgeLabelX = parse(Float64,lArgs[7])
            newEdge.fill = parse(Float64,lArgs[8])
            push!(g.edges,newEdge)
            #edgeColor = "$(edge.color.r),$(edge.color.g),$(edge.color.b)"
            #edgeMeta = "$(edge.label) $edgeColor $(edge.lineWidth) $(edge.displayType) $(edge.hullSize) $(edge.edgeLabelX) $(edge.edgeLabelY) $(edge.fill)"
        end
    else
        for edgeNum in 1:numEdges
            lArgs = ssplit(edge)
            g.edges[edgeNum].label = lArgs[1]
            r,gr,b = [parse(Float64, i) for i in ssplit(lArgs[2],",")]
            colorantRep = RGB{}(r,gr,b)
            g.edges[edgeNum].color = parse(Colorant{Float64},colorantRep)
            g.edges[edgeNum].lineWidth = parse(Float64,lArgs[3])
            g.edges[edgeNum].displayType = parse(Int64,lArgs[4])
            g.edges[edgeNum].hullSize = parse(Float64,lArgs[5])
            g.edges[edgeNum].edgeLabelX = parse(Float64,lArgs[6])
            g.edges[edgeNum].edgeLabelX = parse(Float64,lArgs[7])
            g.edges[edgeNum].fill = parse(Float64,lArgs[8])

        end

    end

end




function loadAll(g::Hypergraph, edgefilepath::String, nodefilepath::String, edgemetafilepath::String, nodemetafilepath::String)
    #TODO do this part first and collect all node data, do not just call the other functions
    #reset the graph structure
    empty!(g.edges)
    empty!(g.nodes)
    #read in the nodes
    nodeLines = []
    try 
        open(nodefilepath) do file 
            nodeLines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(nodefilepath, " could not be loaded.")  
        return 
    end
    #read in the node metadata
    nodeMetaLines = []
    try 
        open(nodemetafilepath) do file 
            nodeMetaLines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(nodemetafilepath, " could not be loaded.")  
        return 
    end
    #make sure they have the same amount of data
    numNodeLines = length(nodeLines) 
    numMetaNodeLines = length(nodeMetaLines)
    if numNodeLines != numMetaNodeLines
        printyellow("Dimmension mismatch. There are $numNodeLines nodes in the data and $numMetaNodeLines nodes in the metadata. \n")  
        return
    end

    edgeLines = []
    try 
        open(edgefilepath) do file 
            edgeLines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(edgefilepath, " could not be loaded.")  
        return 
    end

    edgeMetaLines = []
    try 
        open(edgemetafilepath) do file 
            edgeMetaLines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(edgemetafilepath, " could not be loaded.")  
        return 
    end

    numEdgeLines = length(edgeLines) 
    numMetaEdgeLines = length(edgeMetaLines)
    if numEdgeLines != numMetaEdgeLines
        printyellow("Dimmension mismatch. There are $numEdgeLines edges in the data and $numMetaEdgeLines edges in the metadata. \n")  
        return
    end

     #add nodes to graph
     for i in 1:numNodeLines
        coords = [parse(Float64,j) for j in split(nodeLines[i],",")]
        lineArgs = ssplit(nodeMetaLines[i])
        nodeSize = parse(Int64,lineArgs[1])
        newNode = Node(xCoord=coords[1],yCoord=coords[2],label=i, size=nodeSize, outlineColor=lineArgs[2], fillColor=lineArgs[3], labelColor=lineArgs[4])
        push!(g.nodes,newNode)
        #looks for nodes by label (node is actually a node label here)
       
    end


    for edgeNum in 1:numEdgeLines
        newEdge = Edge()
        lArgs = ssplit(edgeMetaLines[edgeNum])
        newEdge.label = lArgs[1]
        r,gr,b = [parse(Float64, i) for i in ssplit(lArgs[2],",")]
        colorantRep = RGB{}(r,gr,b)
        newEdge.color = parse(Colorant{Float64},colorantRep)
        newEdge.lineWidth = parse(Float64,lArgs[3])
        newEdge.displayType = parse(Int64,lArgs[4])
        newEdge.hullSize = parse(Float64,lArgs[5])
        newEdge.edgeLabelX = parse(Float64,lArgs[6])
        newEdge.edgeLabelX = parse(Float64,lArgs[7])
        newEdge.fill = parse(Float64,lArgs[8])
        #check for duplicate labels
        badEdgeLabel = false
        i = 64
        while (newEdge.label == "") || doesEdgeLabelExist(g,newEdge.label)
            i = i+1 
            newEdge.label = string(Char(i))
            badEdgeLabel = true
        end
        push!(g.edges,newEdge)
    end
    for i in 1:numNodeLines
        newNode = g.nodes[i]
        for edgeNum in 1:numEdgeLines
            if newNode.label in [parse(Int64, i) for i in ssplit(edgeLines[edgeNum],",")] push!(g.edges[edgeNum].members,newNode) end
        end
    end
   
   
end

#TODO make a better version of this function
function loadAll(g::Hypergraph, allPath::String)
    allPathRoot = allPath[begin:end-4]
    loadAll(g,allPathRoot*"-eg.txt",allPathRoot*"-nd.txt",allPathRoot*"-egm.txt",allPathRoot*"-ndm.txt")
end

function parseEdgeExpression(g::Hypergraph,nodeLabels::String)::Edge
    edg = Edge()
    for nodeLabel in ssplit(nodeLabels,",")
        maybenode = findNodeWithLabel(g,nodeLabel)
        if maybenode != false push!(edg.members,maybenode) end
    end
    return edg
end

function edgeSubsetOfEdgeLabel(largerEdge::Edge, smallerEdge::Edge)::Bool

    for node in smallerEdge.members 
        foundName::Bool = false
       for node2 in largerEdge.members
            if node2.label == node.label
                foundName = true
                break
            end
       end
       if foundName == false return false end
    end
    return true

end

function edgesWithLabels(g::Hypergraph, nodeLabels::String)::Vector{Edge}
    edgeOfLabels::Edge = parseEdgeExpression(g,nodeLabels)
    ewm::Vector{Edge} = Edge[]
    for edge in g.edges
        if edgeSubsetOfEdgeLabel(edge,edgeOfLabels) push!(ewm,edge) end
    end
    return ewm
end

function printEdgelist(edgeList::Vector{Edge})
    labelsList::Vector{String} = []
    longestLabel = 0
    membersList::Vector{String} = []
    longestMembers = 0
    for edge in edgeList
        label = edge.label
        llength = length(label)
        members = "["*join([node.label for node in edge.members],",")*"]"
        mlength = length(members)
        if llength>longestLabel longestLabel = llength end
        if mlength>longestMembers longestMembers = mlength end
        push!(labelsList,label)
        push!(membersList,members)
    end
    labelSpace = max(longestMembers,5)
    memberSpace = max(longestMembers,7)
    println("label"*" "^(labelSpace-5)*" | "*"members"*" "^(memberSpace-7))
    println("_"^(labelSpace)*" | "*"_"^(memberSpace))
    for i in 1:length(labelsList)
        thisLabel = labelsList[i]
        thisMembers = membersList[i]
        println("$thisLabel"*" "^(labelSpace-length(thisLabel))*" | "*"$thisMembers"*" "^(memberSpace-length(thisMembers)))
    end

end

function printNodelist(edgeList::Vector{Node})
    labelsList::Vector{String} = []
    longestLabel = 0
    membersList::Vector{String} = []
    longestMembers = 0
    # for edge in edgeList
    #     label = edge.label
    #     llength = length(label)
    #     members = "["*join([node.label for node in edge.members],",")*"]"
    #     mlength = length(members)
    #     if llength>longestLabel longestLabel = llength end
    #     if mlength>longestMembers longestMembers = mlength end
    #     push!(labelsList,label)
    #     push!(membersList,members)
    # end
    # labelSpace = max(longestMembers,5)
    # memberSpace = max(longestMembers,7)
    # println("label"*" "^(labelSpace-5)*" | "*"members"*" "^(memberSpace-7))
    # println("_"^(labelSpace)*" | "*"_"^(memberSpace))
    # for i in 1:length(labelsList)
    #     thisLabel = labelsList[i]
    #     thisMembers = membersList[i]
    #     println("$thisLabel"*" "^(labelSpace-length(thisLabel))*" | "*"$thisMembers"*" "^(memberSpace-length(thisMembers)))
    # end

end


#nodeLabels expects a list of node labels within suare brackets with no spaces seperated by commas
function edgeFromMembers(g::Hypergraph, nodeLabels::String, prints::Bool=true)
    if !('[' in nodeLabels  && ']' in nodeLabels) return false end
    efm::Vector{Edge} = edgesWithLabels(g,stringWithinSB(nodeLabels))
    if length(efm) == 1 return efm[1] end
    if prints
        if length(efm) == 0
            ifprintred("There are not edges with the provided members. These are the edges in the graph (can obtain with edgelist command)\n")
            printEdgelist(g.edges)
        else
            printred("There are multiple edges with the provided members. These are the canidates\n")
            printEdgelist(efm)
        end
    end
    
    return false
    
end



function outputGraphToTxt(g::Hypergraph, filename::String)

    filenamesParts = ["nd","ndm","eg","egm"]
    open(filename*"-nd.txt", "w") do file
        writeString = ""
        for node in g.nodes
            nodeCoords = "$(node.xCoord),$(node.yCoord)"
            writeString *= nodeCoords*"\n"
        end
        write(file,writeString[begin:end-1])
    end
    open(filename*"-ndm.txt", "w") do file
        writeString = ""
        for node in g.nodes
            nodeMeta = "$(node.size) $(node.outlineColor) $(node.fillColor) $(node.labelColor)"
            writeString *= nodeMeta*"\n"
        end
        write(file,writeString[begin:end-1])
    end
    open(filename*"-eg.txt", "w") do file
        writeString = ""
        for edge in g.edges
            edgeMembers = ""
            for node in edge.members
                edgeMembers = edgeMembers*"$(node.label),"
            end
            writeString *= edgeMembers[begin:end-1]*"\n"
        end
        write(file,writeString[begin:end-1])
    end
    open(filename*"-egm.txt", "w") do file
        writeString = ""
        for edge in g.edges
            edgeColor = "$(edge.color.r),$(edge.color.g),$(edge.color.b)"
            edgeMeta = "$(edge.label) $edgeColor $(edge.lineWidth) $(edge.displayType) $(edge.hullSize) $(edge.edgeLabelX) $(edge.edgeLabelY) $(edge.fill)"
            writeString *= edgeMeta*"\n"
            
        end
        write(file,writeString[begin:end-1])
    end
end




Base.:(==)(c1::Hypergraph, c2::Hypergraph) = 
c1.edges == c2.edges && 
c1.nodes == c2.nodes && 
c1.displayType == c2.displayType && 
c1.showTicks == c2.showTicks && 
c1.showLabels == c2.showLabels && 
c1.xMin == c2.xMin && 
c1.xMax == c2.xMax && 
c1.yMin == c2.yMin && 
c1.yMax == c2.yMax 