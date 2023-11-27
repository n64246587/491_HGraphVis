using Plots, LazySets
include("hypergraph-processing.jl")
include("draw_helpers.jl")
hypname = "h2.txt"
xyname = "h2_xy.txt"

edges = load_hypergraph(hypname)
xy = load_xy(xyname)

n = size(xy,1)
exs = 0.2*ones(length(edges))
# exs[3] = .0
# exs[4] = .15
# exs[5] = 0.25
# exs[6] = .4
# exs[7] = .4
# exs[8] = .25
# exs[9] = .1
# exs[10] = .00

# Plot it
r = .5
nodesize = 10
txtsize = 10
termsize = 13
lw = 1.5
la = 1
lc = :black
ms = 10
plot_font = "computer modern"
tag = "v1"
colorset = palette(:seaborn_colorblind)

f = plot()
# plot!(f,xlim = [-2,13], ylim = [-3,3])
plot!(f, aspect_ratio=:equal)
plot!(f, grid = false,legend = false)
plot!(f, axis = false, xticks = false, yticks = false)
# plot!(f, size = (300,350))

for j = 1:length(edges)
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
scatter!(f,xy[:,1], xy[:,2],markerstrokewidth = 3,markersize = nodesize,color = :black)
labels = 1:17
for j = 1:size(xy,1)
    annotate!(f,xy[j,1], xy[j,2],text(labels[j],plot_font, txtsize))
end
annotate!(f,5.5,2,text(" hyperedge X",:times, 16))

g = f
# savefig("hypergraph2.pdf")


## Clique expansion drawing

A1, A2 = CliqueExpansion(edges,17)

II,JJ,VV = findnz(A2)
f = plot()
# plot!(f,xlim = [-3,13], ylim = [-3,6])
plot!(f, aspect_ratio=:equal)
plot!(f, grid = false,legend = false)
plot!(f, axis = false, xticks = false, yticks = false)
# plot!(f, size = (300,350))
for j = 1:length(II)
    u = II[j]
    v = JJ[j]
    plot!(f,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = :black)
end
# scatter!(f,xy[:,1], xy[:,2],markerstrokewidth = 3,markersize = nodesize,color = :white)
scatter!(f,xy[1:5,1], xy[1:5,2],markerstrokewidth = 3,markersize = nodesize,color = :black)
scatter!(f,xy[6:9,1], xy[6:9,2],markerstrokewidth = 3,markersize = nodesize+2,color = :white)
scatter!(f,xy[10:17,1], xy[10:17,2],markerstrokewidth = 3,markersize = nodesize,color = :black)
labels = vec([collect(1:5); collect(1:4); collect(9:17)])
for j = 1:size(xy,1)
    annotate!(f,xy[j,1], xy[j,2],text(labels[j],plot_font, txtsize))
end
plot!(f,legend = false)

annotate!(f,2,3.6,text("a",:times, 16))
annotate!(f,2,0.4,text("c",:times, 16))
annotate!(f,3.6,2,text("d",:times, 16))
annotate!(f,0.4,2,text("b",:times, 16))
annotate!(f,5.5,4.4,text("f",:times, 16))
annotate!(f,5,3.2,text("g",:times, 16))
annotate!(f,5.5,-.4,text("h",:times, 16))
annotate!(f,6,.7,text("i",:times, 16))
annotate!(f,6.6,2,text("e",:times, 16))
f
# savefig("hypergraph2-exp.pdf")


##
plot(g,f, layout = (1,2), legend = false, size = (1000,500))
savefig("hypergraph2-plots-$tag.pdf")
