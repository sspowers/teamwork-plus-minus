rm(list = ls())
setwd('~/Documents/Sports Analytics/Player Synergy/')
source('SynergyMetricsAuxFcns.R')
require(ggplot2)
require(dplyr)
seasons = c('2004-05', '2005-06', '2006-07', '2007-08', '2008-09', '2009-10',
            '2010-11', '2011-12', '2012-13', '2013-14', '2014-15')

cwoint = data.frame('Player' = character(), 'Type' = character(), 'Season' = character(),
                    'Value' = numeric())
cwint = data.frame('Player1' = character(), 'Player2' = character(), 'Type' = character(), 
                   'Season' = character(), 'Value' = numeric())

for (season in seasons) {
  s = strsplit(season, '-')
  sstr = paste(s[[1]][1], '-20', s[[1]][2], sep = '')
  wname = paste('interactions/', sstr, '.csv', sep = '')
  seasonResults = read.csv(wname, header = F)
  plstr = strsplit(as.character(seasonResults$V1), ' - ')
  pldf = t(sapply(plstr, getDfRow))
  sdf = data.frame('Player1' = pldf[ , 1], 'Player2' = pldf[ , 2], 
                   'Type' = pldf[ , 3], 'Season' = rep(season, nrow(seasonResults)), 
                   'Value' = seasonResults$V2)
  cwint = rbind(cwint, sdf)
  
  woname = paste('no-interactions/', sstr, '.csv', sep = '')
  seasonResults = read.csv(woname, header = F)
  plstr = strsplit(as.character(seasonResults$V1), ' - ')
  pldf = t(sapply(plstr, getDfRow))
  sdf = data.frame('Player' = pldf[ , 1], 'Type' = pldf[ , 3], 'Season' = rep(season, nrow(seasonResults)),
                   'Value' = seasonResults$V2)
  cwoint = rbind(cwoint, sdf)
}
intTerms = cwint[complete.cases(cwint), ]
intTerms$Cross.Term = intTerms$Value
intTerms$Value = NULL
N = nrow(intTerms)
pwint = cwint[is.na(cwint$Player2), ]
pwint$Player2 = NULL
pwint = rename(pwint, Player = Player1)
temp = merge(x = intTerms, y = pwint, by.x = c('Player1', 'Type', 'Season'), 
             by.y = c('Player', 'Type', 'Season'), all.x = T)
pw1 = temp$Value
temp = merge(x = intTerms, y = pwint, by.x = c('Player2', 'Type', 'Season'), 
             by.y = c('Player', 'Type', 'Season'), all.x = T)
pw2 = temp$Value
ct = intTerms$Cross.Term
temp = merge(x = intTerms, y = cwoint, by.x = c('Player1', 'Type', 'Season'), 
             by.y = c('Player', 'Type', 'Season'), all.x = T)
pwo1 = temp$Value
temp = merge(x = intTerms, y = cwoint, by.x = c('Player2', 'Type', 'Season'), 
             by.y = c('Player', 'Type', 'Season'), all.x = T)
pwo2 = temp$Value
intTerms$Model.Diff = pw1 + pw2 + ct - pwo1 - pwo2
intTerms$Synergy.Pts = pw1 + pw2 + ct

### Cross-terms ############################################################################################
ggplot(intTerms[intTerms$Type == 'Off', ]) + geom_bar(aes(x = Cross.Term)) + facet_wrap('Season')
ggsave('OffenseCrossTerms.pdf')
ggplot(intTerms[intTerms$Type == 'Def', ]) + geom_bar(aes(x = Cross.Term)) + facet_wrap('Season')
ggsave('DefenseCrossTerms.pdf')
ggplot(intTerms[intTerms$Type == 'Off' & intTerms$Cross.Term != 0, ]) + geom_bar(aes(x = Cross.Term)) + 
  facet_wrap('Season')
ggsave('OffenseCrossTermsNoZeros.pdf')
ggplot(intTerms[intTerms$Type == 'Def' & intTerms$Cross.Term != 0, ]) + geom_bar(aes(x = Cross.Term)) + 
  facet_wrap('Season')
ggsave('DefenseCrossTermsNoZeros.pdf')

bestDef = intTerms[intTerms$Type == 'Def', ]
bestDef = bestDef[order(bestDef$Cross.Term), ]
bestDef$Pair = factor(paste(as.character(bestDef$Player1), '-', as.character(bestDef$Player2), '-', 
                     as.character(bestDef$Season)), ordered = T)
ggplot(bestDef[1:10, ], aes(x = Pair, y = Cross.Term, label = Pair)) + geom_point() +
  coord_flip()
ggsave('BestDefensesCrossTerms.pdf')

