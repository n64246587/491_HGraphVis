using Plots, LazySets
include("hypergraph-processing.jl")
include("draw_helpers.jl")
hypname = "h3.txt"
xyname = "h3_xy.txt"

edges = load_hypergraph(hypname)
xy = load_xy(xyname)

n = size(xy,1)
exs = 0.0*ones(length(edges))

# Plot it
r = .35
nodesize = 18
txtsize = 14
termsize = 13
lw = 1.5
la = 1
lc = :black
ms = 10
plot_font = "computer modern"

## full
f = plot()
plot!(f, aspect_ratio=:equal)
plot!(f, grid = false,legend = false)
plot!(f, axis = false, xticks = false, yticks = false)

colorset = [:blue, :green, :red, :red, :blue, :green]
for j = 1:length(edges)
    if length(edges[j]) == 2
        u = edges[j][1]
        v = edges[j][2]
        plot!(f,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = :black,linewidth = lw)
    else
        ex = exs[j]
        color = :gray
        alp = .2
        H = hyperedgehull(xy, edges[j], r+ex)
        plot!(f,VPolygon(H),alpha = alp,linewidth = lw, markerstrokewidth = ms, color = colorset[j], linecolor = colorset[j],linealpha = la)
    end
end
scatter!(f,xy[:,1], xy[:,2],markerstrokewidth = 3,markersize = nodesize,color = :white)
labels = 1:17
for j = 1:size(xy,1)
    annotate!(f,xy[j,1], xy[j,2],text(labels[j],plot_font, txtsize))
end
f
# savefig("fairness-example.pdf")


## full
f = plot()
plot!(f, aspect_ratio=:equal)
plot!(f, grid = false,legend = false)
plot!(f, axis = false, xticks = false, yticks = false)

colorset = [:blue, :green, :red, :red, :blue, :green]
for j in [1,3,6]
    @show j, edges[j]
    if length(edges[j]) == 2
        u = edges[j][1]
        v = edges[j][2]
        plot!(f,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = :black,linewidth = lw)
    else
        ex = exs[j]
        color = :gray
        alp = .2
        H = hyperedgehull(xy, edges[j], r+ex)
        plot!(f,VPolygon(H),alpha = alp,linewidth = lw, markerstrokewidth = ms, color = colorset[j], linecolor = colorset[j],linealpha = la)
    end
end
scatter!(f,xy[:,1], xy[:,2],markerstrokewidth = 3,markersize = nodesize,color = :white)
labels = 1:17
for j = 1:size(xy,1)
    annotate!(f,xy[j,1], xy[j,2],text(labels[j],plot_font, txtsize))
end

f
# savefig("fairness-example.pdf")
