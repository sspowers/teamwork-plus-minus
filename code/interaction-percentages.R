rm(list = ls())
library(ggplot2)
library(dplyr)
library(reshape2)
player.clusters = read.csv('Clustering.csv')
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

def.cluster$Cluster1 = pmin(def.cluster$Player1.Cluster, def.cluster$Player2.Cluster)
def.cluster$Cluster2 = pmax(def.cluster$Player1.Cluster, def.cluster$Player2.Cluster)
defpospc = aggregate(def.cluster$Value, list(def.cluster$Cluster1, def.cluster$Cluster2),
                  function(s){return(length(s[s>0])/length(s))})
defnegpc = aggregate(def.cluster$Value, list(def.cluster$Cluster1, def.cluster$Cluster2),
                    function(s){return(length(s[s<0])/length(s))})
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", 
                                 "yellow", "#FF7F00", "red", "#7F0000"))

p = ggplot(defpospc) + geom_tile(aes(x = Group.1, y = Group.2, fill = x)) 
p + scale_fill_gradientn(colours = jet.colors(7))
ggsave('DefPosPct.pdf')
p = ggplot(defnegpc) + geom_tile(aes(x = Group.1, y = Group.2, fill = x)) 
p + scale_fill_gradientn(colours = jet.colors(7))
ggsave('DefNegPct.pdf')


off.cluster$Cluster1 = pmin(off.cluster$Player1.Cluster, off.cluster$Player2.Cluster)
off.cluster$Cluster2 = pmax(off.cluster$Player1.Cluster, off.cluster$Player2.Cluster)
offpospc = aggregate(off.cluster$Value, list(off.cluster$Cluster1, off.cluster$Cluster2),
                  function(s){return(length(s[s>0])/length(s))})
offnegpc = aggregate(off.cluster$Value, list(off.cluster$Cluster1, off.cluster$Cluster2),
                     function(s){return(length(s[s<0])/length(s))})
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", 
                                 "yellow", "#FF7F00", "red", "#7F0000"))

p = ggplot(offpospc) + geom_tile(aes(x = Group.1, y = Group.2, fill = x)) 
p + scale_fill_gradientn(colours = jet.colors(7))
ggsave('OffPosPct.pdf')

p = ggplot(offnegpc) + geom_tile(aes(x = Group.1, y = Group.2, fill = x)) 
p + scale_fill_gradientn(colours = jet.colors(7))
ggsave('OffNegPct.pdf')

