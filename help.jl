
const quitAliases = ["q","quit","exit","exit()","quit()"]
const quitHelp="Quit Help Not yet Impemented"

const addAliases = ["add"]
const addHelp="Add Help Not yet Impemented"

const removeAliases = ["remove"]
const removeHelp="Quit Help Not yet Impemented"


function printHelp(commands::Vector{String} = String[])
    if isempty(commands)
        println(quitHelp)
    elseif commands[1] in quitAliases
        println(quitHelp)
    elseif commands[1] in addAliases
        println(addHelp)
    elseif commands[1] in removeAliases
        println(removeHelp)
    end
end