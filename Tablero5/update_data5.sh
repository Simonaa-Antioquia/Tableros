## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero5
sudo mkdir /srv/shiny-server/Tablero5


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero5

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero5/ /srv/shiny-server/Tablero5 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero5

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
