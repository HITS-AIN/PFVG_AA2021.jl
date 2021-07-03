
include("mathlc.jl")
include("setup_for_centroid.jl")
@pyimport matplotlib.font_manager as fm

"""
Run PFVG method
# Example
```julia-repl
julia> include("PFVG.jl")
julia> runPFVG()
```
"""
function runPFVG()
    dirlc = "./data/"
    lc = [dirlc*"bj.txt",dirlc*"vj.txt",dirlc*"rj.txt",dirlc*"ij.txt"]
    filter_vec = ["B","V","R","I"]
    B     = readdlm(lc[1])[:, 1:3]
    V     = readdlm(lc[2])[:, 1:3]
    R     = readdlm(lc[3])[:, 1:3]
    I     = readdlm(lc[4])[:, 1:3]

    #select same dates between B and I
    samet1,sflxB1,sflxI = mergeTimeSeries(B[:,1]',I[:,1]',B[:,2],I[:,2])
    samet1,EsflxB1,EsflxI = mergeTimeSeries(B[:,1]',I[:,1]',B[:,3],I[:,3])
    #select same dates between previous selected B and V
    samet2,sflxB2,sflxV = mergeTimeSeries(samet1',V[:,1]',sflxB1,V[:,2])
    samet2,EsflxB2,EsflxV = mergeTimeSeries(samet1',V[:,1]',EsflxB1,V[:,3])
    #select same dates between previous selected B and R
    samet3,sflxB3,sflxR = mergeTimeSeries(samet2',R[:,1]',sflxB2,R[:,2])
    samet3,EsflxB3,EsflxR = mergeTimeSeries(samet2',R[:,1]',EsflxB2,R[:,3])
    #
    samet,sflxB,sflxI   = mergeTimeSeries(samet3',samet1',sflxB2,sflxI)
    samet,EsflxB,EsflxI   = mergeTimeSeries(samet3',samet1',EsflxB2,EsflxI)

    ndata = length(samet)
    data  = zeros(4,3,ndata)

    flx   = [sflxB,sflxV,sflxR,sflxI]
    eflx  = [EsflxB,EsflxV,EsflxR,EsflxI]

    for i in 1:length(lc)
        obstime = samet #time
        flux    = flx[i]
        errflx  = eflx[i] #errflux
        data[i,1,:] = obstime
        data[i,2,:] = flux
        data[i,3,:] = errflx
    end

    #start PVFG
    @eval using ProbabilisticFluxVariationGradient

    flx = data[:,2,:]
    sig = data[:,3,:]

    # run for one iteration only for warmup (i.e. when first run Julia pre-compiles code)
    #posterior = bpca(flx, sig,maxiter=1)
    # run for more iterations (default value of maxiter is 1000)
    #posterior = bpca(flx, sig,maxiter=500)
    posterior = bpca(flx, sig,maxiter=1000)

    galfile  = dirlc*"Galaxy_vec.txt"

    rgalfile = readdlm(galfile)[:,1]
    galaxyvec = rgalfile[:,1]

    g     = galaxyvec #galaxy fluxes in mJy
    randx = noisyintersectionvi(posterior = posterior, g = g)

    #return random galaxy values
    nsamp = 10000
    rangal = zeros(4,nsamp) #(filters,column,numbers)

    for i in 1:length(lc)
        for j in 1:nsamp
            galrandom = randx()[i]
            rangal[i,j] = galrandom
        end
        #save to file
        writedlm(dirlc*"PFVG.dist.3C120."*filter_vec[i]*".txt", rangal[i,:])
    end
end


