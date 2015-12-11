rm(list = ls())
setwd('~/Documents/Sports Analytics/Player Synergy/')
library(ggplot2)
clusterData = read.csv('Clustering.csv')
clusterData$X = NULL
synergyData = read.csv('PlayerSynergy.csv')
synergyData$X = NULL
a = merge(synergyData, clusterData, by.x = c('Player1','Season'), by.y = c('Player', 'Season'), all.x = T)
