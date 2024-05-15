## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Pre4
sudo mkdir /srv/shiny-server/Pre4


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Pre4

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Pre4/ /srv/shiny-server/Pre4 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Pre4

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
