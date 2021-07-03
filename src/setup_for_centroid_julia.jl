"""
Calculate the best peak and centroid and their uncertainties using the median of the
distributions
"""
function bestcent(inpcent)
    perclim = 84.1344746
    centau = percentile(inpcent, 50)
    centau_uperr = (percentile(inpcent, perclim))-centau
    centau_loerr = centau-(percentile(inpcent, (100.0-perclim)))
    #print('Centroid, error: %10.3f  (+%10.3f -%10.3f)'%(centau, centau_loerr, centau_uperr))
    return centau,centau_loerr,centau_uperr
end

function centerror(centdistr)
    centau,centau_loerr,centau_uperr = bestcent(centdistr)
    return centau,centau_loerr,centau_uperr
end
