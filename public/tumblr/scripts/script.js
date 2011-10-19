$(function(){

    var $tumblelog = $('#content');
  
    $tumblelog.imagesLoaded( function(){
      $tumblelog.masonry({
        columnWidth: 342,
        gutterWidth: 30
      });
    });
  
  });