## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero1_i
sudo mkdir /srv/shiny-server/Tablero1_i


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero1_i

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero1_i/ /srv/shiny-server/Tablero1_i --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero1_i

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
