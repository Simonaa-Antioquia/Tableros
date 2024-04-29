## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero7
sudo mkdir /srv/shiny-server/Tablero7


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero7

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero7/ /srv/shiny-server/Tablero7 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero7

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
