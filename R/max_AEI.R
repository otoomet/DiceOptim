#source("max_AEI.R")
max_AEI <-function(model, new.noise.var=0, y.min=NULL, type = "UK", lower, upper,
                   parinit=NULL, control=NULL, cluster=FALSE) {

  # Compute y.min if missing
  if (is.null(y.min))
  { pred <- predict(object=model, newdata=model@X, type=type, checkNames = FALSE)
    y.min <- pred$mean[which.min(pred$mean + qnorm(0.75)*pred$sd)] }
  
  AEI.envir <- new.env()
	environment(AEI) <- environment(AEI.grad) <- AEI.envir 
	gr = AEI.grad

	d <- ncol(model@X)
	if (is.null(control$print.level)) control$print.level <- 1
	if(d<=6) N <- 3*2^d else N <- 32*d 
  if (is.null(control$pop.size))  control$pop.size <- N
  if (is.null(control$BFGSmaxit)) control$BFGSmaxit <- N
	if (is.null(control$solution.tolerance))  control$solution.tolerance <- 1e-21
  if (is.null(control$max.generations))  control$max.generations <- 12
  if (is.null(control$wait.generations))  control$wait.generations <- 2
  if (is.null(control$BFGSburnin)) control$BFGSburnin <- 2
	if (is.null(parinit))  parinit <- lower + runif(d) * (upper - lower)

	domaine <- cbind(lower, upper)

	o <- genoud(AEI, nvars=d, max=TRUE, 
	            pop.size=control$pop.size, max.generations=control$max.generations, wait.generations=control$wait.generations,
	            hard.generation.limit=TRUE, starting.values=parinit, MemoryMatrix=TRUE, 
	            Domains=domaine, default.domains=10, solution.tolerance=control$solution.tolerance,
	            gr=gr, boundary.enforcement=2, lexical=FALSE, gradient.check=FALSE, BFGS=TRUE,
	            data.type.int=FALSE, hessian=FALSE, unif.seed=floor(runif(1,max=10000)), int.seed=floor(runif(1,max=10000)), 
	            print.level=control$print.level, 
	            share.type=0, instance.number=0, output.path="stdout", output.append=FALSE, project.path=NULL,
	            P1=50, P2=50, P3=50, P4=50, P5=50, P6=50, P7=50, P8=50, P9=0, P9mix=NULL, 
	            BFGSburnin=control$BFGSburnin, BFGSfn=NULL, BFGShelp=NULL, control=list("maxit"=control$BFGSmaxit), 
	            cluster=cluster, balance=FALSE, debug=FALSE, 
              model=model, new.noise.var=new.noise.var, y.min=y.min, type=type, envir=AEI.envir 
		)
                            
    o$par <- t(as.matrix(o$par))
	colnames(o$par) <- colnames(model@X)
	o$value <- as.matrix(o$value)
	colnames(o$value) <- "AEI"   
	return(list(par=o$par, value=o$value)) 
}
