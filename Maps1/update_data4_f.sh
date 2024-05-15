## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Maps1
sudo mkdir /srv/shiny-server/Maps1


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Maps1

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Maps1/ /srv/shiny-server/Maps1 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Maps1

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
