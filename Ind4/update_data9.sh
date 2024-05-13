## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero9
sudo mkdir /srv/shiny-server/Tablero9


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero9

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero9/ /srv/shiny-server/Tablero9 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero9

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
