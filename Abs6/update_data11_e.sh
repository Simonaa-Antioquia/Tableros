## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Tablero11_e
sudo mkdir /srv/shiny-server/Tablero11_e


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero11_e

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Tablero11_e/ /srv/shiny-server/Tablero11_e --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Tablero11_e

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server