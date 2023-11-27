using Plots, LazySets
include("draw_helpers.jl")
#I had to include this because hyperedgehull would not compile
include("hypergraph-processing.jl")

hypname = "h1.txt"
xyname = "h1_xy.txt"

edges = load_hypergraph(hypname)
println(edges)
xy = load_xy(xyname)

n = size(xy,1)
exs = 0.2*ones(length(edges))
exs[3] = .0
exs[4] = .15
exs[5] = 0.25
exs[6] = .4
exs[7] = .4
exs[8] = .25
exs[9] = .1
exs[10] = .00

# Plot it
r = .5
nodesize = 9
txtsize = 8
termsize = 13
lw = 1.5
la = 1
lc = :black
ms = 10
plot_font = "computer modern"
tag = "variant1"
colorset = palette(:seaborn_colorblind)

f = plot()
plot!(f,xlim = [-2,5], ylim = [-5,5])
plot!(f, aspect_ratio=:equal)
plot!(f, grid = false,legend = false)
plot!(f, axis = false, xticks = false, yticks = false)
plot!(f, size = (400,300))

for j = 1:10
    if length(edges[j]) == 2
        u = edges[j][1]
        v = edges[j][2]
        plot!(f,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = :black,linewidth = lw)
    else
        ex = exs[j]
        color = :gray
        alp = .05
        H = hyperedgehull(xy, edges[j], r+ex)
        plot!(f,VPolygon(H),alpha = alp,linewidth = lw, markerstrokewidth = ms, linecolor = colorset[j],linealpha = la)
    end
end
scatter!(f,xy[:,1], xy[:,2],markerstrokewidth = 3,markersize = nodesize,color = :white)
labels = ["a", "b", "c", "d", "e", "f", "x"]
for j = 1:size(xy,1)
    annotate!(f,xy[j,1], xy[j,2],text(labels[j],plot_font, txtsize))
end
g = f
# savefig("hypergraph1.pdf")


## Clique expansion drawing

A1, A2 = CliqueExpansion(edges,7)

II,JJ,VV = findnz(A2)
f = plot()
plot!(f,xlim = [-2,5], ylim = [-5,5])
plot!(f, aspect_ratio=:equal)
plot!(f, grid = false,legend = false)
plot!(f, axis = false, xticks = false, yticks = false)
plot!(f, size = (400,300))
for j = 1:length(II)
    u = II[j]
    v = JJ[j]
    plot!(f,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = :black)
end
other = [1 2; 3 6; 4 5]
for j = 1:3
    u = other[j,1]
    v = other[j,2]
    plot!(f,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = :blue, style = :dash)
end
scatter!(f,xy[:,1], xy[:,2],markerstrokewidth = 3,markersize = nodesize,color = :white)
#labels = ["a", "b", "c", "d", "e", "f", "x"]
labels = ["1","2","3","4","5","6","7"]
for j = 1:size(xy,1)
    annotate!(f,xy[j,1], xy[j,2],text(labels[j],plot_font, txtsize))
end

savefig("hypergraph1-exp.pdf")
display(f)
println("f should be displaying")
readline()


#
plot(g,f, layout = (1, 2), legend = false)

savefig("hypergraph1-plots-$tag.pdf")
display(g)
println("g should be displaying")
readline()
