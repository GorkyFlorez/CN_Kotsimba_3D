
library(rayshader)
library(av)
library(geoviz)
library(sf)
library(elevatr)
library(raster)
Kotsimba = st_read("SHP/Kotsimba.geojson")  %>% st_as_sf()
Kotsimb  <- st_transform(Kotsimba,crs = st_crs("+proj=longlat +datum=WGS84 +no_defs"))
Kotsimb_xy     <- cbind(Kotsimb , st_coordinates(st_centroid(Kotsimb $geometry)))


elev = get_elev_raster(Kotsimb , z=12)

plot(elev)
Poligo_alt    <- crop(elev, Kotsimb)                           #   
Poligo_alt   <- Poligo_alt <- mask(Poligo_alt, Kotsimb)
plot(Poligo_alt)

Area_alt=Poligo_alt

overlay_image <-
  slippy_overlay(Area_alt, image_source = "stamen", image_type = "watercolor", png_opacity = 0.5)

overlay_image <-
  elevation_transparency(overlay_image,
                         Area_alt,
                         pct_alt_high = 0.5,
                         alpha_max = 0.9)

elmat = matrix(
  raster::extract(Area_alt, raster::extent(Area_alt), method = 'bilinear'),
  nrow = ncol(Area_alt),
  ncol = nrow(Area_alt)
)

scene <- elmat %>%
  sphere_shade(sunangle = 270, texture = "desert") %>% 
  add_overlay(overlay_image)

rayshader::plot_3d(
  scene,
  elmat,
  zscale = raster_zscale(Area_alt),
  solid = FALSE,
  shadow = TRUE,
  shadowdepth = -150
)

render_scalebar(limits=c(0, 5, 10),label_unit = "km",position = "W", y=50,
                scale_length = c(0.33,1))

render_compass(position = "E")

rayshader::render_movie("Mapa/Kotsimba en 3D.mp4",frames = 720, fps=60,zoom=0.6,fov = 30)





