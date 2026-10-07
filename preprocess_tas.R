# Extract monthly near-surface air temperature for 10 cities from the FGOALS-f3-L
# SSP5-8.5 netCDF file and save as a small CSV that webR can read.
# Run with desktop R (needs ncdf4):  Rscript preprocess_tas.R
library(ncdf4)

nc_path <- "tas_Amon_FGOALS-f3-L_ssp585_r1i1p1f1_gr_201501-210012.nc"
out_path <- "tas_city_timeseries.csv"

# Cities ordered south to north, spanning the Antarctic to the Arctic
cities <- data.frame(
  city = c("McMurdo Station", "Punta Arenas", "Sydney", "Singapore", "Mumbai",
           "Cairo", "Detroit", "Moscow", "Reykjavik", "Longyearbyen"),
  lat  = c(-77.85, -53.16, -33.87,   1.35, 19.08, 30.04, 42.33, 55.75, 64.15, 78.22),
  lon  = c(166.67, -70.91, 151.21, 103.82, 72.88, 31.24, -83.05, 37.62, -21.94, 15.63)
)

nc <- nc_open(nc_path)
lon <- ncvar_get(nc, "lon")   # 0 to 360
lat <- ncvar_get(nc, "lat")
time <- ncvar_get(nc, "time") # days since 0001-01-01, 365_day calendar
nt <- length(time)

# Convert the 365_day calendar to year and month
year <- 1 + time %/% 365
doy <- time %% 365
month <- findInterval(doy, cumsum(c(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30)))
stopifnot(all(diff(year * 12 + month) == 1)) # consecutive months, no gaps

rows <- lapply(seq_len(nrow(cities)), function(i) {
  lon360 <- cities$lon[i] %% 360
  # circular distance in longitude so cities near the 0/360 seam still work
  ix <- which.min(abs(((lon - lon360) + 180) %% 360 - 180))
  iy <- which.min(abs(lat - cities$lat[i]))
  tas_k <- ncvar_get(nc, "tas", start = c(ix, iy, 1), count = c(1, 1, nt))
  data.frame(
    city = cities$city[i],
    city_lat = cities$lat[i],
    city_lon = cities$lon[i],
    grid_lat = lat[iy],
    grid_lon = ifelse(lon[ix] > 180, lon[ix] - 360, lon[ix]),
    year = year,
    month = month,
    tas_C = round(as.numeric(tas_k) - 273.15, 2)
  )
})
nc_close(nc)

out <- do.call(rbind, rows)
write.csv(out, out_path, row.names = FALSE)
cat("Wrote", nrow(out), "rows to", out_path, "\n")
