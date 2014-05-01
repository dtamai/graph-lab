library("foreach")
library("doMC")
library("ggplot2")
library("reshape2")
library("plyr")
library("dplyr")

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

pad.repeating <- function(mat) {
  nr <- nrow(mat)
  nc <- ncol(mat)
  new.mat <- matrix(nrow=nr + 2,
                    ncol=nc + 2)
  
  # corners
  new.mat[c(1,nr+2), c(1,nc+2)] <- mat[c(1,nr), c(1,nc)]
  
  # center
  new.mat[2:(nr+1), 2:(nc+1)] <- mat
  
  # edges
  new.mat[c(1,nr+2), 2:(nc+1)] <- mat[c(1,nr),]
  new.mat[2:(nr+1), c(1,nc+2)] <- mat[,c(1,nc)]
  
  new.mat
}

extract_4x4 <- function(mat) {
  horz <- ncol(mat) - 3
  vert <- nrow(mat) - 3
  total <- horz*vert
  
  r <- lapply(1:horz, function(i, mat) {
      lapply(1:vert, function(j, mat) {
        mat[j:(j+3),i:(i+3)]
      }, mat=mat)
    }, mat=mat)
  
  lr <- sum(sapply(r, length, simplify=TRUE))
  if(lr != total) {
    stop(paste0("BUG: Expected to extract ", total, " matrices, but extracted ", lr))
  }
  
  r
}

cubic_interp_range <- function(v0, v1, v2, v3, x) {
  P <- -0.5*v0 + 1.5*v1 - 1.5*v2 + 0.5*v3
  Q <-      v0 - 2.5*v1 +   2*v2 - 0.5*v3
  R <- -0.5*v0          + 0.5*v2
  S <-               v1
  P*x^3 + Q*x^2 + R*x + S
}

