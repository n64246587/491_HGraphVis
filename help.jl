#format 12th chat=racter is a line
#
header =      "\nAll imputs are lowercased, therefore the prompt is not case sensitive. All input files should also be lowercased\n" * 
                    "Words in backticks such as `nodelabel` are variables for you to fill in. Do not type the backticks.\n" * 
                    "Words in curly brackets such as {`edge`} optional and specifying them may change the way the command works. Do not type the curly brackets.\n" * 
                     "Words in square brackets seperated by a slash such as [node/edge] mean that you should pick one of the options and type it. Do not type the square brackets or the slash.\n" *
                     "Words in quotation marks such as \"Yes\" mean that you should type the string within the quotation marks literally. Do not type the quotation marks.\n" *
                     "If you see an equal sign after a parameter, such as `hullsize`=0.25, that is an indication of the default, unmodified value for that field.\nYou do still have to specify your value. Do not type the equal sign or default value.\n\n" *  
                      "|  Command   |                                      Description                                      |                         Syntax                         |\n"*
                      "|____________|_______________________________________________________________________________________|________________________________________________________|"
helpHelp=       "|    Help    |   Shows this table if no arguments and shows a specific command's entry id specified  |                     help {`command`}                   |"
quitHelp =      "|    Quit    |                Exits the program and all unsaved changes will be lost                 |                         quit                           |"
addHelp =       "|    Add     |                               Adds a node to the graph                                |                       add node                         |\n"*
                      "|    Add     |           Adds a node with label `nodelabel to the edge labeled `edgelabel`           |              add node to edge `edgeLabel`              |"
removeHelp =    "|   Remove   |             Remove a node or edge with the specified label from the graph             |               remove [node/edge] `label`               |"
moveHelp =      "|    Move    |     Move the node with label `nodelabel` directly to the position `xCoord` `yCoord`   |      move {node} `nodeLabel` to `xCoord` `yCoord`      |\n"*
                      "|    Move    |    Move the node with label `nodelabel` in the specified diirection by `value` units  |  move {node} `nodeLabel` [up/down/left/right] `value`  |"
layoutHelp=     "|   Layout   |             Applies the specified layout to the xy coordinates of all nodes           |            layout [force,spectral,circle]              |"
toggleHelp =    "|   Toggle   |               Turns on or off the specified feature of the visualization              |         toggle [grid, label, legend, warnings]         |"
loadHelp =      "|    Load    |     Load the text file `filepath.txt` which will override the current session data    | load [nodes/edges/nodemeta/edgemeta/all] `filepath.txt`|"
edgeModeHelp=   "|  Edgemode  |    Specify how the edge with label `edgeLabel` or all hyperedges should be rendered   |  edgemode {`edgeLabel`} [none/clique/bipartite/convex] |"
hullSizeHelp=   "|  Hullsize  |    Set the hullsize in convex mode of the edge with label `edgeLabel` or all edges    |        hullsize {`edgeLabel`} `hullsize`=0.25          |"
edgelistHelp=   "|  Edgelist  |  List all edges. If `node` is given, will only list edges with that node as a member  |                   edgelist {`node`}                    |"
setColorHelp=   "|  Setcolor  |  Set the color of the given node or edge with the label `label` to the color `color`  |    setcolor [nodefill/nodelabel/edge] `label` `color`  |"
saveHelp=       "|    Save    |    Save the session to 4 txt files (nd,ndm,eg,egm) that look like `filepath-().txt`   |                  saveas `filepath.txt`                 |"
edgeFillHelp=   "|  edgefill  |    Set the opacity in convex mode of the edge with label `edgeLabel` or all edges     |         edgefill {`edgeLabel`} `opacity`=0.0           |"
nodeSizeHelp =  "|  nodesize  |      Sets the nodesize for a node with label `nodelabel` to value, or all nodes       |               nodesize `nodeLabel` `value`             |"
swapNodesHelp = "|  swapnodes |    Swaps the xy coordinates of the nodes with labels `nodeLabel1` and `nodeLabel2`    |           swapnodes `nodeLabel1` `nodeLabel2`          |"
clearHelp =     "|    clear   |   Entirely removes all nodes and edges from the graph. Requires confirmation of YES   |                     clear {\"YES\"}                      |"
#backgroundHelp= "| background |  Set the bg to an image specified by `filepath` or rests the bg if filepath is blank  |                 background `filepath`                  |"

