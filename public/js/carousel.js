function carouselPagerSetup(carousel) {
  // Wire up the 'next' button.
  $("#next_button").click(function() {
    carousel.next();
    return false;
  });

  // For every link with the .pager_button class, extract it's 'rel' attribute
  // and scroll to that index in the slideshow.
  $(".pager_button").click(function() {
    carousel.stopAuto();
    carousel.scroll(jQuery.jcarousel.intval(jQuery(this).attr('rel')));
    return false;
  });
}

function highlightPagerOnLoad(carousel, list_element, index, state) {
  // Remove highlight class from the previous element.
  $('.pager_button.active').removeClass('active');
  // Add the active class to the currently selected item.
  $('.pager_button[rel="' + index.toString() + '"]').addClass('active');
  // Hide all of the text blurbs.
  $(".slideText div").hide();
  // Show the one with the correct class.
  $(".slideText ." + index.toString()).show();
}

// jCarousel Configuration
$(function(){
  $("#carousel").jcarousel({
    scroll: 1,
    auto: 0,
    wrap: "both",
    setupCallback: carouselPagerSetup,
    itemFirstInCallback: highlightPagerOnLoad,
    buttonNextHTML: null,
    buttonPrevHTML: null
  });
});
