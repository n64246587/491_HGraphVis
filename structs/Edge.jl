include("./Node.jl")

mutable struct Edge
    members::Vector{Node}
    weight::Float64
    color::String
    lineWidth::Float64

    Edge() = new(Node[],1.0,"black",1.0)
    Edge(m,w,c,lw) = new(m,w,c,lw)
    Edge(;m=Node[],w=1.0,c="black",lw=1.0) = new(m,w,c,lw)
end