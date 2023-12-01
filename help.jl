
const quitAliases = ["q","quit","exit","exit()","quit()"]
const quitHelp="q #This will exit the program"

const addAliases = ["add"]
const addHelp=
"""add node `nodeLabel`
add node `nodeLabel` to edge `edgeLabel`"""

const removeAliases = ["remove","rm"]
const removeHelp="remove [node,edge] `label`"

const moveAliases = ["move","mv"]
const moveHelp=
"""move node `nodeLabel` to `xCoord` `yCoord`
move node `nodeLabel` [up/down/left/right] `value`"""

const layoutAliases = ["layout"]
const layoutHelp="layout [force,spectral,circle]"

const loadAliases = ["load"]
const loadxyAliases = ["xy","coords"]
const loadgraphAliases = ["g","graph","h","hg","hgraph","hypergraph"]
const loadallAliases = ["all","both"]

const toggleAliases = ["toggle","tg"]
const toggleHelp = "toggle [grid, label, legend]"


const loadHelp = 
"""load xy `filepath.txt`
load graph `filepath.txt
load `graph.txt` `xy.txt`"""

const edgeModeAliases = ["edgemode","edges","em"]
const edgeModeHelp = "edgemode [clique, bipartite, convex]"

function printHelp(commands::Vector{String} = String[])
    if commands[1] in quitAliases println(quitHelp)
    elseif commands[1] in addAliases println(addHelp)
    elseif commands[1] in removeAliases println(removeHelp)
    elseif commands[1] in toggleAliases println(toggleHelp)
    elseif commands[1] in moveAliases println(moveHelp)
    elseif commands[1] in layoutAliases println(layoutHelp)
    elseif commands[1] in loadAliases println(loadHelp)
    elseif commands[1] in edgeModeAliases println(edgeModeHelp)
    
    end
end

function allHelp()
    println("All Help")
    println(quitHelp)
    println(addHelp)
    println(removeHelp)
    println(toggleHelp)
    println(moveHelp)
    println(layoutHelp)
    println(loadHelp)
    println(edgeModeHelp)
end

#layout constants
const degreeAliases = ["degree","degreedependent"]
const circularAliases = ["cir","circ","circle","circular"]
const forceAliases = ["force-directed","force","forcedirected"]
const spectralAliases = ["spectral","spec"]

#edgemode constants
const cliqueAliases = ["clique","c"]
const bipartiteAliases = ["bipartite","b"]
const convexAliases = ["convex","hull","converhull"]