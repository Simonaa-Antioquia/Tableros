## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Pre2
sudo mkdir /srv/shiny-server/Pre2


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Pre2

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Pre2/ /srv/shiny-server/Pre2 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Pre2

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
