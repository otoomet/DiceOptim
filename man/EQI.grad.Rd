\name{EQI.grad}
\Rdversion{1}
\alias{EQI.grad}

\title{ EQI's Gradient }

\description{
Analytical gradient of the Expected Quantile Improvement (EQI) criterion.
}

\usage{
EQI.grad(x, model, new.noise.var=0, beta=0.9, q.min=NULL, type = "UK", envir=NULL)
}

\arguments{
  \item{x}{ the input vector at which one wants to evaluate the criterion }
  \item{model}{ a Kriging model of "km" class }
  \item{new.noise.var}{ (scalar) noise variance of the future observation. 
Default value is 0 (noise-free observation).}  
  \item{beta}{ Quantile level (default value is 0.9) }  
  \item{q.min}{ Best kriging quantile. If not provided, this quantity is evaluated. } 
  \item{type}{ Kriging type: "SK" or "UK" }
  \item{envir}{ environment for inheriting intermediate calculations from EQI }
}
%\details{}
\value{Gradient of the Expected Quantile Improvement}
%\references{}
\author{
Victor Picheny (INRA, Castanet-Tolosan, France)

David Ginsbourger (University of Bern, Switzerland)
}
%\note{}

%\seealso{}

%
\examples{
\dontrun{
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
n.grid <- 12
x.grid <- y.grid <- seq(0,1,length=n.grid)
design.grid <- expand.grid(x.grid, y.grid)
nt <- nrow(design.grid)

crit.grid <- apply(design.grid, 1, EQI, model=model, 
new.noise.var=noise.var, beta=.9)
crit.grad <- t(apply(design.grid, 1, EQI.grad, model=model, 
new.noise.var=noise.var, beta=.9))

z.grid <- matrix(crit.grid, n.grid, n.grid)
contour(x.grid,y.grid, z.grid, 30)
title("EQI and its gradient")
points(model@X[,1],model@X[,2],pch=17,col="blue")

options(warn=-1)
for (i in 1:nt)
{
 x <- design.grid[i,]
 arrows(x$Var1,x$Var2, x$Var1+crit.grad[i,1]*.2,x$Var2+crit.grad[i,2]*.2, 
length=0.04,code=2,col="orange",lwd=2)
}
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory. \keyword{}
%\keyword{internal}
