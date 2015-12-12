rm(list = ls())
library(ggplot2)
library(dplyr)
library(reshape2)
player.clusters = read.csv('PlayerClustering.csv')
player.synergy = read.csv('PlayerSynergy.csv')
def.synergy = player.synergy[player.synergy$Type == 'Def', ]
off.synergy = player.synergy[player.synergy$Type == 'Off', ]
def1.cluster = merge(def.synergy, player.clusters, by.x = c('Player1','Season'), 
                     by.y = c('Player','Season'))
off1.cluster = merge(off.synergy, player.clusters, by.x = c('Player1','Season'), 
                     by.y = c('Player','Season'))
def1.cluster$X.x = NULL
def1.cluster$X.y = NULL
def1.cluster$Player1.Cluster = def1.cluster$Cluster
def1.cluster$Cluster = NULL

off1.cluster$X.x = NULL
off1.cluster$X.y = NULL
off1.cluster$Player1.Cluster = off1.cluster$Cluster
off1.cluster$Cluster = NULL

def.cluster = merge(def1.cluster, player.clusters, by.x = c('Player2','Season'), 
                    by.y = c('Player','Season'))
off.cluster = merge(off1.cluster, player.clusters, by.x = c('Player2','Season'), 
                    by.y = c('Player','Season'))

def.cluster$Player2.Cluster = def.cluster$Cluster
def.cluster$Cluster = NULL
def.cluster$X = NULL

off.cluster$Player2.Cluster = off.cluster$Cluster
off.cluster$Cluster = NULL
off.cluster$X = NULL

def1 = data.frame('Cluster' = as.factor(def.cluster$Player1.Cluster), 'Synergy' = def.cluster$Value)
def2 = data.frame('Cluster' = as.factor(def.cluster$Player2.Cluster), 'Synergy' = def.cluster$Value)
def = rbind(def1,def2)
ggplot(def, aes(x = Synergy)) + geom_density(aes(fill = Cluster)) + 
  scale_x_continuous(limits=c(-0.0000015, 0.0000015))
