include("./Edge.jl")
using Plots, KrylovKit
printred(s::String) = printstyled(s,color=:red)
printgreen(s::String) = printstyled(s,color=:green)

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

# returns the index of a string in a vector. Returns -1 if not found
function doesLabelExist(g::Hypergraph,label::String)
    for node in g.nodes
        if node.label == label return true end
    end
    return false
end


# returns the index of a string in a vector. Returns -1 if not found
function findIndex(lineArgs, substr)
    numArgs = length(lineArgs)
    for i in 1:numArgs
        if lineArgs[i] == substr return i end
    end
    return -1
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
        
        # if (g.weighted)
        #     annotate!(graphPlot, midx, midy, text(currEdge.weight, plot_font, txtsize, color="black"))
        # end
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
function addNode(g::Hypergraph, label::String, size=1, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.) 
    newNode = Node(label, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
    push!(g.nodes, newNode)
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
    while (newNode.label == "") || doesLabelExist(g,newNode.label)
        i = i+1 
        newNode.label = string(i)
        badNodeLabel = true
    end

    # Check if a node with the same label is already in the graph
    if (badNodeLabel)
        printred("Provided node label \"$NodeLabel\" is empty or already exists in the graph. The node was given the label $(newNode.label)\n")
    end
    push!(g.nodes, newNode)
end