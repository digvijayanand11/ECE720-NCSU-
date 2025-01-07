import pandas as pd
import sys

# take argument for filename.csv to clean
csv_filename = sys.argv[1]
df = pd.read_csv(csv_filename)

# remove rows with NaN
df_cleaned = df.dropna()

# create a cleaned copy of results.csv
output_file = csv_filename
df_cleaned.to_csv(output_file, index=False)