nodeAliases = ["n", "node","nodes","nodefill"]
edgeAliases = ["e", "edge", "edges","hyperedge"]
nodeLabelAliases = ["nodelabel","nodeoutline","nl","no"]

#aliases
helpAliases = ["help", "?"]
quitAliases = ["q","quit","exit","exit()","quit()"]
addAliases = ["add"]
removeAliases = ["remove","rm"]
moveAliases = ["move","mv"]
layoutAliases = ["layout"]

loadAliases = ["load"]
loadAllAliases = ["all","a","ne","en","full","src","source"]
loadNodesAliases = ["nodes", "node", "coord", "coords", "xy", "xys"]
loadEdgesAliases = ["edges","edge","graph","hypergraph","g","hg"]
loadNodeMetaAliases = [["meta"*i for i in loadNodesAliases]; ["m"*i for i in loadNodesAliases]]
loadEdgeMetaAliases = [["meta"*i for i in loadEdgesAliases]; ["m"*i for i in loadEdgesAliases]]


toggleAliases = ["toggle","tg"]
edgeModeAliases = ["edgemode","edges","em"]
setHulllRadiusAliases = ["buffer","hullsize","hullradius","setbuffer", "sethullsize", "sethullradius"]
edgelistAliases = ["edgelist","edges","neighborhood","neighbor"]
setColorAliases = ["setcolor","color"]
saveAliases = ["save","saveas"]
edgeFillAliases = ["edgefill","ef","fill","opacity"]

nodeSizeAliases = ["ns","nodesize", "size"]
swapNodesAliases = ["swapnodes","swapnode","sn"]

backgroundAliases = ["background","bg"]
clearAliases = ["clear","empty"]

function printHelp(commands::Vector{String} = String[])
    println(header)
    if commands[1] in helpAliases println(helpHelp) 
    elseif commands[1] in quitAliases println(quitHelp)
    elseif commands[1] in addAliases println(addHelp)
    elseif commands[1] in removeAliases println(removeHelp)
    elseif commands[1] in toggleAliases println(toggleHelp)
    elseif commands[1] in moveAliases println(moveHelp)
    elseif commands[1] in layoutAliases println(layoutHelp)
    elseif commands[1] in loadAliases println(loadHelp)
    elseif commands[1] in edgeModeAliases println(edgeModeHelp)
    elseif commands[1] in setHulllRadiusAliases println(hullSizeHelp)
    elseif commands[1] in edgelistAliases println(edgelistHelp)
    elseif commands[1] in setColorAliases println(setColorHelp)
    elseif commands[1] in saveAliases println(saveHelp)
    elseif commands[1] in edgeFillAliases println(edgeFillHelp)
    elseif commands[1] in nodeSizeAliases println(nodeSizeHelp)
    elseif commands[1] in swapNodesAliases println(swapNodesHelp)
    elseif commands[1] in clearAliases println(clearHelp)
    #elseif commands[1] in backgroundAliases println(backgroundHelp)
    
    end
    println()
end

function allHelp()
    println(header)
    println(helpHelp) 
    println(quitHelp)
    println(addHelp)
    println(removeHelp)
    println(toggleHelp)
    println(moveHelp)
    println(layoutHelp)
    println(loadHelp)
    println(edgeModeHelp)
    println(hullSizeHelp)
    println(edgelistHelp)
    println(setColorHelp)
    println(saveHelp)
    println(edgeFillHelp)
    println(nodeSizeHelp)
    println(swapNodesHelp)
    println(clearHelp)
    #println(backgroundHelp)

end

#layout constants
degreeAliases = ["degree","degreedependent"]
circularAliases = ["cir","circ","circle","circular"]
forceAliases = ["force-directed","force","forcedirected"]
spectralAliases = ["spectral","spec"]

#edgemode constants
cliqueAliases = ["clique","c","3"]
bipartiteAliases = ["bipartite","b","bi","2"]
convexAliases = ["convex","hull","convexhull","1"]
noEdgeTypeAliases = ["none", "no" , "0"]

# directionAliases
upAliases = ["up","u","y","north","n"]
downAliases = ["down","d","-y","south","s"]
leftAliases = ["left","l","-x","west","w"]
rightAliases = ["right","r","east","e","x"]

upRightAliases = ["upright","rightup","ur","ru","northeast","ne"]
downRightAliases = ["downright","rightdown","dr","rd","southeast","se"]
upLeftAliases = ["upleft","leftup","ul","lu","northwest","nw"]
downLeftAliases = ["downleft","leftdown","dl","ld","southestt","sw"]