data_path="/glade/work/adamhb/processed_output/supIg105_020224/ts_supIg105_020224.csv"

variables = ["Burned_area",
             "Pct_high_severity_3500","Pct_high_severity_1700",
             "TreeStemD", "Pct_shrub_cover_canopy", "BA_conifer", "BA_oak",
             "Pct_conifer_cover_canopy","Pct_oak_cover_canopy"]




# Set the number of columns for the subplots
num_cols = 2

# Calculate the number of rows needed for subplots
num_rows = (len(variables) + num_cols - 1) // num_cols

# Convert the year 1870 to a datetime object
year_1870 = datetime(1870, 1, 1)
plt.rc('font', size=16)
default_font_size = 16

# Create a figure with subplots
fig, axes = plt.subplots(num_rows, num_cols, figsize=(16.8, 16.8), dpi=400)
axes = axes.flatten()

# Loop through each variable and create a subplot

for i, var in enumerate(variables):
    ax = axes[i]

#    if (var == "Pct_high_severity_1700") | (var == "Pct_high_severity_3500"):
#        print(output_df_PHS[output_df_PHS[['Date','Harmonized_tag']].duplicated()])
#        sns.lineplot(x="Date", y=var, units="Harmonized_tag", data=output_df_PHS.reset_index(), ax=ax, color = "grey", alpha = 0.2, estimator=None)
#    else:
    # Use seaborn to create a line plot for each unique group with grey lines
    sns.lineplot(x="Date", y=var, units="Harmonized_tag", data=output_df, ax=ax, color = "grey", alpha = 0.2, estimator=None)

    # Set plot title and labels
    if var == "Burned_area":
        ax.set_title("Fractional area burned")
        ax.set_ylabel("Area burned [% simulation area]", fontsize = default_font_size)
        ax.set_ylim(ymin=0)  # Set ymin for the Burned_area panel to be 0
    elif var == "Pct_high_severity_1700":
        ax.set_title("Percent of fires burning \n at high severity")
        ax.set_ylabel("Percent of fires \n high severity", fontsize = default_font_size)
    elif var == "TreeStemD":
        ax.set_title("Tree stem density")
        ax.set_ylabel("Tree stem density [N ha-1]")
    elif var == "Pct_shrub_cover_canopy":
        ax.set_title("Shrub cover")
        ax.set_ylabel("Shrub cover [% ground area]")
    elif var == "BA_conifer":
        ax.set_title("Conifer basal area")
        ax.set_ylabel("Basal area [m2 ha-1]")
    elif var == "BA_oak":
        ax.set_title("Oak basal area")
        ax.set_ylabel("Basal area [m2 ha-1]")
    elif var == "Pct_conifer_cover_canopy":
        ax.set_title("Conifer cover")
        ax.set_ylabel("Conifer cover [% ground area]")
    elif var == "Pct_oak_cover_canopy":
        ax.set_title("Oak cover")
        ax.set_ylabel("Oak cover [% ground area]")

    ax.set_xlabel("Year")  # Change the x-axis label to "Year"
     # Add a vertical line at 1870 to all panels
    ax.axvline(x=year_1870, color="red", linestyle="--")

    # Add a black trend line representing the mean of the groups


    if (var == "Pct_high_severity_1700") | (var == "Pct_high_severity_3500"):
        mean_values = output_df_PHS.groupby("Date")[var].mean()
    else:
        mean_values = output_df.groupby("Date")[var].mean()

    ax.plot(mean_values.index, mean_values.values, color="black", linestyle="--", label="Mean")

    # Remove the legend
    #ax.get_legend().remove()

# Remove any empty subplots
for i in range(len(variables), num_rows * num_cols):
    fig.delaxes(axes[i])

# Adjust layout
plt.tight_layout()

#plt.savefig(figName, format="pdf", bbox_inches="tight")

# Show the plot
plt.show()


             
