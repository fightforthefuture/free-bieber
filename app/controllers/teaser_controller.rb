class TeaserController < ApplicationController

    def index
      send_file 'public/img/tease.png', :type=>"image/png", :disposition => 'inline'
    end 


end
