import json
import matplotlib.pyplot as plt

f = open('logs/20220510-bw.json')
data = json.load(f)

def plotinate(ax, D, col):
    lw = 2
    ms = 6
    sizes=D['size']
    bw=D['bw']
    ax.plot(sizes, bw, col+'-',  marker='o', linewidth=lw, markersize=ms, markeredgecolor=col, markeredgewidth=2, markerfacecolor='white')

def plot_pretty(title):
    plt.yscale('log')
    plt.xscale('log')
    plt.xlabel('message size (bytes)', fontsize=18)
    plt.ylabel('bandwidth (Mb)', fontsize=18)
    plt.title(title, fontsize=20)
    plt.grid(True)


fig, ax = plt.subplots()

# compare inter-node transfer: g2g vs. h2h
plotinate(ax, data['inter-ib-hh'],  'y')
plotinate(ax, data['inter-osu-hh'], 'b')
plotinate(ax, data['inter-osu-dd'], 'r') # the result we want to match/exceed the others
ax.legend(['infiniband-hh', 'osu-hh', 'osu-dd'])
plot_pretty('Inter-node bandwidth')

fig, ax = plt.subplots()
# compare intra-node g2g transfer
plotinate(ax, data['intra-cuda-dd'], 'y')
plotinate(ax, data['intra-osu-dd'],  'r') # the result we want to match/exceed the others
ax.legend(['cudamemcpy', 'osu-dd'])
plot_pretty('Intra-node bandwidth')

fig, ax = plt.subplots()
# compare intra-node and inter-node g2g transfer
plotinate(ax, data['inter-osu-dd'], 'b')
plotinate(ax, data['intra-osu-dd'], 'r')
ax.legend(['inter-node', 'intra-node'])
plot_pretty('G2G bandwidth: intra and inter node')

plt.show()
