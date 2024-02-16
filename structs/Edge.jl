include("./Node.jl")
using LazySets,Plots,KrylovKit,SparseArrays,Images

nametoColorDict = Dict(value => key for (key, value) in Colors.color_names)
mutable struct Edge
    label::String
    members::Vector{Node}
    color::RGB{Float64}
    lineWidth::Float64
    displayType::Int64 #1 is for hull #2  is for bipartite # 3 is for clique
    hullSize::Float64
    #must make a edgeLabelX and edgeLabelY for bipartite mode
    edgeLabelX::Float64
    edgeLabelY::Float64
    fill::Float64

    Edge() = new("",Node[],RGB{Float64}(0.0,0.0,0.0),1.0,3,0.25,Inf,Inf,0.0)
    Edge(l,m,c,lw,dt,hs,elX,elY,ef) = new(l,m,c,lw,dt,hs,elX,elY,ef)
    Edge(;l="",m=Node[],c=RGB{Float64}(0.0,0.0,0.0),lw=1.0,dt=3,hs=0.25,elX=Inf,elY=Inf,ef=0.0) = new(l,m,c,lw,dt,hs,elX,elY,ef)
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
        color = parse(Colorant{Float64}, lineArgs[i+1])
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
    
    function hyperedgehull(edge::Edge,r=.25)
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

#dictionary does not have every color nametoColorDict #might have to load color by some other metric like RGB values in the text file
function getColorName(c::RGB{Float64})::String
    minColorDistance = Inf
    colorString = "black"
    for color in nametoColorDict     
        colorDist = ((c.r-color.first[1])^2+(c.g-color.first[2])^2+(c.b-color.first[3])^2)^1/2                                                                                                                                       
        if colorDist < 
            minColorDistance minColorDistance= colorDist
            colorString = color.second
        end
    end
    
    return colorString
end


Base.:(==)(c1::Edge, c2::Edge) = 
c1.label == c2.label &&
c1.members == c2.members &&
c1.color == c2.color &&
c1.lineWidth == c2.lineWidth