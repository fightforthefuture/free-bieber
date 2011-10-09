class TeaserController < ApplicationController

    def index
      send_file 'public/img/tease.png', :type=>"image/png", :disposition => 'inline'
#    redirect_to 'http://google.com'
    end 

    def headline
      send_file 'public/img/mock-con-newspaper.png', :type=>"image/png", :disposition => 'inline'
    end 

end