"""
Plot PFVG host-galaxy distributions
# Example
```julia-repl
julia> include("PFVG.jl")
julia> PlotPFVG3C120()
```
"""
function PlotPFVGdist()
    dirlc = "./data/"
    distfiles = [dirlc*"PFVG.dist.3C120.B.txt",dirlc*"PFVG.dist.3C120.V.txt",dirlc*"PFVG.dist.3C120.R.txt",dirlc*"PFVG.dist.3C120.I.txt"]
    color_vec  = ["blue","green","brown","red"]
    filter_vec = ["B","V","R","I"]

    fvggal = [1.69;3.89;5.90;8.97] # FVG results for 3C120
    snvec  = [46;82;87;112] #Light curves S/N


    prop = fm.FontProperties(size=12)
    pygui(true)
    fig  = figure(1,figsize=(15,15))

    for i in 1:length(distfiles)
        distmp   = readdlm(distfiles[i])[:, 1]
        distfvg  = distmp[:,1]
        tmp = 220+i
        ax = subplot(tmp)
        binsize=50
        centgal,centgal_loerr,centgal_uperr = centerror(distfvg)
        text1 = L"$f^{host}$ = "*@sprintf("%.3f", centgal)*"+"*@sprintf("%.3f", centgal_loerr)*"-"*@sprintf("%.3f", centgal_uperr)
        ax.hist(distfvg,bins=binsize,alpha=0.8,color=color_vec[i],label=text1)
        ax.fill_between([centgal-centgal_loerr, centgal+centgal_uperr],[0, 0],[1.1*150, 1.1*150], linestyle="--", color="black", alpha=1.0)
        ax.plot([fvggal[i],fvggal[i]],[0,1000],"--",linewidth=2,color="black")
        ax.text(centgal-0.008*centgal,800,"S/N = "*@sprintf("%.1f", snvec[i]),color="black",fontsize=15)

        if i==1
            ax.text(0.9,800,"3C120",fontsize=15)
            #ax.set_xlim(0.6,1.9)
        end
        ax.set_ylim(0,1000)
        ax.set_xlabel(L"$f_{host}$ "*filter_vec[i]*" [mJy]",fontsize=15)
        ax.set_ylabel("Frequency",fontsize=15)
        ax.tick_params(direction="in",labelsize=14)
        ax.legend(loc="upper left",prop=prop)
    end
    savefig(dirlc*"PFVG3C120.pdf",bbox_inches="tight")
end


"""
Inspect 3C120 light curves
# Example
```julia-repl
julia> include("PFVG.jl")
julia> Check3C120()
```
"""

function Check3C120()
    dirlc = "./data/"
    #read and plot lc's
    lc = [dirlc*"bj.txt",dirlc*"vj.txt",dirlc*"rj.txt",dirlc*"ij.txt"]
    filtervec = ["B","V","R","I"]
    colorvec  = ["blue","green","brown","red"]

    #find the minimum day for all the observations:
    minmjd = zeros(length(lc))
    for i in 1:length(lc)
        glc    = readdlm(lc[i])[:, 1:3]
        mjd    = glc[:,1] #time in MJD
        minmjd[i] = minimum(mjd)
    end
    mmjd = minimum(minmjd)

    #read separate
    B     = readdlm(lc[1])[:, 1:3]
    V     = readdlm(lc[2])[:, 1:3]
    R     = readdlm(lc[3])[:, 1:3]
    I     = readdlm(lc[4])[:, 1:3]

    #select same dates between B and V
    samet,sflxB,sflxV = mergeTimeSeries(B[:,1]',V[:,1]',B[:,2],V[:,2])
    sametBV = samet .- mmjd

    #select same dates between B and r
    samettmp,sflxBr,sflxr = mergeTimeSeries(B[:,1]',R[:,1]',B[:,2],R[:,2])
    sametBr = samettmp .- mmjd
    #select same dates between B and z
    samettmp,sflxBz,sflxz = mergeTimeSeries(B[:,1]',I[:,1]',B[:,2],I[:,2])
    sametBz = samettmp .- mmjd


    #ploting
    prop = fm.FontProperties(size=15)
    figure(1)
    clf()

    for i in 1:length(lc)
        glc     = readdlm(lc[i])[:, 1:3]
        mjd     = glc[:,1] #time
        flux    = glc[:,2] #flux
        errflx  = glc[:,3] #errflux
        obsdays = mjd .- mmjd

        plot(obsdays,flux,ls="", marker=".", ms=4,color=colorvec[i],label=filtervec[i])
        errorbar(obsdays, flux, yerr=errflx, fmt="o", ms=4, color=colorvec[i])
        legend(loc="upper right",prop=prop)

    end
    plot(sametBV,sflxB,ls="", marker="o", ms=8,color="black")
    plot(sametBV,sflxV,ls="", marker="o", ms=8,color="black")
    plot(sametBr,sflxr,ls="", marker="o", ms=8,color="black")
    plot(sametBz,sflxz,ls="", marker="o", ms=8,color="black")
    #xlim(0.0,maxday)
    #ylim(3.0,8.0)
    xlabel("Days after MJD"*string(mmjd),fontsize=20)
    ylabel("Flux (mJy)",fontsize=20)
    tick_params(direction="in",labelsize=14)
    gcf()
end
