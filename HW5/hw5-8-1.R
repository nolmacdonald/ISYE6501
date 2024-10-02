
# Load libraries we will need
library(tidyverse)
library(ggplot2)
library(ggimage)
library(moments)
library(tidymodels)
library(nflfastR)

# Set the working directory
setwd("~/projects/ISYE6501/HW5")



# This code chunk creates a dataframe that stores win, loss, tie, point differential info for all regular season games
pbp <- load_pbp(2014:2023)
# Create outcomes dataframe
outcomes <- pbp %>%
  filter(case_when(
    season >= 1999 & season <= 2020 ~ week <= 17,
    season >= 2021 & season <= 2023 ~ week <= 18,
    TRUE ~ FALSE  # In case seasons outside the specified range are included
  )) %>%
  group_by(season, game_id, home_team) %>%
  summarize(
    home_win = if_else(sum(result) > 0, 1, 0),
    home_tie = if_else(sum(result) == 0, 1, 0),
    home_diff = last(result),
    home_pts_for = last(home_score),
    home_pts_against = last(away_score)
  ) %>%
  group_by(season, home_team) %>%
  summarize(
    home_games = n(),
    home_wins = sum(home_win),
    home_ties = sum(home_tie),
    home_diff = sum(home_diff),
    home_pts_for = sum(home_pts_for),
    home_pts_against = sum(home_pts_against)
  ) %>%
  ungroup() %>%
  left_join(
    # away games
    pbp %>%
      filter(week <= 17) %>%
      group_by(season, game_id, away_team) %>%
      summarize(
        away_win = if_else(sum(result) < 0, 1, 0),
        away_tie = if_else(sum(result) == 0, 1, 0),
        away_diff = last(result)*-1,
        away_pts_for = last(away_score),
        away_pts_against = last(home_score)
      ) %>%
      group_by(season, away_team) %>%
      summarize(
        away_games = n(),
        away_wins = sum(away_win),
        away_ties = sum(away_tie),
        away_diff = sum(away_diff),
        away_pts_for = sum(away_pts_for),
        away_pts_against = sum(away_pts_against)
      ) %>%
      ungroup(),
    by = c("season", "home_team" = "away_team")
  ) %>%
  rename(team = "home_team") %>%
  mutate(
    games = home_games + away_games,
    wins = home_wins + away_wins,
    losses = games - wins,
    ties = home_ties + away_ties,
    win_percentage = (wins + 0.5 * ties) / games,
    point_diff = home_diff + away_diff,
    points_for = home_pts_for + away_pts_for,
    points_against = home_pts_against + away_pts_against,
    pythag_wins = (points_for^2.37 / (points_for^2.37 + points_against^2.37))*16
  ) %>%
  select(
    season, team, games, wins, losses, ties, win_percentage, point_diff, points_for, points_against, pythag_wins
  )


# This code chunk creates a dataframe that stores season long offensive and defensive stats

