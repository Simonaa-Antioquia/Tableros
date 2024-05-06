## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero1_e
sudo mkdir /srv/shiny-server/Tablero1_e


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero1_e

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero1_e/ /srv/shiny-server/Tablero1_e --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero1_e

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
