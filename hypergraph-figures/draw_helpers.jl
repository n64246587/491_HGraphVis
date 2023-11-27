function circlepoints(center,radius,pts = 100)
# Return a list of points that define a circle with 
# specified center and radius, using 20 evenly spaced points

    rads = LinRange(0,2*pi, pts)
    X = Vector{Vector{Float64}}()
    # Y = zeros(pts,2)
    for i = 1:pts
        x = radius*cos(rads[i]) + center[1]
        y = radius*sin(rads[i]) + center[2]
        push!(X,[x;y])
        # Y[i,:] = [x,y]
    end

    return X
end

function hyperedgehull(xy, e, r)
# xy gives the (x,y) coordinates for nodes
# e is a set of indices defining a hyperedge
# r controls how much of a border to put around nodes
# Output: a convex hull object that defines the hyperedge
    print("This call's e is $e")
    c = xy[e[1],:]
    p = circlepoints(c,r)
    for i = 2:length(e)
        c = xy[e[i],:]
        append!(p, circlepoints(c,r))
    end 
    H = convex_hull(p)
    return H
end


function circleplot(f,Y)
    scatter!(f,Y[:,1],Y[:,2])
end

function personshape()
    xx = Vector{Float64}()
    yy = Vector{Float64}()

    low = -1.5
    push!(xx,2)
    push!(yy,low)

    pts = 100
    rads = LinRange(0,pi/2, pts)
    radius = 1
    t = 1
    x = radius*cos.(rads).+t
    y = radius*sin.(rads)

    append!(xx,x)
    append!(yy,y)

    rads = LinRange(-pi/2,3*pi/2, pts)
    radius = 1
    x = radius*cos.(rads)
    y = radius*sin.(rads) .+ 2

    append!(xx,x)
    append!(yy,y)

    rads = LinRange(pi/2,pi, pts)
    radius = 1
    x = radius*cos.(rads).-t
    y = radius*sin.(rads)

    append!(xx,x)
    append!(yy,y)

    push!(xx,-2)
    push!(yy,low)
    push!(xx,2)
    push!(yy,low)

    return Shape(xx,yy)
end