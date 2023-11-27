include("./Edge.jl")

using Plots

printred(s::String) = printstyled(s,color=:red)
printgreen(s::String) = printstyled(s,color=:green)
printyellow(s::String) = printstyled(s,color=:yellow)

mutable struct Hypergraph
    edges::Vector{Edge}
    nodes::Vector{Node}

    versionNo::Int64

    xMin::Float64
    xMax::Float64
    yMin::Float64
    yMax::Float64

    Hypergraph() = new(Edge[],Node[],1,Inf,-Inf,Inf,-Inf)
    Hypergraph(e,n,v,xm,xM,ym,yM) = new(e,n,v,xm,xM,ym,yM)
    Hypergraph(;edges::Vector{Edge}=Edge[],nodes::Vector{Node}=Node[],versionNo::Int64=1,xMin::Float64=Inf,xMax::Float64=-Inf,yMin::Float64=Inf,yMax::Float64=-Inf) = new(edges,nodes,versionNo,xMin,xMax,yMin,yMax) 
    
end

# returns the true if an edge with this label is found
function doesEdgeLabelExist(g::Hypergraph,label::String)
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
function makePlot(g::Hypergraph, showTicks::Bool = false, showLabels::Bool = true)::Plots.Plot{Plots.GRBackend} 

    graphPlot = plot()
    k = 0.25

    deltaX = (g.xMax - g.xMin) * k
    deltaY = (g.yMax - g.yMin) * k
    
    plot!(graphPlot, xlim = [g.xMin - deltaX,g.xMax + deltaX], ylim = [g.yMin - deltaY, g.yMax + deltaY])
    #plot!(graphPlot, aspect_ratio=:equal)
    plot!(graphPlot, grid = false, legend = false)
    plot!(graphPlot, axis = showTicks, xticks = showTicks, yticks = showTicks) 

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
        #push!(edges, [currEdge.sourceKey, currEdge.destKey])

        # u = currEdge.sourceKey
        # v = currEdge.destKey

        # plot!(graphPlot,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = currEdge.color, linewidth = currEdge.lineWidth)
        # midx = (xy[u,1] + xy[v,1]) / 2
        # midy = (xy[u,2] + xy[v,2]) / 2

        # if length(edges[j]) == 2
        #     u = edges[j][1]
        #     v = edges[j][2]
        #     plot!(f,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = :black,linewidth = lw)
        # else
        lw = 1.5
        la = 1
        lc = :black
        ms = 10

        color = :gray
        #colorset = palette(:seaborn_colorblind)
        alp = .05
        ms = 1
        H = hyperedgehull(currEdge)
        plot!(graphPlot,VPolygon(H),alpha = alp,linewidth = lw, markerstrokewidth = ms, linecolor = color,linealpha = la)
        #end
        

    end
    
    #Plot the xy circles and node labels
    for currNode in g.nodes

        scatter!(graphPlot, xy[:,1], xy[:,2], markersize = currNode.size, color = currNode.fillColor, markerstrokecolor = currNode.outlineColor)
        
        if (showLabels == true)
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

function addEdge(g::Hypergraph, label::String, mems = Node[],color = "black",linew = 1.0)
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


    push!(g.edges, newEdge)
    return newEdge
end

function removeEdge(g::Hypergraph, label::String)
    #Removes the first edge it finds with the appropriate label
    #
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
        nodeLabel = g.nodes[nodeIndex].label
    end

    for edge in g.edges
        if edge.label == edgeLabel
            push(edge.members, g.nodes[nodeIndex])
            return
        end
    end
    addEdge(g,edgeLabel)
    push!(g.edges[end].members, g.nodes[nodeIndex])
end