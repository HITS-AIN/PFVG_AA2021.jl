# PFVG-AA2021

Application of the probabilistic flux variation gradient (PFVG) method, as presented
in Gianniotis, N., Pozo Nunez, F., and Polsterer, K.L. (2021).

In the following examples we apply the PFVG method on observations from the source
3C120. The light curves for 3C120 have been taken from the published work of [Ramolla et al. (2018)](https://www.aanda.org/articles/aa/pdf/2018/12/aa32081-17.pdf).


# Installation


# Visualize 3C120 light curves

The light curves for 3C120 can be inspected using the following command:

```
Check3C120()
```

This will output the following plot:

![](src/plots/lcs.png)

The filled circles mark simultaneous observations obtained for each filter. These observations are used in the
PFVG analysis.

# PFVG Application

To run the PFVG method on the light curves above, run the code:

```
runPFVG()
```

The code will use the light curves stored in the data folder and output the distribution
of host-galaxy fluxes as ascii files with names PFVG.dist.object.filter.txt, in the same data folder.
The input galaxy color vector taken from Sakata et al. (2010) is stored as Galaxy_vec.txt

To plot the distributions use the following command:

```
PlotPFVGdist()
```

This will output the following plot:

![](src/plots/pfvgdist.png)

which is the same as Fig. A.5 presented in Gianniotis, N., Pozo Nunez, F., and Polsterer, K.L. (2021).

# Questions, ideas, suggestions, etc..

email: francisco.pozonunez@h-its.org
