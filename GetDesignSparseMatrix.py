import time
import csv
import itertools
import os


def get_matrix(season):
    interaction = True
    start_time = time.time()
    possessions = []
    with open('Data/PossessionData' + season + '.csv', 'r') as f:
        game_reader = csv.reader(f)
        for row in game_reader:
            possessions.append(row)
    possessions.pop(0)
    if interaction:
        if os.path.isfile('DesignMatrix.csv'):
            os.remove('DesignMatrix.csv')
    else:
        if os.path.isfile('DesignMatrixNoInteract.csv'):
            os.remove('DesignMatrixNoInteract.csv')
    numrows = len(possessions)
    row_idx = 1
    colnames = {}
    col_idx = 1
    prev_prg = 0
    for p in possessions:
        prg = row_idx*100/numrows
        if prg > prev_prg:
            print 'Season ' + season + ' ' + str(prg) + '% completed'
            prev_prg = prg
        pos = p[10]
        if pos == 'Home':
            defense = p[0:5]
            offense = p[5:10]
        else:
            offense = p[0:5]
            defense = p[5:10]
        if interaction:
            def_cmbn = itertools.combinations(defense, 2)
            off_cmbn = itertools.combinations(offense, 2)

        for player in defense:
            st = player + ' - Def'
            i = row_idx
            if st not in colnames:
                colnames[st] = col_idx
                col_idx += 1
            j = colnames[st]
            if interaction:
                with open('DesignMatrix' + season + '.csv', 'a') as f:
                    writer = csv.writer(f)
                    writer.writerow([i, j])
            else:
                with open('DesignMatrixNoInteraction' + season + '.csv', 'a') as f:
                    writer = csv.writer(f)
                    writer.writerow([i, j])

        for player in offense:
            st = player + ' - Off'
            i = row_idx
            if st not in colnames:
                colnames[st] = col_idx
                col_idx += 1
            j = colnames[st]
            if interaction:
                with open('DesignMatrix' + season + '.csv', 'a') as f:
                    writer = csv.writer(f)
                    writer.writerow([i, j])
            else:
                with open('DesignMatrixNoInteraction' + season + '.csv', 'a') as f:
                    writer = csv.writer(f)
                    writer.writerow([i, j])
        if interaction:
            for pair in def_cmbn:
                st = min(pair[0], pair[1]) + ' - ' + max(pair[0], pair[1]) + ' - Def'
                i = row_idx
                if st not in colnames:
                    colnames[st] = col_idx
                    col_idx += 1
                j = colnames[st]
                with open('DesignMatrix' + season + '.csv', 'a') as f:
                    writer = csv.writer(f)
                    writer.writerow([i, j])

            for pair in off_cmbn:
                st = min(pair[0], pair[1]) + ' - ' + max(pair[0], pair[1]) + ' - Off'
                i = row_idx
                if st not in colnames:
                    colnames[st] = col_idx
                    col_idx += 1
                j = colnames[st]
                with open('DesignMatrix' + season + '.csv', 'a') as f:
                    writer = csv.writer(f)
                    writer.writerow([i, j])

        row_idx += 1
    if interaction:
        with open('ColNames' + season + '.csv', 'w') as f:
            writer = csv.writer(f)
            for key, value in colnames.items():
                writer.writerow([key, value])
    else:
        with open('ColNamesNoInteraction' + season + '.csv', 'w') as f:
            writer = csv.writer(f)
            for key, value in colnames.items():
                writer.writerow([key, value])

    print("Time elapsed: %s seconds" % (time.time() - start_time))

season_list = ['2004-05', '2005-06', '2006-07', '2007-08', '2008-09', '2009-10', '2010-11', '2011-12', '2012-13',
               '2013-14', '2014-15']
for season in season_list:
    get_matrix(season)
# get_matrix('2004-05')