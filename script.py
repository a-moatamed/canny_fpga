import pandas as pd
import matplotlib.pyplot as plt

# Load CSV
data = pd.read_csv("results/timing_results.csv")

# Plot per image
images = data["image"].unique()

for img in images:
    subset = data[data["image"] == img]

    plt.plot(subset["size"], subset["avg_time_us"], marker='o', label=img)

plt.xlabel("Image Size (NxN)")
plt.ylabel("Processing Time (microseconds)")
plt.title("Canny Edge Detection Performance")
plt.legend()
plt.grid(True)

plt.show()