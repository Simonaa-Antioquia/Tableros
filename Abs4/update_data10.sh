## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero10
sudo mkdir /srv/shiny-server/Tablero10


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero10

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero10/ /srv/shiny-server/Tablero10 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero10

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
