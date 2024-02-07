include("./Edge.jl")

cp = palette(:seaborn_colorblind,10)

printred(s::String) = printstyled(s,color=:red)
printgreen(s::String) = printstyled(s,color=:green)
printyellow(s::String) = printstyled(s,color=:yellow)
ssplit(s::String,delim::String=" ")::Vector{String} = [lowercase(String(i)) for i in split(strip(s), delim)] 
stringWithinSB(s::String)::String = String(s[findfirst('[',s)+1:findfirst(']',s)-1])

mutable struct Hypergraph
    edges::Vector{Edge}
    nodes::Vector{Node}

    displayType::Int64
    showTicks::Bool
    showLabels::Bool
    showLegend::Bool

    xMin::Float64
    xMax::Float64
    yMin::Float64
    yMax::Float64



    Hypergraph() = new(Edge[],Node[],3,false,true,false,Inf,-Inf,Inf,-Inf)
    Hypergraph(e,n,dt,sT,sLa,sLe,xm,xM,ym,yM) = new(e,n,dt,sT,sLa,sLe,xm,xM,ym,yM)
    Hypergraph(;edges::Vector{Edge}=Edge[],nodes::Vector{Node}=Node[],displayType::Int64=3,showTicks=false,showLabels=true,showLegend=false,xMin::Float64=Inf,xMax::Float64=-Inf,yMin::Float64=Inf,yMax::Float64=-Inf) = new(edges,nodes,displayType,showTicks,showLabels,showLegend,xMin,xMax,yMin,yMax) 
    
end
function setAllEdgeMode(g::Hypergraph,edgemode::Int64)
    for edge in g.edges edge.displayType = edgemode end
end

function setAllEdgeFill(g::Hypergraph,edgefill::Float64)
    for edge in g.edges edge.fill = edgefill end
end

function setAllEdgeRad(g::Hypergraph,hullSize::Float64)
    for edge in g.edges edge.hullSize = hullSize end
end


function findNodeIndexfromLabel(g::Hypergraph,label::String)
    for node in 1:length(g.nodes) if lowercase(g.nodes[node].label) == label return node end end
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
function doesNodeLabelExist(g::Hypergraph,label::String)
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
    if (dir == "left" || dir == "l") edge.edgeLabelX -= units 
    elseif (dir == "right" || dir == "x" ||  dir == "r") edge.edgeLabelX += units
    elseif (dir == "up" || dir == "y" ||  dir == "u") edge.edgeLabelY += units
    elseif (dir == "down" || dir == "d") edge.edgeLabelY -= units
    else print("Invalid Direction in moveEdge") end
    setGraphLimits(g)
end

function moveNode(g::Hypergraph, node::Node, dir::String, units::Float64)
    if (dir == "left" || dir == "l") node.xCoord -= units 
    elseif (dir == "right" || dir == "x" ||  dir == "r") node.xCoord += units
    elseif (dir == "up" || dir == "y" ||  dir == "u") node.yCoord += units
    elseif (dir == "down" || dir == "d") node.yCoord -= units
    else print("Invalid Direction in moveNode") end
    setGraphLimits(g)
end

function moveNode(g::Hypergraph, label::String, xUnits::Float64, yUnits::Float64)
    node = findNodeWithLabel(g, label)

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
    index = findNodeIndexFromLabel(g, label)
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
    labels = String[]
    plot_font = "computer modern"
    txtsize = 12

    # Populate the xy 2-dimmensional vector
    allZeroes = true # Boolean that checks if the xy coordinates are all 0s
    
    for currNode in 1:n
        thisNode = g.nodes[currNode]
        # NOTE: we use the index of the node to identify it
        
        if (!allZeroes) || (thisNode.xCoord != 0) || (thisNode.yCoord != 0)
            allZeroes = false
        end
        xy[currNode,:] = [thisNode.xCoord, thisNode.yCoord]
        push!(labels, thisNode.label)
    end

    # Populate the edges vector and plot the edges
    for currEdge in g.edges
        la = 1
        ms = 10
        alp = .0
        ms = 1

        if currEdge.displayType == 1
            
            H = hyperedgehull(currEdge, currEdge.hullSize)
            plot!(graphPlot,VPolygon(H),alpha = currEdge.fill,linewidth = currEdge.lineWidth, markerstrokewidth = ms, linecolor = currEdge.color,linealpha = la, label=currEdge.label)
        elseif currEdge.displayType == 2
            #find centroid of poiints
            if currEdge.edgeLabelX == Inf && currEdge.edgeLabelY == Inf 
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
            #println("$(currEdge.label) $(currEdge.edgeLabelX) $(currEdge.edgeLabelY)")

            for node in currEdge.members
                plot!(graphPlot,[currEdge.edgeLabelX; node.xCoord], [currEdge.edgeLabelY; node.yCoord],color = currEdge.color, linewidth = currEdge.lineWidth)
            end
            

            scatter!(graphPlot, [currEdge.edgeLabelX], [currEdge.edgeLabelX], alpha = alp, markersize =10, markershape = :rect, color = currEdge.color, markerstrokecolor = currEdge.color)
            annotate!(graphPlot, currEdge.edgeLabelX, currEdge.edgeLabelY, text(currEdge.label, plot_font, txtsize, color="black"))
        elseif currEdge.displayType == 3
            for S in 1:length(currEdge.members)-1
                nodeS = currEdge.members[S]
                for D in S+1:length(currEdge.members)
                    nodeD = currEdge.members[D]
                    plot!(graphPlot,[nodeS.xCoord; nodeD.xCoord], [nodeS.yCoord; nodeD.yCoord],color = currEdge.color, linewidth = currEdge.lineWidth)
                end
            end
        end
    end

    
    #Plot the xy circles and node labels
    for currNode in g.nodes

        scatter!(graphPlot, xy[:,1], xy[:,2], markersize = currNode.size, color = currNode.fillColor, markerstrokecolor = currNode.outlineColor, label="")
        
        if (g.showLabels == true)
            annotate!(graphPlot, currNode.xCoord, currNode.yCoord, text(currNode.label, plot_font, txtsize, color=currNode.labelColor))
        end
    end

    return graphPlot
