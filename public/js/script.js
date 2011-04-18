$(document).ready(function() {

  $(".snap").each(function() {
    var $this = $(this);
    if (Modernizr.csstransitions) {
      setTimeout(function() {
        $this.addClass("moved");
      }, 2000 + Math.random()*2000);
    } else {
      $this.addClass("moved");
    }
  });

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

