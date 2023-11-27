printstyled("Interactive Julia Hypergraph Visualizizer Starting.\nLoading Packages...\n",color=:green)

include("./structs/Hypergraph.jl")
include("./help.jl")

debug = true
G = Hypergraph()
input = ""
commands= String[]
graphHistory = Hypergraph[]
intendedExit = false

showTicks = false
showLabels = true






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
        printred("Program Exited Unexpectedly, potentially via Keyboard Interrupt.")
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

            elseif commands[1] in addAliases
                if commands[2] == "node"
                    if commands[5] == "edge" && commandParts == 6
                        simpleAddNodetoEdge(G,commands[3],commands[6])
                    elseif commandParts == 2 # add node
                        nodetoadd = addNode(G, commands)
                    elseif commands[3] != "" # add node somethhing
                        nodetoadd = addNode(G, commands[3])
                    else
                        nodetoadd = addNode(G, commands)
                    end
                    
                end
                
            elseif commands[1] in removeAliases
                if commandParts !=3
                    printred("No subject to remove. Please try help remove.")
                elseif commands[2] == "node"
                    removeNode(G,commands[3])
                elseif commands[2] == "edge"
                    removeEdge(G,commands[3])
                end
            


            else 
                printred("$(join(commands," ")) is not a recognized Command.\nTry `help remove` for assistance.\n") 
                continue
            end
           
        setGraphLimits(G)
        displayGraph()

        catch e
            printred("Problem in promptLoop of input.jl\nPlease watch your syntax. Try `help` if you need.\n")
            if debug 
                printred("Rethrowing Error due to debug flag.\n")
                rethrow(e)
            end
        end
    end 

end

atexit(programExited)
promptLoop() 
intendedExit = true
exit(0)

