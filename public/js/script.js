$(function() {
    $("ol.nav li a:first").addClass("active");

    var imageWidth = $(".slides").width();
    //var textWidth = $(".slideText").height();
    var imageSum = $(".slideImages li").size();
    //var textSum = $(".slideText div").size();
    var imageReelWidth = imageWidth * imageSum; 
    //var textReelWidth = textWidth * textSum; 

    $(".slideImages").css({'width' : imageReelWidth});
    //$(".slideText").css({'height' : textReelWidth});

    rotate = function() {
        var triggerID = $active.attr("rel") - 1; //Get number of times to slide
        var image_reelPosition = triggerID * imageWidth; //Determines the distance the image reel needs to slide

    $("ol.nav li a").removeClass('active'); //Remove all active class
    $active.addClass('active'); //Add active class (the $active is declared in the rotateSwitch function)

        //Slider Animation
        $(".slideImages").animate({
            left: -image_reelPosition
        }, 500 );

        $(".slideText").animate({
            left: -image_reelPosition
        }, 500 );




       };

    //Rotation  and Timing Event
    rotateSwitch = function(){
        play = setInterval(function(){ //Set timer - this will repeat itself every 7 seconds
            $active = $('ol.nav li a.active').next(); //Move to the next paging
            if ( $active.length === 0) { //If paging reaches the end...
                $active = $('ol.nav li a:first'); //go back to first
            }
            rotate(); //Trigger the paging and slider function
        }, 7000); //Timer speed in milliseconds (7 seconds)
    };

    rotateSwitch(); //Run function on launch






    //On Hover
    $(".slideImages li img").hover(function() {
        clearInterval(play); //Stop the rotation
    }, function() {
        rotateSwitch(); //Resume rotation timer
    }); 

    //On Click
    $("ol.nav li a").click(function() {
        $active = $(this); //Activate the clicked paging
        //Reset Timer
        clearInterval(play); //Stop the rotation
        rotate(); //Trigger rotation immediately
        rotateSwitch(); // Resume rotation timer
        return false; //Prevent browser jump to link anchor
    });

});
