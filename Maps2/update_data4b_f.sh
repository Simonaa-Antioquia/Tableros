## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Maps2
sudo mkdir /srv/shiny-server/Maps2


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Maps2

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Maps2/ /srv/shiny-server/Maps2 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Maps2

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
