## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero4
sudo mkdir /srv/shiny-server/Tablero4


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero4

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero4_b/ /srv/shiny-server/Tablero4_b --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero4

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
