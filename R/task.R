library(dplyr)
library(ggplot2)
library(lubridate)
library(tdcR)

x <- rnorm(1:10)
y <- rnorm(1:10)

df <- tibble(x, y)

p <- ggplot(df, aes(x,y)) +
  geom_point()

fname <- paste0("outputs/data_", make.names(Sys.time()), ".png")

ggsave(fname, p, dpi = 300, width = 5, height = 5)


# # Exploring upload to sharepoint
# library(glue)
# library(Microsoft365R)
#
# list_sharepoint_sites()
#
# site <- get_sharepoint_site(site_name = "Environmental Monitoring")
#
#
#
# site$list_drives()
#
# site$get_drive()$list_items("Reports and Analyses")
#
# site$get_drive()$upload_file(glue("{fname}"), glue("Reports and Analyses/R Outputs/{fname}"))
