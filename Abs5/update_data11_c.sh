## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero11_c
sudo mkdir /srv/shiny-server/Tablero11_c


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero11_c

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero11_c/ /srv/shiny-server/Tablero11_c --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero11_c

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
