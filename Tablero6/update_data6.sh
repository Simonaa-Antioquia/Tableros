## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero6
sudo mkdir /srv/shiny-server/Tablero6


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero6

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero6/ /srv/shiny-server/Tablero6 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero6

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
