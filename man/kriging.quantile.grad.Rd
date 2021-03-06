\name{kriging.quantile.grad}

\alias{kriging.quantile.grad}

\title{ Analytical gradient of the Kriging quantile of level beta}

\description{ Computes the gradient of the Kriging quantile of level beta at the current location. Only available for Universal Kriging with constant trend (Ordinary Kriging). }

\usage{
kriging.quantile.grad(x, model, beta=0.1, type="UK",envir=NULL)}

%- maybe also 'usage' for other objects documented here.
\arguments{

  \item{x}{ a vector representing the input for which one wishes to calculate kriging.quantile.grad. }

  \item{model}{ an object of class \code{\link[DiceKriging]{km}}. }

  \item{beta}{ A quantile level (between 0 and 1) }

  \item{type}{ Kriging type: "SK" or "UK" }

  \item{envir}{ environment for inheriting intermediate calculations from \code{"kriging.quantile"} }
}

\value{
  The gradient of the Kriging mean predictor with respect to x. 
% Returns 0 at design points (where the gradient does not exist).
}
\author{
Victor Picheny (INRA, Castanet-Tolosan, France)

David Ginsbourger (IMSV, University of Berne, Switzerland)  
}


\references{

O. Roustant, D. Ginsbourger, Y. Deville,
\emph{DiceKriging, DiceOptim: Two R packages for the analysis of computer experiments by kriging-based metamodeling and optimization}, 
J. Stat. Soft., Vol. 51, Issue 1, Oct 2012.
\url{http://www.jstatsoft.org/v51/i01/}

D. Ginsbourger (2009), \emph{Multiples metamodeles pour l'approximation et l'optimisation de fonctions numeriques multivariables}, Ph.D. thesis, Ecole Nationale Superieure des
Mines de Saint-Etienne, 2009. 
\url{http://www.ginsbourger.ch/recherche/these.php}

}

\seealso{ \code{\link{EI.grad}} }

\keyword{models}
\keyword{optimize}

\examples{
\dontrun{
##########################################################################
###    KRIGING QUANTILE SURFACE AND ITS GRADIENT FOR                  ####
###    THE BRANIN FUNCTION KNOWN AT A 12-POINT LATIN HYPERCUBE DESIGN ####
##########################################################################
set.seed(421)

# Set test problem parameters
doe.size <- 12
dim <- 2
test.function <- get("branin2")
lower <- rep(0,1,dim)
upper <- rep(1,1,dim)
noise.var <- 0.2

# Generate DOE and response
doe <- as.data.frame(optimumLHS(n=doe.size, k=dim))
y.tilde <- rep(0, 1, doe.size)
for (i in 1:doe.size)  {
y.tilde[i] <- test.function(doe[i,]) + sqrt(noise.var)*rnorm(n=1)
}
y.tilde <- as.numeric(y.tilde)

# Create kriging model
model <- km(y~1, design=doe, response=data.frame(y=y.tilde),
        covtype="gauss", noise.var=rep(noise.var,1,doe.size), 
	lower=rep(.1,dim), upper=rep(1,dim), control=list(trace=FALSE))

# Compute actual function and criterion on a grid
n.grid <- 12 # Change to 21 for a nicer picture
x.grid <- y.grid <- seq(0,1,length=n.grid)
design.grid <- expand.grid(x.grid, y.grid)
nt <- nrow(design.grid)

crit.grid <- apply(design.grid, 1, kriging.quantile, model=model, beta=.1)
crit.grad <- t(apply(design.grid, 1, kriging.quantile.grad, model=model, beta=.1))

z.grid <- matrix(crit.grid, n.grid, n.grid)
contour(x.grid,y.grid, z.grid, 30)
title("kriging.quantile and its gradient")
points(model@X[,1],model@X[,2],pch=17,col="blue")

for (i in 1:nt)
{
 x <- design.grid[i,]
 arrows(x$Var1,x$Var2, x$Var1+crit.grad[i,1]*.01,x$Var2+crit.grad[i,2]*.01, 
length=0.04,code=2,col="orange",lwd=2)
}
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory. \keyword{}
%\keyword{internal}
