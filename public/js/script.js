function startMoving() {
  $('.snap').each(function() {
    var $this = $(this);
    $this.show();
    if (Modernizr.csstransitions) {
      setTimeout(function() {
        $this.addClass("moved");
      }, (Math.random()*1500));
    } else {
      $this.addClass("moved");
    }
  });
}

function loadEvents() {
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
                },
    timeout:    300000
  });
}

$(document).ready(function() {

  $holder = $("#eventlist");
  $("#images img").imagesLoaded( startMoving );
  loadEvents();

  $("script[type='text/x-jquery-template']").each( function () {
    $.template(this.id, this.innerHTML);
  });


});

