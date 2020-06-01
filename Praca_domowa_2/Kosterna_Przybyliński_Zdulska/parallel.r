fortunes::fortune(10)

?Map

library(parallelMap)
library(microbenchmark)

# adapted from: https://mllg.github.io/batchtools/articles/batchtools.html#example-1-approximation-of-pi

approximate_pi <- function(n) {
  nums <- matrix(runif(2 * n), ncol = 2)
  d <- sqrt(nums[, 1]^2 + nums[, 2]^2)
  4 * mean(d <= 1)
}
RNGkind("L'Ecuyer-CMRG")
set.seed(1410)

approximate_pi(5)

lapply(rep(1e5, 100), approximate_pi)

# under the hood parallel::mclapply
# również parallelStartMPI
parallelStartMulticore(4, show.info = TRUE)
# parallelStart()
parallelLapply(rep(1e5, 10), approximate_pi)
parallelLapply(rep(1e5, 3), function(x){parallelLapply(rep(1e5, 10), approximate_pi)})

parallelStop()

parallelStartMulticore(4, show.info = FALSE)
microbenchmark(lapply = lapply(rep(1e5, 100), approximate_pi), 
               parallelLapply = parallelLapply(rep(1e5, 100), approximate_pi), 
               times = 1)
parallelStop()
parallelStart()
microbenchmark(lapply = lapply(1L:3, function(x){lapply(rep(1e5, 100), approximate_pi)}), 
               parallelLapply = parallelLapply(rep(1e5, 3), function(x){parallelLapply(rep(1e5, 100), approximate_pi)}), 
               times = 1)


# batchtools ----------------------
library(batchtools)

# ułatwienie: btlapply

registry <- makeRegistry(file.dir = "./registry", seed = 15390)
getDefaultRegistry()
# setDefaultRegistry()
# clearRegistry()
batchMap(fun = approximate_pi, n = rep(1e5, 10))
getJobTable()
submitJobs(resources = list(walltime = 3600, memory = 1024))
getStatus()

microbenchmark(lapply = lapply(rep(1e5, 100), approximate_pi), 
               batchtools = function(){
                 clearRegistry()
                 batchMap(fun = approximate_pi, n = rep(1e5, 100))
                 submitJobs(resources = list(walltime = 3600, memory = 1024))
                 waitForJobs()
                 cat('dupa')
               }, 
               times = 1, unit = 's')


# readRDS("./file_registry/user.function.rds")

aaa <- function(dataset, na.omit, ...){
  return(fun(x, ...))
}

loadResult(1)
readRDS("./file_registry/results/1.rds")
makeClusterFunctionsMulticore(ncpus = 4)
clearRegistry()
batchMap(fun = approximate_pi, n = rep(1e5, 500))
getJobTable()
submitJobs(resources = list(walltime = 3600, memory = 1024))
waitForJobs()

make_some_parallels <- function(x){
  clearRegistry()
  cat(x)
  batchMap(fun = approximate_pi, n = rep(1e5, 5))
  submitJobs(resources = list(walltime = 3600, memory = 1024))
  waitForJobs()
  ret <- lapply(1L:10, loadResult)
  return(ret)
}

clearRegistry()
batchMap(fun = make_some_parallels,x=1L:3)
submitJobs(resources = list(walltime = 3600, memory = 1024))
getJobTable()
waitForJobs()


# makeClusterFunctionsSSH
#?parallelStartBatchtools
library(future.batchtools)
plan("batchtools_interactive")
batchMap(fun = approximate_pi, n = rep(1e5, 10))
clearRegistry()