worstDef = intTerms[intTerms$Type == 'Def', ]
worstDef = worstDef[order(-worstDef$Cross.Term), ]
worstDef$Pair = factor(paste(as.character(worstDef$Player1), '-', as.character(worstDef$Player2), '-', 
                            as.character(worstDef$Season)), ordered = T)
ggplot(worstDef[1:10, ], aes(x = Pair, y = Cross.Term, label = Pair)) + geom_point() +
  coord_flip()
ggsave('WorstDefensesCrossTerms.pdf')

bestOff = intTerms[intTerms$Type == 'Off', ]
bestOff = bestOff[order(-bestOff$Cross.Term), ]
bestOff$Pair = factor(paste(as.character(bestOff$Player1), '-', as.character(bestOff$Player2), '-', 
                            as.character(bestOff$Season)), ordered = T)
ggplot(bestOff[1:10, ], aes(x = Pair, y = Cross.Term, label = Pair)) + geom_point() +
  coord_flip()
ggsave('BestOffensesCrossTerms.pdf')

worstOff = intTerms[intTerms$Type == 'Off', ]
worstOff = worstOff[order(worstOff$Cross.Term), ]
worstOff$Pair = factor(paste(as.character(worstOff$Player1), '-', as.character(worstOff$Player2), '-', 
                             as.character(worstOff$Season)), ordered = T)
ggplot(worstOff[1:10, ], aes(x = Pair, y = Cross.Term, label = Pair)) + geom_point() +
  coord_flip()
ggsave('WorstOffensesCrossTerms.pdf')

### Model Difference ########################################################################################
ggplot(intTerms, aes(x = Model.Diff, y = Cross.Term)) + geom_point() + facet_wrap('Type')
ggsave('ModelDiffVsCrossTerms.pdf')
ggplot(intTerms[intTerms$Type == 'Off', ]) + geom_bar(aes(x = Model.Diff)) + facet_wrap('Season')
ggsave('OffenseModelDiff.pdf')
ggplot(intTerms[intTerms$Type == 'Def', ]) + geom_bar(aes(x = Model.Diff)) + facet_wrap('Season')
ggsave('DefenseModelDiff.pdf')
ggplot(intTerms[intTerms$Type == 'Off' & intTerms$Model.Diff != 0, ]) + geom_bar(aes(x = Model.Diff)) + 
  facet_wrap('Season')
ggsave('OffenseModelDiffNoZeros.pdf')
ggplot(intTerms[intTerms$Type == 'Def' & intTerms$Model.Diff != 0, ]) + geom_bar(aes(x = Model.Diff)) + 
  facet_wrap('Season')
ggsave('DefenseModelDiffNoZeros.pdf')

bestDef = intTerms[intTerms$Type == 'Def', ]
bestDef = bestDef[order(bestDef$Model.Diff), ]
bestDef$Pair = factor(paste(as.character(bestDef$Player1), '-', as.character(bestDef$Player2), '-', 
                            as.character(bestDef$Season)), ordered = T)
ggplot(bestDef[1:10, ], aes(x = Pair, y = Model.Diff, label = Pair)) + geom_point() +
  coord_flip()
ggsave('BestDefensesModelDiff.pdf')

worstDef = intTerms[intTerms$Type == 'Def', ]
worstDef = worstDef[order(-worstDef$Model.Diff), ]
worstDef$Pair = factor(paste(as.character(worstDef$Player1), '-', as.character(worstDef$Player2), '-', 
                             as.character(worstDef$Season)), ordered = T)
ggplot(worstDef[1:10, ], aes(x = Pair, y = Model.Diff, label = Pair)) + geom_point() +
  coord_flip()
ggsave('WorstDefensesModelDiff.pdf')

bestOff = intTerms[intTerms$Type == 'Off', ]
bestOff = bestOff[order(-bestOff$Model.Diff), ]
bestOff$Pair = factor(paste(as.character(bestOff$Player1), '-', as.character(bestOff$Player2), '-', 
                            as.character(bestOff$Season)), ordered = T)
ggplot(bestOff[1:10, ], aes(x = Pair, y = Model.Diff, label = Pair)) + geom_point() +
  coord_flip()
ggsave('BestOffensesModelDiff.pdf')

worstOff = intTerms[intTerms$Type == 'Off', ]
worstOff = worstOff[order(worstOff$Model.Diff), ]
worstOff$Pair = factor(paste(as.character(worstOff$Player1), '-', as.character(worstOff$Player2), '-', 
                             as.character(worstOff$Season)), ordered = T)
ggplot(worstOff[1:10, ], aes(x = Pair, y = Model.Diff, label = Pair)) + geom_point() +
  coord_flip()
ggsave('WorstOffensesModelDiff.pdf')
