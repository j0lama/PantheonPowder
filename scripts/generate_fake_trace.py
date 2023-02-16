with open('test.trace', 'w') as f:
    for i in range(33001):
        if i >= 15000 and i <= 20000:
            continue
        for j in range(4):
            f.write('{0}\n'.format(i))
