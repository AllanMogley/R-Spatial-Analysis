library(sf)
library(maptools)
library(raster)
library(spatstat)
library(ggplot2)

# Load and read the datasets for plotting

poly  <-  read_sf("E:/Allan Wafula/My Works/MyCodes/R-Spatial Analyst/DATA_R/E_Ravine.shp")
#pts  <- read_sf("E:/Allan Wafula/My Works/MyCodes/R-Spatial Analyst/DATA_R/HFC.shp")
pts  <- read_sf("E:/Allan Wafula/My Works/MyCodes/R-Spatial Analyst/DATA_R/HFC_Proj3.shp")

#print(pts)

#Plot the ward boundaries and the health facilities using ggplot
ggplot() + 
  geom_sf(data = poly, fill = "white", color = "black" )+
  geom_sf(data = pts, aes(color= Facility_t))+
  scale_color_manual(values = c("Dispensary"="#377eb8","District Hospital"="#e41a1c","Health Centre"="#4daf4a","Mission Hospital"="#984ea3"), name = "Health Facility Type")+
  ggtitle("ELDAMA/RAVINE WARD BOUNDARIES \n AND HEALTH FACILITIES")+
  theme(axis.text.x = element_text(angle = 90))

#Load the polygon shapefile(constituency boundary)  
s  <- st_read("E:/Allan Wafula/My Works/MyCodes/R-Spatial Analyst/DATA_R/E_Ravine.shp")
region  <- as.owin(s)
region <- rescale(region, 1000)



# Load a HFC.shp point feature shapefile
s  <- st_read("E:/Allan Wafula/My Works/MyCodes/R-Spatial Analyst/DATA_R/HFC_Proj3.shp")  
HFC <-  as.ppp(s)
marks(HFC) <- NULL
#HFC <- rescale(HFC, 1000)
Window(HFC)  


# Load a  population density raster layer
#img  <- raster("E:/Allan Wafula/My Works/MyCodes/R-Spatial Analyst/DATA_R/Ravine_Pop.img")
#img  <- raster("E:/Allan Wafula/My Works/MyCodes/R-Spatial Analyst/DATA_R/Ravine_Mask.img")
img  <- raster("E:/Allan Wafula/My Works/MyCodes/R-Spatial Analyst/DATA_R/Ravine_Mask_Proj2.img")
print(img)
pop  <- as.im(img)
pop <- rescale(pop, 1000)


#remove attributes
marks(HFC)  <- NULL
Window(HFC) <- region
plot(HFC, main=NULL, cols=rgb(0,0,0,.2), pch=20)

#Histogram of population layer
hist(pop, main=NULL, las=1)

#Transform the skewed pop data through log
pop.lg <- log(pop)
pop.lg <- rescale(pop.lg, 1000)
hist(pop.lg, main=NULL, las=1)

#Compute the quadrat density
Quads <- quadratcount(HFC, nx= 6, ny=3)
plot(HFC, pch=20, cols="#FF006E", main= "Quadrat Density")  # Plot points
plot(Quads, add=TRUE)  # Add quadrat grid



#Density of points in each quadrat computation
# Compute the density for each quadrat (in counts per km2)
Q   <- quadratcount(HFC, nx= 6, ny=3)
Q.d <- intensity(Quads)


# Plot the density
plot(intensity(Q, image=TRUE), main= "Point Density Per Quadrat", las=1)  # Plot density raster
plot(HFC, pch=20, cex=1.2, col=rgb(0,0,0,.5), add=TRUE)  # Add points

#Quadrant Density On a tessellated surface
databrks  <- c( -Inf, 4, 6, 8 , Inf)  # Define the breaks
Zcut <- cut(pop.lg, breaks=databrks, labels=1:4)  # Classify the raster
plot(Zcut)




#-------------------------------------------------------------------------------
te <- tess(image=Zcut)  # Create a tessellated surface
tiles(te)
plot(te, main="Tessellated Surface")
Q   <- quadratcount(HFC, tess = te)  # Tally counts
Q.d <- intensity(Q)  # Compute density
Q.d
#-------------------------------------------------------------------------------




#set style and plot
cols <-  interp.colours(c("#edf8b1", "#7fcdbb" ,"#2c7fb8"), te$n)
plot( intensity(Q, image=TRUE), las=1, col=cols, main= "Tessellated")
plot(HFC, pch=20, cex=1.2, col=rgb(0,0,0), add=TRUE)

#Kernel Density Raster
Kd1 <- density(HFC) # Using the default bandwidth
plot(Kd1, main="Kernel Density Raster\n(default bandwidth)", las=1)
contour(Kd1, add=TRUE)

#Using 50km bandwidth
Kd2 <- density(HFC, sigma=50) # Using a 50km bandwidth
plot(Kd2, main="Kernel Density Raster\n(50km bandwidth)", las=1)
contour(Kd2, add=TRUE)

#Change Smoothing Function
Kd3 <- density(HFC, kernel = "quartic", sigma=50) # Using a 50km bandwidth
plot(Kd3, main="Kernel Density Raster\n(quartic smoothing function)", las=1)
contour(Kd3, add=TRUE)


