## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero3_f
sudo mkdir /srv/shiny-server/Tablero3_f


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero3_f

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero3_f/ /srv/shiny-server/Tablero3_f --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero3_f

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
