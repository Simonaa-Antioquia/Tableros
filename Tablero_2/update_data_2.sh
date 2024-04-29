## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero_2
sudo mkdir /srv/shiny-server/Tablero_2


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero_2

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero_2/ /srv/shiny-server/Tablero_2 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero_2

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
