require(glmnet)
require(Matrix)
setwd('~/Documents/Sports Analytics/Player Synergy/')
data = read.csv('PossessionData.csv')
n = nrow(data)

offenseAway = data[data$Possession == 'Away', 1:5]
defenseHome = data[data$Possession == 'Away', 6:10]
offenseHome = data[data$Possession == 'Home', 6:10]
defenseAway = data[data$Possession == 'Home', 1:5]
points = c(data$Points[data$Possession == 'Away'],
    data$Points[data$Possession == 'Home'])

offense = rbind(as.matrix(offenseAway), as.matrix(offenseHome))
defense = rbind(as.matrix(defenseHome), as.matrix(defenseAway))

o = as.numeric(as.factor(c(offense)))
d = as.numeric(as.factor(c(defense))) + max(o)
x = sparseMatrix(rep(1:n, 10), c(o, d))
y = points

pos = colSums(as.matrix(x))
posO = pos[sort(unique(o))]
posD = pos[sort(unique(d))]
pts = colSums(as.matrix(x)*y)
ptsO = pts[sort(unique(o))]
ptsD = pts[sort(unique(d))]
pm = ptsO - ptsD
names(posO) = names(ptsO) = sort(unique(c(offense)))
names(posD) = names(ptsD) = sort(unique(c(defense)))
names(pm) = names(posO)
initials = sapply(strsplit(names(pm), split = ' '), function(name) {
    args = as.list(substr(name, 1, 1))
    args$sep = ''
    do.call(paste, args)})

fit = cv.glmnet(x, y, alpha = 0, standardize = FALSE)

coef = predict(fit, rbind(0, diag(ncol(x))), s = 'lambda.min')
names(coef) = c('intercept', paste(sort(unique(c(offense))), 'Off'), paste(sort(unique(c(offense))), 'Def'))
alpha = coef[1]
beta = coef[1 + sort(unique(o))] - alpha
delta = coef[1 + sort(unique(d))] - alpha
names(beta) = names(posO)
names(delta) = names(posD)

# offense.pdf
plot(100*ptsO/posO, 100*(alpha + beta),
    xlab = 'Offensive points per 100 possessions',
    ylab = 'Predicted pts/100pos in average environment', type = 'n')
text(100*ptsO/posO, 100*(alpha + beta), label = initials, cex = 0.5)
abline(h = 100*alpha, lty = 1)
abline(0, 1, lty = 2)
legend('topleft', lty = c(1, 2), c('Average', 'Diagonal'))

# defense.pdf
plot(100*ptsD/posD, 100*(alpha + delta),
    xlab = 'Defensive points per 100 possessions',
    ylab = 'Predicted pts/100pos in average environment', type = 'n')
text(100*ptsO/posO, 100*(alpha + delta), label = initials, cex = 0.5)
abline(h = 100*alpha, lty = 1)
abline(0, 1, lty = 2)
legend('topleft', lty = c(1, 2), c('Average', 'Diagonal'))

# overall.pdf
plot(200*pm/(posO+posD), 100*(beta - delta),
    xlab = '+/- per 200 possessions',
    ylab = 'Predicted +/- per 200 poss in average environment', type = 'n')
text(200*pm/(posO+posD), 100*(beta - delta), label = initials, cex = 0.5)
abline(h = 0, lty = 1)
abline(0, 1, lty = 2)
legend('topright', lty = c(1, 2), c('Average', 'Diagonal'))

# Regression with python-supplied design matrix and no interaction
colnamesNI = read.csv('ColNamesNoInteract.csv', header = FALSE)
ij = read.csv('DesignMatrixNoInteract.csv', header = FALSE)
x.interactive = sparseMatrix(ij[, 1], ij[, 2])
fit.interactive = cv.glmnet(x.interactive, data$Points, alpha = 0, standardize = FALSE)
coefNI = predict(fit.interactive, rbind(0,diag(ncol(x.interactive))), s = 'lambda.min')
names(coefNI) = c('intercept', as.character(colnamesNI$V1[order(colnamesNI$V2)]))
# rownames(coef.interactive) = c('intercept', colnames[order(colnames[, 2]), 1])

# Regression with python-supplied design matrix and interaction
colnames = read.csv('ColNames.csv', header = FALSE)
ij = read.csv('DesignMatrix.csv', header = FALSE)
x.interactive = sparseMatrix(ij[, 1], ij[, 2])
fit.interactive = cv.glmnet(x.interactive, data$Points, alpha = 1, standardize = FALSE)
coef.interactive = predict(fit.interactive, rbind(0,diag(ncol(x.interactive))), s = 'lambda.min')
names(coef.interactive) = c('intercept', as.character(colnames$V1[order(colnames$V2)]))
# rownames(coef.interactive) = c('intercept', colnames[order(colnames[, 2]), 1])
sort(coef.interactive)