import matplotlib.pyplot as plt


line_one = [x*20 for x in range(100)]
line_two = [x*30 for x in range(110)]

plt.plot(line_one, label="series 1")
plt.plot(line_two, label="series 2")
plt.xlabel("index"); plt.ylabel("value")
plt.title("My Title", fontsize=12, loc="center", pad=8) 
plt.legend()
plt.savefig("Example.png", dpi = 300, bbox_inches="tight")