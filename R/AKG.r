AKG <- function(x, model, new.noise.var=0, type = "UK", envir=NULL)
{

d <- length(x)
newdata <- matrix(x, 1, d)
type="UK"
tau2.new <- new.noise.var

######### Compute prediction at x #########
predx <- predict.km(model, newdata=newdata, type=type, checkNames = FALSE)
mk.x <- predx$mean
c.x  <- predx$c
V.x <- predx$Tinv.c
T <- model@T
z <- model@z
U <- model@M

sk.x <- sqrt(model@covariance@sd2 - t(V.x)%*%V.x + (1 - t(V.x)%*%U)^2/(t(U)%*%U))

######### Compute prediction at X #########
predX <- predict.km(model, newdata=model@X, type=type, checkNames = FALSE)
mk.X <- predX$mean
V.X <- predX$Tinv.c

######### Compute m_min #########
m_min <- min(c(mk.X,mk.x))

######### Compute cn #########
mu.x <- (1 - t(V.x)%*%U)/(t(U)%*%U)
cn <- rep(0, model@n+1)
for (i in 1:model@n)
{
  V.i <- V.X[,i]
  cn[i] <- c.x[i] - t(V.i)%*%V.x - mu.x*t(V.i)%*%U + mu.x
}

cn[model@n+1] <- sk.x^2

######### Compute a and b #########
A <- c(mk.X, mk.x)
B <- cn / sqrt(tau2.new + sk.x^2)
sQ <- B[length(B)]
######### Careful: the AKG is written for MAXIMIZATION #########
######### Minus signs have been added where necessary ##########
A <- -A

######## Sort and reduce A and B ####################
nobs <- model@n
Isort <- order(x=B,y=A)
b <- B[Isort]
a <- A[Isort]

Iremove <- numeric()
for (i in 1:(nobs))
{
  if (b[i+1] == b[i])
  {  Iremove <- c(Iremove, i)}
}

if (length(Iremove) > 0)
{  b <- b[-Iremove]
   a <- a[-Iremove]}
nobs <- length(a)-1

C <- rep(0, nobs+2)
C[1] <- -1e36
C[length(C)] <- 1e36
A1 <- 0
      
for (k in 2:(nobs+1))
{
  nondom <- 1
  if (k == nobs+1)
  {  nondom <- 1
  } else if ( (a[k+1] >= a[k]) && (b[k] == b[k+1]) ) #((b[k] - b[k+1])^2 < 1e-18)
  {  nondom <- 0}
            
  if (nondom == 1)       
  {
    loopdone <- 0
    count <- 0
    while ( loopdone == 0 && count < 1e3 )
    {
      count <- count + 1
      u <- A1[length(A1)] + 1
      C[u+1] <- (a[u]-a[k]) / (b[k] - b[u])
      if ((length(A1) > 1) && (C[u+1] <= C[A1[length(A1)-1]+2]))
      { A1 <- A1[-length(A1)]
      } else
      { A1 <- c(A1, k-1)
        loopdone <- 1
      }
    }
  }
}
at <- a[A1+1]
bt <- b[A1+1]
ct <- C[c(1, A1+2)]

######### AGK ##########
maxNew <- 0       
for (k in 1:length(at))
{  maxNew <- maxNew + at[k]*(pnorm(ct[k+1])-pnorm(ct[k])) + bt[k]*(dnorm(ct[k]) - dnorm(ct[k+1]))}

AKG <- maxNew - (-m_min)

if (!is.null(envir)) {
assign("mk.x", mk.x, envir=envir)
assign("c.x", c.x, envir=envir)
assign("V.x", V.x, envir=envir)
assign("sk.x", sk.x, envir=envir)
assign("mk.X", mk.X, envir=envir)
assign("V.X", V.X, envir=envir)
assign("mu.x", mu.x, envir=envir)
assign("cn", cn, envir=envir)
assign("sQ", sQ, envir=envir)
assign("T", T, envir=envir)
assign("z", z, envir=envir)
assign("U", U, envir=envir)
assign("Isort", Isort, envir=envir)
assign("Iremove", Iremove, envir=envir)
assign("A1", A1, envir=envir)
assign("at", at, envir=envir)
assign("bt", bt, envir=envir)
assign("ct", ct, envir=envir)
}

return(AKG)
}
