#format 12th chat=racter is a line
#
const header =      "\nAll imputs are lowercased, therefore the prompt is not case sensitive.\n" * 
                    "Words in backticks such as `nodelabel` are variables for you to fill in. Do not type the backticks.\n" * 
                    "Words in curly brackets such as {`edge`} optional and specifying them may change the way the command works. Do not type the curly brackets.\n" * 
                    "Words in square brackets seperated by a slash such as [node/edge] mean that you should pick one of the options and type it. Do not type the square brackets or the slash.\n\n" * 
                    "|  Command   |                                      Description                                      |                       Syntax                       |\n"*
                    "|____________|_______________________________________________________________________________________|____________________________________________________|"
const quitHelp =    "|    Quit    |                Exits the program and all unsaved changes will be lost                 |                       quit                         |"
const addHelp =     "|    Add     |                    Adds a node with label `nodelabel` to the graph                    |                 add node `nodeLabel`               |\n"*
                    "|    Add     |           Adds a node with label `nodelabel to the edge labeled `edgelabel`           |      add node `nodeLabel` to edge `edgeLabel`      |"
const removeHelp =  "|   Remove   |             Remove a node or edge with the specified label from the graph             |             remove [node/edge] `label`             |"
const moveHelp =    "|    Move    |     Move the node with label `nodelabel` directly to the position `xCoord` `yCoord`   |     move node `nodeLabel` to `xCoord` `yCoord`     |\n"*
                    "|    Move    |    Move the node with label `nodelabel` in the specified diirection by `value` units  | move node `nodeLabel` [up/down/left/right] `value` |"
const layoutHelp=   "|   Layout   |             Applies the specified layout to the xy coordinates of all nodes           |          layout [force,spectral,circle]            |"
const toggleHelp =  "|   Toggle   |               Turns on or off the specified feature of the visualization              |            toggle [grid, label, legend]            |"
const loadHelp =    "|    Load    |     Load the text file `filepath.txt` which will override the current session data    | load [nodes/edges/nodemeta/edgemeta] `filepath.txt`|"
const edgeModeHelp= "|  Edgemode  |                       Specify how hyperedges should be rendered                       |       edgemode [none/clique/bipartite/convex]      |"
const hullSizeHelp= "|  Hullsize  | Set hull radius of all convex hulls to `radius`. If `edge` given, will only affect it |             hullsize {`edge`} `radius`             |"
const edgelistHelp= "|  Edgelist  |  List all edges. If `node` is given, will only list edges with that node as a member  |                 edgelist {`node`}                  |"
const setColorHelp= "|  Setcolor  |  Set the color of the given node or edge with the label `label` to the color `color`  |        setcolor [node/edge] `label` `color`        |"
const saveHelp=     "|    Save    |    Save the session to 4 txt files (nd,ndm,eg,egm) that look like `filepath-().txt`   |                  saveas `filepath.txt`                 |"

#TODO change buffer around the nodes
#TODO show edgeList "either all or of a node"
#TODO show skip the middle man ba able to specify an edge by its members [1,2,5] or maybe [1 2 5]
#comprehense list
#TODO make a get label from edges function.

#aliases
const quitAliases = ["q","quit","exit","exit()","quit()"]
const addAliases = ["add"]
const removeAliases = ["remove","rm"]
const moveAliases = ["move","mv"]
const layoutAliases = ["layout"]

const loadAliases = ["load"]
const loadNodesAliases = ["nodes", "node", "coord", "coords", "xy", "xys"]
const loadEdgesAliases = ["edges","edge","graph","hypergraph","g","hg"]
const loadNodeMetaAliases = [["meta"*i for i in loadNodesAliases]; ["m"*i for i in loadNodesAliases]]
const loadEdgeMetaAliases = [["meta"*i for i in loadEdgesAliases]; ["m"*i for i in loadEdgesAliases]]


const toggleAliases = ["toggle","tg"]
const edgeModeAliases = ["edgemode","edges","em"]
const setHulllRadiusAliases = ["buffer","hullsize","hullradius","setbuffer", "sethullsize", "sethullradius"]
const edgelistAliases = ["edgelist","edges","neighborhood","neighbor"]
const setColorAliases = ["setcolor","color"]
const saveAliases = ["save","saveas"]

function printHelp(commands::Vector{String} = String[])
    println(header)
    if commands[1] in quitAliases println(quitHelp)
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
    
    end
    println()
end

function allHelp()
    println(header)
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

end

#layout constants
const degreeAliases = ["degree","degreedependent"]
const circularAliases = ["cir","circ","circle","circular"]
const forceAliases = ["force-directed","force","forcedirected"]
const spectralAliases = ["spectral","spec"]

#edgemode constants
const cliqueAliases = ["clique","c","3"]
const bipartiteAliases = ["bipartite","b","2"]
const convexAliases = ["convex","hull","convexhull","1"]
const noEdgeTypeAliases = ["none", "no" , "0"]