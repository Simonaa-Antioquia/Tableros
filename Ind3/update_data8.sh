## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero8
sudo mkdir /srv/shiny-server/Tablero8


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero8

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero8/ /srv/shiny-server/Tablero8 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero8

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
