import os
import csv
season_list = ['2004-05', '2005-06', '2006-07', '2007-08', '2008-09', '2009-10', '2010-11', '2011-12', '2012-13',
               '2013-14', '2014-15']
ast_idx = 22
blk_idx = 25
stl_idx = 36
plr_idx = 31
res_idx = 35
typ_idx = 37
dst_idx = 38
event_types = []

for season in season_list:
    folder_name = 'NBAstuffer/' + season
    file_list = os.listdir(folder_name)
    file_name = folder_name + '/' + file_list[0]
    events = []
    with open(file_name, 'r') as f:
        game_reader = csv.reader(f)
        for row in game_reader:
            events.append(row)
    events.pop(0)
    player_events = {}
    evt_idx = 0
    num_evts = len(events)
    prev_prg = 0
    while len(events) > 0:
        event = events.pop(0)
        progress = evt_idx*100./num_evts
        evt_idx += 1
        progress = float(int(progress*10))/10
        if progress != prev_prg:
            print 'Season ' + season + ' ' + str(progress) + '% completed'
            prev_prg = progress
        if event[ast_idx] != '':
            player = event[ast_idx]
            if player in player_events.keys():
                if 'assist' in player_events[player].keys():
                    player_events[player]['assist'] += 1
                else:
                    player_events[player]['assist'] = 1
            else:
                player_events[player] = {}
                player_events[player]['assist'] = 1
        if event[blk_idx] != '':
            player = event[blk_idx]
            if player in player_events.keys():
                if 'block' in player_events[player].keys():
                    player_events[player]['block'] += 1
                else:
                    player_events[player]['block'] = 1
            else:
                player_events[player] = {}
                player_events[player]['block'] = 1
        if event[stl_idx] != '':
            player = event[stl_idx]
            if player in player_events.keys():
                if 'steal' in player_events[player].keys():
                    player_events[player]['steal'] += 1
                else:
                    player_events[player]['steal'] = 1
            else:
                player_events[player] = {}
                player_events[player]['steal'] = 1
        player = event[plr_idx]
        court = event[3:13]
        if player == '' or player not in court:
            continue
        evt_type = event[typ_idx]
        if 'Free Throw' in evt_type:
            evt_type = 'Free Throw'
        if evt_type == 'Jump Shot':
            dsc = event[-1]
            dsc = dsc.split(' ')
            if '3PT' in dsc:
                evt_type = 'Jump Shot 3PT'
            else:
                evt_type = 'Jump Shot 2PT'
        if evt_type not in event_types:
            event_types.append(evt_type)
        if player in player_events.keys():
            if evt_type in player_events[player].keys():
                player_events[player][evt_type] += 1
            else:
                player_events[player][evt_type] = 1
        else:
            player_events[player] = {}
            player_events[player][evt_type] = 1
    header = ['Player'] + event_types
    with open('PlayerEvents' + season + '.csv', 'w') as f:
        writer = csv.writer(f)
        writer.writerow(header)
    for player, events in player_events.items():
        missing_events = list(set(event_types) - set(events.keys()))
        for evt in missing_events:
            player_events[player][evt] = 0
        row = [player]
        for evt in event_types:
            row.append(player_events[player][evt])
        with open('PlayerEvents' + season + '.csv', 'a') as f:
            writer = csv.writer(f)
            writer.writerow(row)