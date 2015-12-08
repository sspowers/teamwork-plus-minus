rm(list = ls())
setwd('~/Documents/Sports Analytics/Player Synergy/')
source('ClusteringTestFcns.R')

seasons = c('2004-05', '2005-06', '2006-07', '2007-08', '2008-09', '2009-10',
            '2010-11', '2011-12', '2012-13', '2013-14', '2014-15')
seasonflag = 1

if (seasonflag == 0) {
  k = 33
} else {
  k = 18
}

clustResults = data.frame('Player' = character(), 'Season' = character(), 'Cluster' = numeric())
if (seasonflag == 0) {
  for (season in seasons) {
    filename = paste('PlayerEvents', season, '.csv', sep = '')
    minname = paste('PlayerMinutes', season, '.csv', sep = '')
    playerStats = read.csv(filename)
    playerMinutes = read.csv(minname)
    playerStats = merge(playerStats, playerMinutes)
    rownames(playerStats) = playerStats$Player
    playerStats$Player = NULL
    playerStats = playerStats/playerStats$Minutes
    playerStats$Minutes = NULL
    playerStats = playerStats[ , colMeans(playerStats) >= 1/480]
    pc = princomp(playerStats, scores = T)
    vp = cumsum(pc$sdev^2/sum(pc$sdev^2))
    npc = which(vp >= .9)
    npc = npc[1]
    km = kmeans(pc$scores[ , 1:npc], k)
    seasonResults = data.frame('Player' = names(km$cluster), 'Season' = rep(season, nrow(playerStats)), 
                               'Cluster' = km$cluster)
    rownames(seasonResults) = NULL
    clustResults = rbind(clustResults, seasonResults)
  }
} else {
  for (season in seasons) {
    filename = paste('PlayerEvents', season, '.csv', sep = '')
    minname = paste('PlayerMinutes', season, '.csv', sep = '')
    playerStats = read.csv(filename)
    playerMinutes = read.csv(minname)
    playerStats = merge(playerStats, playerMinutes)
    playerStats$Player = paste(playerStats$Player, season, sep = ',')
    playerStats[ , 2:ncol(playerStats)] = playerStats[ , 2:ncol(playerStats)]/
      playerStats[ , 2:ncol(playerStats)]$Minutes
    playerStats$Minutes = NULL
    if (season == '2004-05') {
      allStats = playerStats
    } else {
      allStats = merge(allStats, playerStats, all = T)
    }
  }
  rownames(allStats) = allStats$Player
  allStats$Player = NULL
  playerStats = allStats[ , !is.na(colSums(allStats))]
  playerStats = playerStats[ , colMeans(playerStats) >= 1/480]
  pc = princomp(playerStats, scores = T)
  vp = cumsum(pc$sdev^2/sum(pc$sdev^2))
  npc = which(vp >= .9)
  npc = npc[1]
  km = kmeans(pc$scores[ , 1:npc], k)
  nl = strsplit(names(km$cluster), ',')
  playernames = character(length(nl))
  playerseasons = character(length(nl))
  for (idx in 1:length(nl)) {
    playernames[idx] = nl[[idx]][1]
    playerseasons[idx] = nl[[idx]][2]
  }
  clustResults = data.frame('Player' = playernames, 'Season' = playerseasons, 
                            'Cluster' = km$cluster)
  rownames(clustResults) = NULL
}
for (season in seasons) {
  seasonResults = clustResults[clustResults$Season == season, ]
  fname = paste('PlayerClusters', season, '-', seasonflag, '.csv', sep = '')
  write.csv(seasonResults, file = fname)
}


c = 18
cl = clustResults[clustResults$Cluster == c, ]
a = table(cl$Player)
b = a[a >= 1]
b[order(b)]
