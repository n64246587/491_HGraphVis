mutable struct Node
    label::Int64 # How the node will actually appear on the graph #labels should be unique
    size::Int64 # How big the node will appear on the graph
    
    outlineColor::String 
    fillColor::String 
    labelColor::String 

    xCoord::Float64
    yCoord::Float64
    Node() = new(0,10,"black","white","black")
    Node(label=0, size=10, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.) = new(label,  size, outlineColor, fillColor, labelColor, xCoord, yCoord)
    Node(;label=0, size=10, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.) = new(label, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
    Node(n::Node) = new(n.label, n.size, n.outlineColor, n.fillColor, n.labelColor, n.xCoord, n.yCoord)
end
function updateNodeColor(n::Node, fc::String, oc::String)
    if (fc != "")  n.fillColor = fc end
    if (oc != "") n.outlineColor = oc end
end

function updateNodeLabelColor(n::Node, lc::String)
    if (lc != "") n.labelColor = lc end
end

function setNode(node::Node ,label = -1, size=10, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.)
node.label = label
node.size = size
node.outlineColor = outlineColor
node.fillColor = fillColor
node.labelColor = labelColor
node.xCoord = xCoord
node.yCoord = yCoord
end

# Parses a node based on vac file commands
function parseNode(lineArgs::Vector{String})::Node
    label = 0
    size = 10
    outlineColor = "black"
    fillColor = "white"
    labelColor = "black"
    xCoord = 0.0
    yCoord = 0.0

    i = findIndex(lineArgs, "-l")
    if i != -1
        label = parse(Int64,lineArgs[i+1])
    end
    i = findIndex(lineArgs, "-x")
    if i != -1
        xCoord = parse(Float64, lineArgs[i+1])
    end
    i = findIndex(lineArgs, "-y")
    if i != -1
        yCoord = parse(Float64, lineArgs[i+1])
    end
    i = findIndex(lineArgs, "-f")
    if i != -1
        fillColor = lineArgs[i+1]
    end
    i = findIndex(lineArgs, "-o")
    if i != -1
        outlineColor = lineArgs[i+1]
    end
    i = findIndex(lineArgs, "-lc")
    if i != -1
        labelColor = lineArgs[i+1]
    end
    i = findIndex(lineArgs, "-s")
    if i != -1
        size = parse(Int64, lineArgs[i+1])
    end

    return Node(label, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
end

Base.:(==)(c1::Node, c2::Node) = 
c1.label == c2.label && 
c1.size == c2.size && 
c1.outlineColor == c2.outlineColor && 
c1.fillColor == c2.fillColor && 
c1.labelColor == c2.labelColor && 
c1.xCoord == c2.xCoord && 
c1.yCoord == c2.yCoord

function Base.:show(io::IO, n::Node) 
    s =  "Node Label: $(n.label)\n"
    s *= "Node Size: $(n.size)\n"
    s *= "Node Colors: Outline:$(n.outlineColor), Fill:$(n.fillColor), Label:$(n.labelColor)\n"
    s *= "Node Coords: ($(n.xCoord),$(n.yCoord))\n"
    print(io,s)
end
