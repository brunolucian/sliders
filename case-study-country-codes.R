# =====================================================================================================================
# = Country Codes                                                                                                     =
# =                                                                                                                   =
# = Author: Andrew B. Collier <andrew@exegetic.biz> | @datawookie                                                     =
# =====================================================================================================================

# LIBRARIES -----------------------------------------------------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(forcats)
library(reticulate)

# ---------------------------------------------------------------------------------------------------------------------

# Count of finishers in 2017 Comrades Marathon broken down by nationality.
#
comrades_finishers <- data.frame(country_code = c("AE", "AR", "AT", "AU", "BE", "BJ", 
                                                  "BR", "BW", "BY", "CA", "CD", "CH", "CI", "CM", "CN", "CO", "CZ", 
                                                  "DE", "DK", "ES", "FR", "GB", "GM", "HK", "HN", "IE", "IL", "IN", 
                                                  "IT", "JP", "KE", "LS", "LV", "MU", "MW", "MX", "MY", "MZ", "NA", 
                                                  "NG", "NL", "NO", "NZ", "PH", "PT", "RO", "RU", "SA", "SE", "SG", 
                                                  "SI", "SZ", "TZ", "UA", "UG", "US", "VG", "ZA", "ZM", "ZW", NA),
                                 count = c(6L, 5L, 4L, 119L, 3L, 1L, 134L, 28L, 1L, 36L, 
                                           1L, 19L, 1L, 2L, 1L, 4L, 3L, 57L, 2L, 6L, 10L, 199L, 1L, 3L, 
                                           1L, 12L, 3L, 81L, 4L, 12L, 10L, 25L, 4L, 1L, 8L, 3L, 2L, 4L, 
                                           16L, 5L, 31L, 2L, 17L, 1L, 13L, 1L, 49L, 1L, 10L, 4L, 2L, 38L, 
                                           3L, 2L, 1L, 119L, 1L, 8059L, 11L, 98L, 4549L))

# [!] Take a look at the data using head() and tail().

ggplot(comrades_finishers, aes(x = country_code, y = count)) +
  geom_col() +
  labs(x = "", y = "Comrades 2017 Finishers")

# What sucks about that plot? There are at LEAST two serious problems!

# ---------------------------------------------------------------------------------------------------------------------

use_virtualenv("test")
#
pycountry <- import("pycountry")

# Test it out with a single code.
#
(de <- pycountry$countries$get(alpha_2 = 'DE'))            # [Python] Equivalent to pycountry.countries.get()
de$name

# Write a function wrapper.
#
get_country_name <- function(alpha_2) {
  # [!] Function body goes here. Make sure to deal with NA input!
  NA
}
#
# Test it.
#
get_country_name('DE')
get_country_name('ZA')
#
# It's not vectoried out of the box. We'd need to do some more work for that! But we can use sapply().

# Systematically extract country names.
#
comrades_finishers <- comrades_finishers %>% mutate(
  country_name = sapply(country_code, get_country_name)
)
tail(comrades_finishers)

# ---------------------------------------------------------------------------------------------------------------------

comrades_finishers %>%
  mutate(
    # Sort country name factor by count.
    country_name = fct_reorder(country_name, count)
  ) %>%
  # Filter for the logarithmic scale.
  filter(count > 1) %>%
  ggplot(aes(x = country_name, y = count)) +
  geom_col(fill = "#2980b9") +
  geom_text(aes(label = count), y = 0, size = 3, hjust = -0.25, color = "white") +
  scale_y_log10("", breaks = 10**(0:4)) +
  scale_x_discrete("") +
  ggtitle("Comrades 2017 Finishers") +
  # Change orientation.
  coord_flip() +
  theme_classic()
