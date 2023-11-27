include("./Node.jl")
using LazySets

mutable struct Edge
    label::String
    members::Vector{Node}
    color::String
    lineWidth::Float64

    Edge() = new("",Node[],"black",1.0)
    Edge(l,m,c,lw) = new(l,m,c,lw)
    Edge(;l="",m=Node[],c="black",lw=1.0) = new(l,m,c,lw)
end

function parseEdge(lineArgs::Vector{String})::Edge
    label::String = ""
    members::Vector{Node} = Node[]
    color::String = "black"
    lineWidth::Float64 = 1.0

    i = findIndex(lineArgs, "-l")
    if i != -1
        label = lineArgs[i+1]
    end
    i = findIndex(lineArgs, "-c")
    if i != -1
        color = parse(Float64, lineArgs[i+1])
    end
    i = findIndex(lineArgs, "-w")
    if i != -1
        lineWidth = parse(Float64, lineArgs[i+1])
    end

    for i in findAllIndex(lineArgs, "-m")
        push!(members, Node(lineArgs[i+1]))
    end


    return Edge(label, members, color, li)
end


function circlepoints(centerX,centerY,radius,pts = 100)
    # Return a list of points that define a circle with 
    # specified center and radius, using pts evenly spaced points
    
        rads = LinRange(0,2*pi, pts)
        X = Vector{Vector{Float64}}()
        # Y = zeros(pts,2)
        for i = 1:pts
            x = radius*cos(rads[i]) + centerX
            y = radius*sin(rads[i]) + centerY
            push!(X,[x;y])
            # Y[i,:] = [x,y]
        end
    
        return X
    end
    
    function hyperedgehull(edge::Edge,r=.1)
    # xy gives the (x,y) coordinates for nodes
    # e is a set of indices defining a hyperedge
    # r controls how much of a border to put around nodes
    # Output: a convex hull object that defines the hyperedge
        
        p = Vector{Vector{Float64}}()
        for node in edge.members
            append!(p, circlepoints(node.xCoord, node.yCoord ,r))
        end 
        H = convex_hull(p)
        return H
    end