mutable struct Node
    label::String # How the node will actually appear on the graph #labels should be unique
    size::Int64 # How big the node will appear on the graph
    
    outlineColor::String 
    fillColor::String 
    labelColor::String 

    xCoord::Float64
    yCoord::Float64
    Node() = new("",1,"black","white","black")
    Node(label="", size=1, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.) = new(label,  size, outlineColor, fillColor, labelColor, xCoord, yCoord)
    Node(;label="", size=1, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.) = new(label, size, outlineColor, fillColor, labelColor, xCoord, yCoord)

end

# Parses a node based on vac file commands
function parseNode(lineArgs::Vector{String})::Node
    label = ""
    size = 10
    outlineColor = "black"
    fillColor = "white"
    labelColor = "black"
    xCoord = 0.0
    yCoord = 0.0

    i = findIndex(lineArgs, "-l")
    if i != -1
        label = lineArgs[i+1]
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