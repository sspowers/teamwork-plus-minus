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
tim_idx = 18
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
    player_minutes = {}
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
        court = event[3:13]
        play_time = event[tim_idx]
        play_time = play_time.split(':')
        play_time = int(play_time[2])
        if play_time == 0:
            continue
        for player in court:
            if player in player_minutes.keys():
                player_minutes[player] += play_time
            else:
                player_minutes[player] = play_time
    header = ['Player', 'Minutes']
    with open('PlayerMinutes' + season + '.csv', 'w') as f:
        writer = csv.writer(f)
        writer.writerow(header)
    for player, minutes in player_minutes.items():
        row = [player, minutes/60.]
        with open('PlayerMinutes' + season + '.csv', 'a') as f:
            writer = csv.writer(f)
            writer.writerow(row)