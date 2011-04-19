// Source:
// https://gist.github.com/268257
//
// $('img.photo',this).imagesLoaded(myFunction)
// execute a callback when all images have loaded.
// needed because .load() doesn't work on cached images

// mit license. paul irish. 2010.
// webkit fix from Oren Solomianik. thx!

// callback function is passed the last image to load
//   as an argument, and the collection as `this`


$.fn.imagesLoaded = function(callback){
  var elems = this.children('img'),
      len   = elems.length;

  elems.bind('load',function(){
      if (--len <= 0){ callback.call(elems,this); }
  }).each(function(){
     // cached images don't fire load sometimes, so we reset src.
     if (this.complete || this.complete === undefined){
        var src = this.src;
        // webkit hack from http://groups.google.com/group/jquery-dev/browse_thread/thread/eee6ab7b2da50e1f
        // data uri bypasses webkit log warning (thx doug jones)
        this.src = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==";
        this.src = src;
     }
  });

  return this;
};

$(document).ready(function() {

  // FIXME: imagesLoaded is waiting until ajax to complete before firing, no good.
  //$("#images",this).imagesLoaded(function() {
    $('.snap').each(function() {
      var $this = $(this);
      if (Modernizr.csstransitions) {
        setTimeout(function() {
          $this.addClass("moved");
        }, 1000 + Math.random()*2000);
      } else {
        $this.addClass("moved");
      }
    });
  //});

  $("script[type='text/x-jquery-template']").each( function () {
    $.template(this.id, this.innerHTML);
  });

  $holder = $("#eventlist");

  $.ajax({
    dataType:   "json",
    url:        "/events.json",
    beforeSend: function(){
                  $holder.after("<div id='loading'>Loading events...</div>");
                },
    success:    function( data ) {
                  $holder.empty();
                  $("#loading").fadeOut('fast');
                  if (data.length > 0) {
                    $.tmpl( "event-template", data ).appendTo($holder).fadeIn('fast');
                  } else {
                    $holder.after("<div>No upcoming courses are scheduled, check back later.</div>");
                  }
                },
    error:      function ( data ) {
                  $holder.empty();
                  $("#loading").fadeOut('fast');
                  $holder.after("<div id='error'>The ticketing system seems down, try again later?</div>");
                }
  });

});

