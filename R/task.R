library(tidyverse)
library(lubridate)

x <- rnorm(1:10)
y <- rnorm(1:10)

df <- tibble(x, y)

p <- ggplot(df, aes(x,y)) +
  geom_point()

fname <- paste0("outputs/data_", make.names(Sys.time()), ".png")

ggsave(fname, p, dpi = 300, width = 5, height = 5)
