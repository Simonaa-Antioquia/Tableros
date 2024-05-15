## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Pre3
sudo mkdir /srv/shiny-server/Pre3


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Pre3

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Pre3/ /srv/shiny-server/Pre3 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Pre3

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
