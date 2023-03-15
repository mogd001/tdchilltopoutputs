library(dplyr)
library(ggplot2)
library(lubridate)
library(glue)
library(tdcR)

sites <- get_sites(collection = "AllRainfall", synonyms = TRUE) %>%
  mutate(
    longitude_ = longitude,
    latitude_ = latitude,
    site_name = second_synonym
  )

rainfall_data <- get_data_collection(collection = "AllRainfall", method = "Total", interval = "1 hour", time_interval = "P7D") %>%
  rename(rainfall = value) %>%
  mutate(
    datetime = with_tz(datetime, "NZ") + hours(1), # Handling rainfall total right bound time presentation e.g. 8 for 7am - 8am rainfall total.
    date = as.numeric(format(as.Date(datetime, t = "NZ"), "%Y%m%d")),
    rainfall = round(rainfall, 2)
  )

max_datetime <- max(rainfall_data$datetime)
min_datetime <- max_datetime - days(7)

rainfall_data_p7d <- rainfall_data %>%
  filter(datetime >= min_datetime)

r_summary <- rainfall_data_p7d %>%
  group_by(site) %>%
  summarise(
    p7d_rainfall_total = round(sum(rainfall, na.rm = TRUE), 0),
    p7d_max_hrly_rainfall = round(max(rainfall, na.rm = TRUE), 0)
  ) %>%
  left_join(sites, by = "site")

p <- ggplot(r_summary, aes(
  x = reorder(site_name, -p7d_rainfall_total), y = p7d_rainfall_total,
  text = paste("Site:", site_name, "\n 7 Day Rainfall Total:", p7d_rainfall_total, "mm")
)) +
  geom_bar(color = "black", alpha = 0.6, stat = "identity") +
  geom_text(mapping = aes(label = p7d_rainfall_total), size = 2, vjust = -1) +
  theme_bw() +
  labs(x = "", y = "Rainfall Total (mm)", title = glue("Rainfall P7D (mm) {min_datetime} - {max_datetime}  [NZDT]")) + # caption = glue("at {now_plot})"
  scale_y_continuous(limits = c(0, max(r_summary$p7d_rainfall_total * 1.05)), expand = c(0, NA)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

ggsave(glue("outputs/{as.Date(max_datetime, tz = 'NZ')}_rainfall_summary_p7days.png"), p, dpi = 300, height = 10, width = 16)

# get current time
now <- with_tz(Sys.time(), tz = "NZ")

# create a string with current time and "completed" text
text <- paste("Completed at:", now)

# save text to file
if (file.exists("log.txt")) {
  # append to existing file
  fileConn <- file("log.txt", open = "a")
  writeLines(text, fileConn)
  close(fileConn)
} else {
  # create new file and write text
  fileConn <- file("log.txt")
  writeLines(text, fileConn)
  close(fileConn)
}

# Exploring upload to sharepoint
# library(glue)
# library(Microsoft365R)
#
# list_sharepoint_sites()
#
# site <- get_sharepoint_site(site_name = "Environmental Monitoring")
# site$list_drives()
# site$get_drive("Reports and Analyses")$upload_file(glue("outputs/2023-03-15_rainfall_summary_p7days.png"), glue("R Outputs/2023-03-15_rainfall_summary_p7days.png"))
