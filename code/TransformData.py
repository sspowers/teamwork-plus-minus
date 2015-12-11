import os
import csv


def TransformSeasonData(season):
    games_list = os.listdir('NBAstuffer/' + season)
    games_list.pop(0)
    auto_skip_events = ['timeout', 'sub', 'violation', 'jump ball']
    h = ['h' + str(x) for x in range(1, 6)]
    a = ['a' + str(x) for x in range(1, 6)]
    qtr_idx = 13
    team_idx = 20
    etype_idx = 21
    ftype_idx = 37
    result_idx = 35
    pts_idx = 32
    off_foul_str = 'off.foul'
    headers = a + h
    headers.append('Possession')
    headers.append('Points')
    headers.append('Game ID')
    with open('PossessionData' + season + '.csv', 'w') as f:
        writer = csv.writer(f)
        writer.writerow(headers)
    game_idx = 0
    pprog = 0
    for game in games_list:
        # print game
        progress = int(game_idx*100./len(games_list))
        game_idx += 1
        if progress != pprog:
            print 'Season ' + season + ' ' + str(progress) + '% complete'
            pprog = progress
        game_possessions = []
        with open('NBAstuffer/' + season + '/' + game, 'rU') as f:
            game_reader = csv.reader(f)
            for row in game_reader:
                game_possessions.append(row)
        categories = game_possessions.pop(0)
        home_team = game[28:31]
        poss_pts = 0
        while len(game_possessions) > 0:
            possession = game_possessions.pop(0)
            qtr = possession[qtr_idx]
            team = possession[team_idx]
            if team == '':
                continue
            etype = possession[etype_idx]
            ftype = possession[ftype_idx]
            result = possession[result_idx]
            if etype in auto_skip_events:
                continue
            if etype == 'foul' and (ftype != off_foul_str or ftype != 'o'):
                continue
            if etype != 'free throw':
                try:
                    poss_pts += int(possession[pts_idx])
                except ValueError:
                    pass
            else:
                if result == 'made':
                    poss_pts += 1
            try:
                nxt_poss = game_possessions[0]
                nxt_etype = nxt_poss[etype_idx]
                nxt_ftype = nxt_poss[ftype_idx]
                while (nxt_etype in auto_skip_events) or (nxt_etype == 'foul' and
                                                              (nxt_ftype != off_foul_str and nxt_ftype != 'o')):
                    game_possessions.pop(0)
                    nxt_poss = game_possessions[0]
                    nxt_etype = nxt_poss[qtr_idx]
                nxt_team = nxt_poss[team_idx]
                nxt_qtr = nxt_poss[qtr_idx]
            except IndexError:
                nxt_team = ''
                nxt_qtr = ''
                nxt_etype = ''
                nxt_ftype = ''
            if team != nxt_team or qtr != nxt_qtr or (nxt_etype == 'foul' and (nxt_ftype == off_foul_str or nxt_ftype == 'o')):
                if team == home_team:
                    poss_team = 'Home'
                else:
                    poss_team = 'Away'
                players = possession[3:13]
                poss_data = players + [poss_team]
                poss_data.append(poss_pts)
                poss_data.append(possession[0])
                with open('PossessionData' + season + '.csv', 'a') as f:
                    writer = csv.writer(f)
                    writer.writerow(poss_data)
                poss_pts = 0

season_list = ['2004-05', '2005-06', '2006-07', '2007-08', '2008-09', '2009-10', '2010-11', '2011-12', '2012-13',
               '2013-14', '2014-15']
for season in season_list:
    TransformSeasonData(season)
# TransformSeasonData('2004-05')