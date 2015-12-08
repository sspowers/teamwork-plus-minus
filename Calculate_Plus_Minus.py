import csv
possessions = []
with open('PossessionData.csv', 'r') as f:
    game_reader = csv.reader(f)
    for row in game_reader:
        possessions.append(row)
plusminus = {}
possessions.pop(0)
poss_idx = 1
pp = 0
for p in possessions:
    cp = (100*poss_idx)/len(possessions)
    if cp > pp:
        print 'Progress: ' + str(cp) + '%'
        pp = cp
    poss_idx += 1
    away = p[0:5]
    home = p[5:10]
    team = p[10]
    pts = int(p[11])
    if team == 'Home':
        for pl in home:
            if pl in plusminus.keys():
                plusminus[pl] += pts
            else:
                plusminus[pl] = pts
        for pl in away:
            if pl in plusminus.keys():
                plusminus[pl] -= pts
            else:
                plusminus[pl] = pts
    elif team == 'Away':
        for pl in home:
            if pl in plusminus.keys():
                plusminus[pl] -= pts
            else:
                plusminus[pl] = pts
        for pl in away:
            if pl in plusminus.keys():
                plusminus[pl] += pts
            else:
                plusminus[pl] = pts
with open('PlusMinus.csv', 'w') as f:
    writer = csv.writer(f)
    for key, value in plusminus.items():
        writer.writerow([key, value])