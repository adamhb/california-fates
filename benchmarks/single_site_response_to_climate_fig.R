library(tidyverse)
library(cowplot)


df <- read_csv('~/cloud/gdrive/postdoc/california-fates/benchmarks/dry_wet_comparison_fig.csv')
df$Var <- factor(df$Var, levels = c("Con_BA","Oak_BA","Shrub_cover"))


default_font_size <- 26

# Create a custom labeller function
# custom_labeller <- function(variable, value) {
#   facet_titles <- c("Con_BA" = "Conifer basal area", "Oak_BA" = "Oak basal area")
#   return(facet_titles[value])
# }
# 
# 
# ggplot(df %>% filter(Var %in% c("Con_BA","Oak_BA")), aes(x = Site, y = Value)) +
#   geom_boxplot() +
#   facet_wrap(~Var, labeller = as_labeller(custom_labeller)) +
#   #facet_wrap(~ Var, scales = "free", labeller = label_parsed) +
#   #scale_y_log10() +
#   labs(x = "Site", y = "Value") +
#   theme_minimal()

oak <- ggplot(df %>% filter(Var == "Oak_BA"), aes(x = Site, y = Value)) +
  geom_boxplot() +
  labs(x = "Site", y = "Basal area [m2 ha-1]", title = "Oak basal area") +
  theme_minimal() +
  scale_y_log10() +
  theme(plot.title = element_text(hjust = 0.5, size = default_font_size),
        legend.text = element_text(size = default_font_size),
        axis.title.y = element_text(size = default_font_size),
        axis.title.x = element_text(size = default_font_size),
        axis.text = element_text(size = default_font_size,color = "black"))

#ggsave("~/cloud/gdrive/postdoc/california-fates/figures/oak_dry_wet.pdf", plot = oak, device = "pdf")


con <- ggplot(df %>% filter(Var == "Con_BA"), aes(x = Site, y = Value)) +
  geom_boxplot() +
  labs(x = "Site", y = "Basal area [m2 ha-1]", title = "Conifer basal area") +
  theme_minimal() +
  scale_y_continuous(limits = c(0,65)) +
  #scale_y_log10() +
  theme(plot.title = element_text(hjust = 0.5, size = default_font_size),
        legend.text = element_text(size = default_font_size),
        axis.title.y = element_text(size = default_font_size),
        axis.title.x = element_text(size = default_font_size),
        axis.text = element_text(size = default_font_size,color = "black"))

#ggsave("~/cloud/gdrive/postdoc/california-fates/figures/con_dry_wet.pdf", plot = con, device = "pdf")




shrub <- ggplot(df %>% filter(Var == "Shrub_cover"), aes(x = Site, y = Value)) +
  geom_boxplot() +
  labs(x = "Site", y = "Shrub cover [% ground area]", title = "Shrub cover") +
  theme_minimal() +
  #scale_y_log10() +
  theme(plot.title = element_text(hjust = 0.5, size = default_font_size),
        legend.text = element_text(size = default_font_size),
        axis.title.y = element_text(size = default_font_size),
        axis.title.x = element_text(size = default_font_size),
        axis.text = element_text(size = default_font_size, color = "black"))

#ggsave("~/cloud/gdrive/postdoc/california-fates/figures/shrub_dry_wet.pdf", plot = shrub, device = "pdf")


plots <- plot_grid(con,oak,shrub, align = "v",nrow = 1,
          label_x = 1.1, label_y = 1)

ggsave("~/cloud/gdrive/postdoc/california-fates/figures/con_oak_shrub_dry_wet.pdf", plot = plots, device = "pdf")
plots





df$Var <- factor(df$Var, levels = c("Shrub_cover", "Con_BA", "Oak_BA"))

ggplot(df, aes(x = Site, y = Value)) +
  geom_boxplot() +
  scale_y_log10(data = subset(df, Var == "Shrub_cover")) + #Apply log scale only to Shrub_over
  facet_wrap(~ Var, scales = "free") +
  labs(x = "Site", y = "Value") +
  ggtitle("Grouped Box Plots by Site and Faceted by Var")