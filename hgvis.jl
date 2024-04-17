using Plots, LazySets
#include statements here

ssplit(s::String,delim::String=" ")::Vector{String} = [lowercase(String(i)) for i in split(strip(s), delim)] 



relativefilepath = "hgfiles/"
#leave filePrefix blank unless you files are saved as x-eg.txt,x-egm.txt, x-nd.txt, and x-ndm.txt where x is filePrefix
filePrefix = "h1"

#set these 4 if your files have different prefixes than above
edgesFile =    "h1-eg.txt"
nodeFile =     "h1-nd.txt"
edgeMetaFile = "h1-egm.txt"
nodeMetaFile = "h1-ndm.txt"

defaultNodeLabel = 97
defaultEdgeLabel = 64


nodelabels = []


#if filePrefix is set then 
if filePrefix != ""
    edgesFile =    filePrefix*"-eg.txt"
    nodeFile =     filePrefix*"-nd.txt"
    edgeMetaFile = filePrefix*"-egm.txt"
    nodeMetaFile = filePrefix*"-ndm.txt"
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
        open(edgemetafilepath) do file 
            edgeMetaLines = [i for i in readlines(file) if i != ""] 
        end
    catch 
        println(edgemetafilepath, " could not be loaded.")   
    end
end
#check egde file dimensions
numEdgeLines = length(edgeLines) 
numMetaEdgeLines = length(edgeMetaLines)
if numMetaEdgeLines>0 && numEdgeLines != numMetaEdgeLines
    print("Dimmension mismatch. There are $numEdgeLines edges in the data and $numMetaEdgeLines edges in the metadata. \n")  
end
# store stuff in containers
if numMetaEdgeLines > 0
    for i in 1:numNodeLines
        coords = [parse(Float64,j) for j in split(nodeLines[i],",")]
        lineArgs = ssplit(nodeMetaLines[i])
        nodeSize = parse(Int64,lineArgs[2])
        #xcoord, ycoord, label, nodesize, outlineColor, fillColor, labelColor
        newNode = [coords[1],coords[2],lineArgs[1], nodeSize, lineArgs[3], lineArgs[4], lineArgs[5]]
        push!()
    end
else
    for i in 1:numNodeLines
        coords = [parse(Float64,j) for j in split(nodeLines[i],",")]
        #make sure labels are unique


        #xcoord, ycoord, label, nodesize, outlineColor, fillColor, labelColor
        newNode = [coords[1],coords[2],lineArgs[1], 10, "", lineArgs[4], lineArgs[5]]
        push!(nodelabels,lineArgs[1])
    end





# Plot it
# Hypergraph info








