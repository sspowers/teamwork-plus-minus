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
def.cluster$Cluster1 = pmin(def.cluster$Player1.Cluster,def.cluster$Player2.Cluster)
def.cluster$Cluster2 = pmax(def.cluster$Player1.Cluster,def.cluster$Player2.Cluster)

off.cluster$Player2.Cluster = off.cluster$Cluster
off.cluster$Cluster = NULL
off.cluster$X = NULL
off.cluster$Cluster1 = pmin(off.cluster$Player1.Cluster, off.cluster$Player2.Cluster)
off.cluster$Cluster2 = pmax(off.cluster$Player1.Cluster, off.cluster$Player2.Cluster)

def.mean = aggregate(def.cluster$Value, list(def.cluster$Cluster1, 
                                             def.cluster$Cluster2),mean)
off.mean = aggregate(off.cluster$Value, list(off.cluster$Cluster1, 
                                             off.cluster$Cluster2),mean)

jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", 
                                 "yellow", "#FF7F00", "red", "#7F0000"))

p = ggplot(def.mean) + geom_tile(aes(x = Group.1, y = Group.2, fill = x)) 
p + scale_fill_gradientn(colours = jet.colors(7))
ggsave('DefMean.pdf')
p = ggplot(off.mean) + geom_tile(aes(x = Group.1, y = Group.2, fill = x)) 
p + scale_fill_gradientn(colours = jet.colors(7))
ggsave('OffMean.pdf')

def.sd = aggregate(def.cluster$Value, list(def.cluster$Cluster1, 
                                           def.cluster$Cluster2),sd)
off.sd = aggregate(off.cluster$Value, list(off.cluster$Cluster1, 
                                           off.cluster$Cluster2),sd)

p = ggplot(def.sd) + geom_tile(aes(x = Group.1, y = Group.2, fill = x)) 
p + scale_fill_gradientn(colours = jet.colors(7))
ggsave('DefSd.pdf')
p = ggplot(off.sd) + geom_tile(aes(x = Group.1, y = Group.2, fill = x)) 
p + scale_fill_gradientn(colours = jet.colors(7))
ggsave('OffSd.pdf')

ds = data.frame('Cluster' = paste(def.cluster$Cluster1, '-', def.cluster$Cluster2, sep = ''),
                'Synergy' = def.cluster$Value)
os = data.frame('Cluster' = paste(off.cluster$Cluster1, '-', off.cluster$Cluster2, sep = ''),
                'Synergy' = off.cluster$Value)

dsm = aggregate(ds$Synergy, list(ds$Cluster), mean)
dss = aggregate(ds$Synergy, list(ds$Cluster), sd)
def = data.frame('Clusters' = dsm$Group.1, lo = dsm$x - dss$x, mean = dsm$x, hi = dsm$x + dss$x)
def = def[complete.cases(def), ]

def$Cluster = reorder(def$Cluster, def$mean)
def = def[order(def$mean), ]
dred = def[c(1:5, (nrow(def)-4):nrow(def)), ]
def = melt(def)
ggplot(def, aes(x = Cluster, y = value)) + geom_point(aes(colour = variable)) +
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0, size = 8))
ggsave('AllDef.pdf', width = 15, height = 5)
dred = melt(dred)
ggplot(dred, aes(x = Cluster, y = value)) + geom_point(aes(colour = variable))
ggsave('FewDef.pdf')

osm = aggregate(os$Synergy, list(os$Cluster), mean)
oss = aggregate(os$Synergy, list(os$Cluster), sd)
off = data.frame('Clusters' = osm$Group.1, lo = osm$x - oss$x, mean = osm$x, hi = osm$x + oss$x)
off = off[complete.cases(off), ]

off$Cluster = reorder(off$Cluster, off$mean)
off = off[order(off$mean), ]
ored = off[c(1:5, (nrow(off)-4):nrow(off)), ]
off = melt(off)
ggplot(off, aes(x = Cluster, y = value)) + geom_point(aes(colour = variable)) +
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0, size = 8))
ggsave('AllOff.pdf', width = 15, height = 5)
ored = melt(ored)
ggplot(ored, aes(x = Cluster, y = value)) + geom_point(aes(colour = variable))
ggsave('FewOff.pdf')