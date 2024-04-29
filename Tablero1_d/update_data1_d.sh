## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero1_d
sudo mkdir /srv/shiny-server/Tablero1_d


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero1_d

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero1_d/ /srv/shiny-server/Tablero1_d --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero1_d

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
