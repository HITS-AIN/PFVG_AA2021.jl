using PyCall, Interpolations

py"""

import numpy as np
import scipy.stats as sst

def bestcent(inpcent):
    '''
    Calculate the best peak and centroid and their uncertainties using the median of the
    distributions
    '''
    perclim = 84.1344746
    centau = sst.scoreatpercentile(inpcent, 50)
    centau_uperr = (sst.scoreatpercentile(inpcent, perclim))-centau
    centau_loerr = centau-(sst.scoreatpercentile(inpcent, (100.-perclim)))
    #print('Centroid, error: %10.3f  (+%10.3f -%10.3f)'%(centau, centau_loerr, centau_uperr))
    return centau,centau_loerr,centau_uperr

"""

function centerror(centdistr)
    centau,centau_loerr,centau_uperr = py"bestcent($centdistr)"
    return centau,centau_loerr,centau_uperr
end
