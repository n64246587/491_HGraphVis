printstyled("Interactive Julia Hypergraph Visualizizer Starting.\nLoading Packages...\n",color=:green)

include("./structs/Hypergraph.jl")

debug = false
G = Hypergraph()
input = ""
commands= String[]
graphHistory = Hypergraph[]
intendedExit = false
const quitAliases = ["q","quit","exit","exit()","quit()"]
showTicks = false
showLabels = true




quitHelp="Quit Help Not yet Impemented"
function printHelp(commands::Vector{String} = String[])
    if isempty(commands)
        println(quitHelp)
    elseif commands[1] in quitAliases
        println(quitHelp)
    end
end

function displayGraph()
    if (isnothing(G))
        global G = Graph()
        empty!(G.nodes)
        empty!(G.edges)
    end
    display(makePlot(G, showTicks, showLabels))
end

function programExited()
    global intendedExit
    if intendedExit
        printgreen("Program Exited Safely. Bye.")
    else
        printred("Program Exited Unexpectedly.")
    end
end

ssplit(s::String,delim::String=" ")::Vector{String} = [lowercase(String(i)) for i in split(strip(s), delim)] 



function promptLoop()
    global G
    global debug

    while true
        try
            print("Enter a Command: ")
            commands = ssplit(readline())
            commandParts = length(commands)
            if commandParts == 0
                printred("Empty Command, Please Try Again\n")
                continue
            end
            if commands[1] in quitAliases return 
            elseif commands[1] == "help" 
                if commandParts <2 printHelp() else printHelp(commands[2:end]) end
            elseif commands[1] == "add"
                addNode(G, commands)
                setGraphLimits(G)
                displayGraph()
            elseif commands[1] == "remove"
            else printred("Unrecognized Command, Please Try Again or type Help\n")



            
            
            
            
            
            end
           
        display(makePlot(G))

        catch e
            if debug rethrow(e) end
            printred("Problem in promptLoop\n")
            rethrow(e)
        end
    end 

end
atexit(programExited)
promptLoop() 
intendedExit = true
exit(0)