end


"""
Adds a new Node object to the graph from the provided parameters
"""
function addNode(g::Hypergraph, label::String, size=10, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.) 
    newNode = Node(label, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
    badNodeLabel = false
    i = 0
    while (newNode.label == "") || doesNodeLabelExist(g,newNode.label)
        i = i+1 
        newNode.label = string(i)
        badNodeLabel = true
    end

    # Check if a node with the same label is already in the graph
    if (badNodeLabel)
        printyellow("Provided node label \"$label\" is empty or already exists in the graph. The node was given the label $(newNode.label)\n")
    end
    push!(g.nodes, newNode)
    return newNode
end


"""
Adds a new node constructed from the arguments in `commands`.
Assumes commands is of the form:
\t\t add node -l label -s size - oc outlineColor -fc fillColor -lc labelColor -x xCoord -y yCoords

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
    i = 1
    deleteIndex = -1
    for node in g.nodes
            if node.label == label
                deleteIndex = i
                break
            end
            i+=1  
    end
    
    if (deleteIndex == -1)
        printred("A node with label $label was not found.\n")
        return
    else
        deleteat!(g.nodes, i)
    end


    # Iterate through all of the edges in the graph and modify appropriately
    deleteEdges = [] 
    j = 1
    for edge in g.edges

        i = 1
        deleteIndex = -1
        
        for node in edge.members
            if node.label == label
                deleteIndex = i
                break
            end
            i+=1  
        end
        if (deleteIndex != -1) deleteat!(edge.members, i) end
        if length(edge.members) == 0 pushfirst!(deleteEdges,j) end
       j+=1
    end

    #delete all singleton edges
    for edgeNo in deleteEdges
        deleteat!(g.edges, edgeNo)
    end

end

function addEdge(g::Hypergraph, label::String, mems = Node[],color = RGB{Float64}(0.0,0.0,0.0) ,linew = 1.0)
    newEdge = Edge(label, mems, color,linew)
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

    #does the node exist
    nodeIndex = 0
    for nodeNum in 1:length(g.nodes)
        if g.nodes[nodeNum].label == nodeLabel
            nodeIndex = nodeNum
            break
        end
    end
    if nodeIndex == 0
        printyellow("No node with label $nodeLabel found in the graph\nMaking a new Node with label $nodeLabel\n")
        nodeIndex = length(g.nodes)+1
        addNode(g,nodeLabel)
    end
    #does edge exist
    for edge in g.edges
        if edge.label == edgeLabel
            push!(edge.members, g.nodes[nodeIndex])
            return
        end
    end
    maybeEdge = edgeFromMembers(g,edgeLabel)
    if maybeEdge != false 
        push!(maybeEdge.members, g.nodes[nodeIndex]) 
        return 
    end

    #edge does not exist then add it
    addEdge(g,edgeLabel)
    push!(g.edges[end].members, g.nodes[nodeIndex])
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

    print("the adjacent nodes are ", adjacentNodes)

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
    # Lam, E = eigs(L; nev = 3, which=:SM)

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
function loadxy(g::Hypergraph,filepath::String)
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
            newNode = Node(xCoord=coords[1],yCoord=coords[2])
            badNodeLabel = false
            i = 0
            while (newNode.label == "") || doesNodeLabelExist(g,newNode.label)
                i = i+1 
                newNode.label = string(i)
                badNodeLabel = true
            end
            push!(g.nodes,newNode)
        end
    else
        for nodeNum in 1:numNodes
            g.nodes[nodeNum].xCoord,g.nodes[nodeNum].yCoord = [parse(Float64,j) for j in split(lines[nodeNum],",")]
        end

    end
end
function loadhgraph(g::Hypergraph,filepath::String)
    #emptyGraph!(g)
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
        for nodeLabel in [string(i) for i in split(edge,",")]
            maybeNode = findNodeWithLabel(g,nodeLabel)
            if maybeNode == false
                push!(newEdge.members,addNode(g,nodeLabel))
            else
                push!(newEdge.members,maybeNode)
            end
        end
        push!(g.edges,newEdge)
    end

end
function loadall(g::Hypergraph, graphfilepath::String, xyfilepath::String)
    loadhgraph(g,graphfilepath)
    loadxy(g,xyfilepath)
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


#nodeLabels expects a list of node labels within suare brackets with no spaces seperated by commas
function edgeFromMembers(g::Hypergraph, nodeLabels::String, prints::Bool=true)
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
            nodeMeta = "$(node.label) $(node.size) $(node.outlineColor) $(node.fillColor) $(node.labelColor)"
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
            edgeMeta = "$(edge.label) $edgeColor $(edge.lineWidth) $(edge.displayType) $(edge.hullSize)"
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