# Create metrics dataframe
metrics <- pbp %>% 
  filter(
    week <= 17 & pass == 1 & !is.na(epa) | 
      week <= 17 & rush == 1 & !is.na(epa)
  ) %>% 
  group_by(season, posteam) %>% 
  summarize(
    n_pass = sum(pass),
    n_rush = sum(rush),
    pass_yards = sum(yards_gained*pass, na.rm = TRUE),
    rush_yards = sum(yards_gained*rush, na.rm = TRUE),
    epa_per_pass = sum(epa*pass)/n_pass,
    epa_per_rush = sum(epa*rush)/n_rush,
    success_per_pass = sum(pass*epa>0)/n_pass,
    success_per_rush = sum(rush*epa>0)/n_rush,
    y_per_pass = sum(yards_gained*pass, na.rm = TRUE)/n_pass,
    y_per_rush = sum(yards_gained*rush, na.rm = TRUE)/n_rush
  ) %>% 
  left_join(
    pbp %>%
      filter(
        week <= 17 & pass == 1 & !is.na(epa) | 
          week <= 17 & rush == 1 & !is.na(epa)
      ) %>% 
      group_by(season, defteam) %>% 
      summarize(
        def_n_pass=sum(pass),
        def_n_rush=sum(rush),
        def_pass_yards = sum(yards_gained * pass, na.rm = TRUE),
        def_rush_yards = sum(yards_gained * rush, na.rm = TRUE),
        def_epa_per_pass=sum(-epa*pass)/def_n_pass,
        def_epa_per_rush=sum(-epa*rush)/def_n_rush,
        def_success_per_pass=sum(pass*epa>0)/def_n_pass,
        def_success_per_rush=sum(rush*epa>0)/def_n_rush,
        def_y_per_pass = sum(yards_gained*pass, na.rm = TRUE)/def_n_pass,
        def_y_per_rush = sum(yards_gained*rush, na.rm = TRUE)/def_n_rush
      ),
    by = c("season", "posteam" = "defteam")
  ) %>% 
  rename(team = "posteam") %>% 
  select(-n_pass, -n_rush, -def_n_pass, -def_n_rush)


# Create dataframe for season long outcomes and stats
df <- outcomes %>% 
  left_join(metrics, by = c("season", "team"))


# Source linear regression code
source("regression_code.R")


# Create simple linear regression based on all variables of interest and store r squared
# value of each fit in dataframe called r_squareds

# Create empty df
r_squareds <- c()

# Loop through variables and store results
for(i in 12:27) {
  input = colnames(df)[i]
  fit <- lm(data = df, wins ~ get(input))
  crit <- aa_critique_fit(fit)
  r2 <- crit$R2
  r_squareds = rbind(r_squareds, data.frame(input, r2))
}



r_squareds$metric <- r_squareds$input

r_squareds$metric <- c(
  "pass_yards" = "Pass Yards",
  "rush_yards" = "Rush Yards", 
  "epa_per_pass" = "EPA per Dropback", 
  "epa_per_rush" = "EPA per Rush",
  "success_per_pass" = "Success Rate per Dropback",
  "success_per_rush" = "Success Rate per Rush", 
  "y_per_pass" = "Yards per Dropback",
  "y_per_rush" = "Yards per Rush",
  "def_pass_yards" = "Pass Yards Allowed",
  "def_rush_yards" = "Rush Yards Allowed", 
  "def_epa_per_pass" = "Def EPA per Dropback",
  "def_epa_per_rush" = "Def EPA per Rush", 
  "def_success_per_pass" = "Def Success Rate per Dropback",
  "def_success_per_rush" = "Def Success Rate per Rush", 
  "def_y_per_pass" = "Def Yards per Dropback",
  "def_y_per_rush" = "Def Yards per Rush")

r_squareds <- r_squareds[order(r_squareds$r2), ]

# Create the barplot
r2_plot <- ggplot(r_squareds, aes(x = r2, y = metric, fill=metric)) +  # Set y to metric
  geom_bar(stat = "identity") +
  scale_fill_grey() + 
  geom_text(aes(label = round(r2, 3)), hjust = -0.1, size=4, fontface="bold") +
  labs(title = "R-squared Linear Regression for NFL Metrics",
       subtitle = "Win Regression using NFL Metrics | 2011-2023 NFL Seasons",
       x = "R-squared Value",
       y = "Predictors",
       caption = "Data: @nflfastR"
       ) +
  scale_x_continuous(limits = c(0, 0.6)) +
  scale_y_discrete(limits = r_squareds$metric) +  # Ensure y-axis uses the metric names
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(size = 16,
                                  hjust = 0,
                                  face = "bold",
                                  color = "black"),
        plot.subtitle = element_text(size = 10,
                                     hjust = 0,
                                     color = "black"),
        )

print(r2_plot)
# Optionally, save the plot
ggsave("figures/r_squared_regression_win_models.png", r2_plot, bg='white', width = 10, height = 6, dpi = 300)
