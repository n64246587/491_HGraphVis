println("Loading packages...")
using Plots, LazySets
#include statements here


ssplit(s::String,delim::String=" ")::Vector{String} = [lowercase(String(i)) for i in split(strip(s), delim)] 


#leave relativefilepath blank if the graph files are in the same folder as this file
#if the graphfiles are in a subfollder of the folder this file is in, specify the path to that folder
relativefilepath = "hgfiles/"

#leave filePrefix blank unless you files are saved as x-eg.txt,x-egm.txt, x-nd.txt, and x-ndm.txt where x is filePrefix
filePrefix = "h1"

#set these 4 if your files have different prefixes than above
edgesFile =    relativefilepath*"h1-eg.txt"
nodeFile =     relativefilepath*"h1-nd.txt"
edgeMetaFile = relativefilepath*"h1-egm.txt"
nodeMetaFile = relativefilepath*"h1-ndm.txt"

defaultNodeLabel = 1 #must be numeric
defaultOutlineColor = "black"
defaultFillColor = "white"
defaultLabelColor = "black"
#________________________________________________________

defaultLineWidth = 1.0
defaultDisplayType = 1 #1 is for hull #2  is for bipartite # 3 is for clique
defaultHullSize = 0.25
defaultEdgeLabelX = 0.0
defaultEdgeLabelY = 0.0
defaultFill = 0.0

defaultEdgeLabel = 65


nodelabels = []
nodes = []
edges = []


#if filePrefix is set then use that to set the other data
if filePrefix != ""
    edgeFile =    relativefilepath*filePrefix*"-eg.txt"
    nodeFile =     relativefilepath*filePrefix*"-nd.txt"
    edgeMetaFile = relativefilepath*filePrefix*"-egm.txt"
    nodeMetaFile = relativefilepath*filePrefix*"-ndm.txt"
end
#loading nodes
nodeLines = []
if nodeFile != ""
    try 
        open(nodeFile) do file 
            nodeLines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(nodeFile, " could not be loaded.")   
    end
end
#loading node meta
nodeMetaLines = []
if nodeMetaFile != ""
    try 
        open(nodeMetaFile) do file 
            nodeMetaLines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(nodeMetaFile, " could not be loaded.")  
    end
end

#check node file dimensions
numNodeLines = length(nodeLines) 
numMetaNodeLines = length(nodeMetaLines)
if numMetaNodeLines>0 && numNodeLines != numMetaNodeLines
    println("Dimmension mismatch. There are $numNodeLines nodes in the data and $numMetaNodeLines nodes in the metadata. \n")  
end

edgeLines = []
if edgeLines != ""
    try 
        open(edgeFile) do file 
            edgeLines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(edgeFile, " could not be loaded.")   
    end
end
edgeMetaLines = []
if edgeMetaFile != ""
    try 
        open(edgeMetaFile) do file 
            edgeMetaLines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(edgeMetaFile, " could not be loaded.")   
    end
end
#check egde file dimensions
numEdgeLines = length(edgeLines) 
numMetaEdgeLines = length(edgeMetaLines)
if numMetaEdgeLines>0 && numEdgeLines != numMetaEdgeLines
    print("Dimmension mismatch. There are $numEdgeLines edges in the data and $numMetaEdgeLines edges in the metadata. \n")  
end

# store stuff in containers
if numMetaNodeLines > 0
    nodeLabels = []
    for i in 1:numMetaNodeLines
        coords = [parse(Float64,j) for j in split(nodeLines[i],",")]
        lineArgs = ssplit(nodeMetaLines[i])
        nodeSize = parse(Int64,lineArgs[2])
        #make sure labels are unique
        nodeLabel = lineArgs[1]
        while nodeLabel in nodeLabels
            global defaultNodeLabel
            nodeLabel = string(defaultNodeLabel)
            defaultNodeLabel += 1
        end


        #xcoord, ycoord, label, nodesize, outlineColor, fillColor, labelColor
        newNode = [coords[1],coords[2], nodeLabel, nodeSize, lineArgs[3], lineArgs[4], lineArgs[5]]
        push!(nodeLabels, nodeLabel)
        push!(nodes, newNode)
    end
else
    for i in 1:numNodeLines
        coords = [parse(Float64,j) for j in split(nodeLines[i],",")]
        #xcoord, ycoord, label, nodesize, outlineColor, fillColor, labelColor
        newNode = [coords[1],coords[2], string(i), 10, defaultOutlineColor,defaultFillColor, defaultLabelColor]
        push!(nodes, newNode)
    end
end
#

# store edge in containers
if numMetaEdgeLines > 0
    edgeLabels = []
    for i in 1:numMetaEdgeLines
        members =  split(edgeLines[i],",")
        lineArgs = ssplit(edgeMetaLines[i])
        edgeLabel = lineArgs[1]
        r,g,b = [parse(Float64, i) for i in ssplit(lineArgs[2],",")]
        lineWidth = parse(Float64,lineArgs[3])
        displayType = parse(Int64,lineArgs[4])
        hullSize = parse(Float64,lineArgs[5])
        edgeLabelX = parse(Float64,lineArgs[6])
        edgeLabelY = parse(Float64,lineArgs[7])
        fill = parse(Float64,lineArgs[8])
        
        while edgeLabel in edgeLabels
            global defaultEdgeLabel
            nodeLabel = Char(defaultEdgeLabel)
            defaultEdgeLabel += 1
        end


        #members, edgelabel, r,g,b,lineWidth, displayType, hullsize, edgeLabelX, edgeLabelY, fill
        newEdge = [members,edgeLabel,r,g,b,lineWidth,displayType,hullSize,edgeLabelX,edgeLabelY,fill]
        push!(edgeLabels, edgeLabel)
        push!(edges, newEdge)
    end
else
    for i in 1:numEdgeLines
        members =  split(edgeLines[i],",")
        #members, edgelabel, r,g,b,lineWidth, displayType, hullsize, edgeLabelX, edgeLabelY, fill
        newEdge = [members,edgeLabel,r,g,b,lineWidth,displayType,hullSize,edgeLabelX,edgeLabelY,fill]
        push!(edgeLabels, edgeLabel)
        push!(edges, newEdge)
    end
end





# Plot it
# Hypergraph info








