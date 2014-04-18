library("foreach")
library("doMC")
library("ggplot2")

registerDoMC()

normalize.range <- function(range) {
  (range - min(range))*(1/(max(range) - min(range)))
}

create.pairs <- function(x) {
  nOut <- length(x) - 1
  pairs <- matrix(nrow=nOut, ncol=2)
  for(i in 1:nOut) {
    pairs[i,] <- x[i:(i+1)]
  }
  pairs
}

cubic_interp_range <- function(v0, v1, v2, v3, x) {
  P <- -0.5*v0 + 1.5*v1 - 1.5*v2 + 0.5*v3
  Q <-      v0 - 2.5*v1 +   2*v2 - 0.5*v3
  R <- -0.5*v0          + 0.5*v2
  S <-               v1
  P*x^3 + Q*x^2 + R*x + S
}

cubic_interp <- function(x, z, border) {
  # interpolates values in z over x
  # x - domain values for interpolation
  # z - data values, NA when there is no point to interpolate
  # border - function values outside x, required to interpolate
  #          over all x
  # Method based on http://freespace.virgin.net/hugo.elias/models/m_perlin.htm

  if (length(x) != length(z)) {
    stop(paste("x and z must have the same length",
               paste0("[length(x)=",length(x)),
               paste0("length(z)=",length(z), "]"),
               sep=" ")
    )
  }
  
  v.idx <- which(!is.na(z))
  
  if (length(v.idx) < 1) {
    stop("z must have at least one non-NA value")
  }
  
  points <- create.pairs(v.idx)
  n <- nrow(points)  
  
  interpolated <- numeric()
  interp.mid <- numeric()
  
  range <- (x[points[1,1]:points[1,2]])
  xs <- normalize.range(range)
  v0 <- border[1]
  v1 <- z[points[1,1]]
  v2 <- z[points[1,2]]
  v3 <- ifelse(n > 1, z[points[2,2]], border[2])
  interpolated <- cubic_interp_range(v0, v1, v2, v3, xs)
  
  if (n > 2) {
    interp.mid <- foreach(i=2:n, .combine=function(total, curr) {
      c(total, curr[2:length(curr)])
    }, .inorder=TRUE) %do% {
      range <- (x[points[i,1]:points[i,2]])
      xs <- normalize.range(range)
      v0 <- z[points[i-1,1]]
      v1 <- z[points[i  ,1]]
      v2 <- z[points[i  ,2]]
      v3 <- ifelse(i < n, z[points[i+1,2]], border[2])
      cubic_interp_range(v0, v1, v2, v3, xs)
    }
    interpolated <- c(interpolated, interp.mid[2:length(interp.mid)])
  }
  
  interpolated
}

perlin_noise <- function(x,
                         persistence,
                         noctaves,
                         initial_octave=0,
                         rand_func=function(n) runif(n, -1, 1),
                         border_func=function(p0, p1) runif(2, -0.5, 0.5)
                         ){
  # x - domain for the noise
  # persistence - parameter that controls the contribution for higher octaves
  # noctaves - number of octaves that will compose the noise
  # initial_octave - allows skip the first octaves
  # rand_func - function to generate random values in the domain, the function
  #             receives the values in the domain that will base the random
  #             seed, it allows some control over the distribuition of the
  #             noise in the domain
  # border_func - function to generate the values before the first and after
  #               the last random points in the domain, it controls the
  #               steepness in the borders, the function must return only two
  #               values. The first and last random points are passed as
  #               parameters
  n <- noctaves - 1
  
  noise <- foreach(i=initial_octave:n, .combine=`+`) %do% {
    freq <- max(2^i, 2)
    ampl <- persistence^i
    z <- rep(NA, length(x))
    z.idx <- seq(1, length(x), length.out=freq)
    z[z.idx] <- rand_func(x[z.idx])
    border <- border_func(z[1], z[length(z)])
    cubic_interp(x, z, border)*ampl
  }
  
  noise
}

# Sample, source the file and it will show a picture
n <- 1000
len <- 100
x <- seq(0, len, length.out=n)
noise <- perlin_noise(x, 0.6, 5,
                      initial_octave=3,
                      rand_func=function(x) {
                        # high values in the left, a flat region in middle
                        # and lower flat region in the right
                        n.low <- length(x[x < 20])
                        n.mid <- length(x[x > 20 & x < 70])
                        n.high <- length(x) - n.low - n.mid
                        c(runif(n.low, 1.5, 3.5),
                          runif(n.mid, 1.3, 1.6),
                          runif(n.high, 0, 0.4))
                      },
                      border_func=function(p0, p1) c(p0/2, p1/2)
                      )
data <- data.frame(x, noise)
q <- ggplot(data, aes(x=x, y=noise)) +
  geom_line() +
  scale_y_continuous(limits=c(-0.1, 2))
show(q)