cubic_interp_area <- function(p, x, y) {
  # algo from http://www.paulinternet.nl/?page=bicubic
  
  a00 = p[2,2];
  a01 = -.5*p[2,1] + .5*p[2,3];
  a02 = p[2,1] - 2.5*p[2,2] + 2*p[2,3] - .5*p[2,4];
  a03 = -.5*p[2,1] + 1.5*p[2,2] - 1.5*p[2,3] + .5*p[2,4];
  a10 = -.5*p[1,2] + .5*p[3,2];
  a11 = .25*p[1,1] - .25*p[1,3] - .25*p[3,1] + .25*p[3,3];
  a12 = -.5*p[1,1] + 1.25*p[1,2] - p[1,3] + .25*p[1,4] + .5*p[3,1] - 1.25*p[3,2] + p[3,3] - .25*p[3,4];
  a13 = .25*p[1,1] - .75*p[1,2] + .75*p[1,3] - .25*p[1,4] - .25*p[3,1] + .75*p[3,2] - .75*p[3,3] + .25*p[3,4];
  a20 = p[1,2] - 2.5*p[2,2] + 2*p[3,2] - .5*p[4,2];
  a21 = -.5*p[1,1] + .5*p[1,3] + 1.25*p[2,1] - 1.25*p[2,3] - p[3,1] + p[3,3] + .25*p[4,1] - .25*p[4,3];
  a22 = p[1,1] - 2.5*p[1,2] + 2*p[1,3] - .5*p[1,4] - 2.5*p[2,1] + 6.25*p[2,2] - 5*p[2,3] + 1.25*p[2,4] + 2*p[3,1] - 5*p[3,2] + 4*p[3,3] - p[3,4] - .5*p[4,1] + 1.25*p[4,2] - p[4,3] + .25*p[4,4];
  a23 = -.5*p[1,1] + 1.5*p[1,2] - 1.5*p[1,3] + .5*p[1,4] + 1.25*p[2,1] - 3.75*p[2,2] + 3.75*p[2,3] - 1.25*p[2,4] - p[3,1] + 3*p[3,2] - 3*p[3,3] + p[3,4] + .25*p[4,1] - .75*p[4,2] + .75*p[4,3] - .25*p[4,4];
  a30 = -.5*p[1,2] + 1.5*p[2,2] - 1.5*p[3,2] + .5*p[4,2];
  a31 = .25*p[1,1] - .25*p[1,3] - .75*p[2,1] + .75*p[2,3] + .75*p[3,1] - .75*p[3,3] - .25*p[4,1] + .25*p[4,3];
  a32 = -.5*p[1,1] + 1.25*p[1,2] - p[1,3] + .25*p[1,4] + 1.5*p[2,1] - 3.75*p[2,2] + 3*p[2,3] - .75*p[2,4] - 1.5*p[3,1] + 3.75*p[3,2] - 3*p[3,3] + .75*p[3,4] + .5*p[4,1] - 1.25*p[4,2] + p[4,3] - .25*p[4,4];
  a33 = .25*p[1,1] - .75*p[1,2] + .75*p[1,3] - .25*p[1,4] - .75*p[2,1] + 2.25*p[2,2] - 2.25*p[2,3] + .75*p[2,4] + .75*p[3,1] - 2.25*p[3,2] + 2.25*p[3,3] - .75*p[3,4] - .25*p[4,1] + .75*p[4,2] - .75*p[4,3] + .25*p[4,4];

  xn <- normalize.range(x)
  yn <- normalize.range(y)

  xyn <- expand.grid(xn, yn)
  colnames(xyn) <- c("x", "y")
  xn <- xyn$x
  yn <- xyn$y
  xn2 <- xn * xn;
  xn3 <- xn2 * xn;
  yn2 <- yn * yn;
  yn3 <- yn2 * yn;
  
  z <- (a00 + a01*xn + a02*xn2 + a03*xn3) +
       (a10 + a11*xn + a12*xn2 + a13*xn3) * yn +
       (a20 + a21*xn + a22*xn2 + a23*xn3) * yn2 +
       (a30 + a31*xn + a32*xn2 + a33*xn3) * yn3
  
  xy <- expand.grid(x, y)
  colnames(xy) <- c("x", "y")
  return(cbind(xy, z))
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
  
  if (length(v.idx) < 2) {
    stop("z must have at least two non-NA values")
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

interp2 <- function(x=seq(0,1, lenght.out=10),
                    y=seq(0,1, lenght.out=10),
                    z) {
  # z - retangular matrix of seed values
  # x - the x values of the grid
  # y - the y values of the grid
  
  nz <- list(x=ncol(z), y=nrow(z))
  
  if(any(dim(z) <= 1)) {
    stop(paste0("z must be at least 2x2 [dim(z)=", paste(dim(z), collapse='x'), "]"))
  }
  
  split.range <- list(
    x=split(x, factor(sort(rank(x)%%(nz$x - 1)))),
    y=split(y, factor(sort(rank(y)%%(nz$y - 1))))
  )
  
  vs <- extract_4x4(pad.repeating(z))
  imax <- length(vs)
  jmax <- length(vs[[1]])
  
  s <- foreach(i=1:imax, .combine=rbind) %do% {
    foreach(j=1:jmax, .combine=rbind) %do% {
      cubic_interp_area(vs[[i]][[j]], split.range$x[[i]], split.range$y[[j]])
    }
  }

  arrange(s, x, y)
}

z <- matrix(c(0.8, 0.4, 0.8, 0.5,
              0.2, 0.2, 0.8, 0.2,
              0.1, 0.4, 0.4, 0.5,
              0.6, 0.7, 1.5, 0.3), 4, byrow=TRUE)

#cub <- interp2(seq(1, 50, length.out=100), seq(1, 50, length.out=100), z)
#q <- ggplot(cub, aes(x, y, fill=z)) + geom_raster() + scale_y_reverse()
#print(q)

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

perlin_noise2 <- function(
  x,
  y,
  persistence,
  noctaves,
  initial_octave=1
) {
  
  n <- noctaves - 1
  noise <- foreach(i=initial_octave:n, .combine=function(tot, part) {
    tot$z <- tot$z + part$z
    tot
  }) %do% {
    freq <- max(2^i, 2)
    ampl <- persistence^i
    z <- matrix(runif((freq)^2), freq)
    
    r <- interp2(x, y, z)
    r$z <- r$z*ampl
    r
  }
  
  noise
}

noise2 <- perlin_noise2(
  seq(1, 50, length.out=200),
  seq(1, 50, length.out=200),
  0.2,
  5,
  2
)

q <- ggplot(noise2, aes(x, y, fill=z)) + geom_raster() + scale_y_reverse() +
  scale_fill_gradientn(colours=c("black", "blue", "cyan", "green", "yellow", "red", "white"))
print(q)


# Sample, source the file and it will show a picture
# n <- 1000
# len <- 100
# x <- seq(0, len, length.out=n)
# noise <- perlin_noise(x, 0.6, 5,
#                       initial_octave=3,
#                       rand_func=function(x) {
#                         # high values in the left, a flat region in middle
#                         # and lower flat region in the right
#                         n.low <- length(x[x < 20])
#                         n.mid <- length(x[x > 20 & x < 70])
#                         n.high <- length(x) - n.low - n.mid
#                         c(runif(n.low, 1.5, 3.5),
#                           runif(n.mid, 1.3, 1.6),
#                           runif(n.high, 0, 0.4))
#                       },
#                       border_func=function(p0, p1) c(p0/2, p1/2)
#                       )
# data <- data.frame(x, noise)
# q <- ggplot(data, aes(x=x, y=noise)) +
#   geom_line() +
#   scale_y_continuous(limits=c(-0.1, 2))
# show(q)