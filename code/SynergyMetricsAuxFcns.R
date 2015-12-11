getDfRow = function(l) {
  if (length(l) == 2) {
    return(c(l[[1]], NA, l[[2]]))
  } else {
    return(c(l[[1]], l[[2]], l[[3]]))
  }
}