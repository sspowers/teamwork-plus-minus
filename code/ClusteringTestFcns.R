getDegenerateClusters = function(clustResults) {
  totalClusters = 0
  degenClusters = 0
  seasons = levels(clustResults$Season)
  for (season in seasons) {
    seasonClusters = clustResults[clustResults$Season == season, ]
    totalClusters =  totalClusters + max(seasonClusters$Cluster)
    clCount = table(seasonClusters$Cluster)
    degenClusters = degenClusters + sum(clCount <= 2)
  }
  return(degenClusters / totalClusters)
}

getSplitPctg = function(clustResults) {
  totalPairs = 0
  splitPairs = 0
  seasons = levels(clustResults$Season)
  seasons = sort(seasons)
  for (season in seasons) {
    if (season == '2004-05') {
      prevClusters = clustResults[clustResults$Season == season, ]
    } else {
      seasonClusters = clustResults[clustResults$Season == season, ]
      ovrPlayers = intersect(prevClusters$Player, seasonClusters$Player)
      seasonClusters = seasonClusters[seasonClusters$Player %in% ovrPlayers, ]
      prevClusters = prevClusters[prevClusters$Player %in% ovrPlayers, ]
      totalPairs = totalPairs + choose(nrow(seasonClusters), 2)
      totalClusters = max(seasonClusters$Cluster)
      for (player in seasonClusters$Player) {
        currCl = seasonClusters$Cluster[seasonClusters$Player == player]
        clPlayers = seasonClusters$Player[seasonClusters$Cluster == currCl]
        prevCl = prevClusters$Cluster[prevClusters$Player == player]
        for (pair in clPlayers) {
          if (player == pair) {next}
          pairCl = prevClusters$Cluster[prevClusters$Player == pair]
          if (pairCl != prevCl) {splitPairs = splitPairs + 1}
        }
      }
      prevClusters = clustResults[clustResults$Season == season, ]
    }
  }
  return(splitPairs/totalPairs)
}

getClusterOverlap = function(clustResults) {
  seasons = levels(clustResults$Season)
  seasons = sort(seasons)
  overlap = rep(NA, length(seasons))
  idx = 1
  for (season in seasons) {
    if (season == '2004-05') {
      prevClust = clustResults[clustResults$Season == season, ]
    } else {
      currClust = clustResults[clustResults$Season == season, ]
      ovrPlayers = intersect(prevClust$Player, currClust$Player)
      currClust = currClust[currClust$Player %in% ovrPlayers, ]
      prevClust = prevClust[prevClust$Player %in% ovrPlayers, ]
      ncl = max(currClust$Cluster)
      npcl = max(prevClust$Cluster)
      clovr = rep(NA,ncl)
      for (i in 1:ncl) {
        clust = as.character(currClust$Player[currClust$Cluster == i])
        if (length(clust) <= 2) {next}
        ovr = 0
        for (k in 1:npcl) {
          prclust = as.character(prevClust$Player[prevClust$Cluster == k])
          if (length(prclust) <= 2) {next}
          novr = length(intersect(clust, prclust))
          novr = novr/length(clust)
          if (novr > ovr) {ovr = novr}
        }
        clovr[i] = ovr
      }
      overlap[idx] = mean(clovr, na.rm = T)
      idx = idx + 1
      prevClust = clustResults[clustResults$Season == season, ]
    }
  }
  return(mean(overlap, na.rm = T))
}