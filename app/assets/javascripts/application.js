// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require dropzone
//= require materialize
//= require_tree .

$( document ).on('turbolinks:load',function(){
  $('body').on('click', '.booking-card', function(e){
    $('.search-results').addClass('hide');
    $('.missing_images_wrapper').removeClass('hide');
    if($(e).hasClass('booking-card')){
      var id = $(e).attr('id');
    }else{
      var id = $(e.target).parents('.booking-card').attr('id')
    }
    window.location.href = "booking-by-reference/" + id;
  })
  $('.datepicker').datepicker();
  $('#submit-form').on('click', searchForBookings);

  if($('.booking-show-wrapper').length){
    var bookingId = $('.booking-show-wrapper').attr('id');
    getImageData(bookingId)
  }
});


function getImageData(id){
  console.log('hit image data')
  $.ajax({
    type: "GET",
    url: "/get-missing-images/"+id+".json",
    dataType: 'json',
    success: function(data) {
      images = data["singled_pics"]
      inspection = data["singled_pics"]["inspection"];
      checkin = data["singled_pics"]["checkin"];
      rtl = data["singled_pics"]["rtl"];
      loaded = data["singled_pics"]["loaded"];
      booking = data["booking"];
      var imageTypes = [['inspection', 'Inspection Images'], ['checkin', 'Checkin Images'], ['rtl', 'Ready to load images'] ]
      $('.missing_images_wrapper').removeClass('hide');
      $('.search-results').addClass('hide');
      $('.booking-info').removeClass('hide');
      $('.preloader-container').addClass('hide');
      imageTypes.forEach(function(type) {
        $('.missing-images').append("<div class='row col s12'><h4>"+type[1]+"</h4></div>")
        images[type[0]].forEach(function(image) {
          if(image != null){
              $('.missing-images').append("<div class='col s4 image-card' data-large='"+image.image.large.url+"'data-thumb='"+image.image.thumb.url+"' data-url='"+image.image.url+"' id='"+image.id+"' > <form action='/file-upload' class='dropzone'><div class='card blue-grey'><div class='card-content white-text'><h5>"+image.name+"</h5></div></div></form></div>");
              // $('.missing-images form.dropzone').last().dropzone({ url: "/upload_to_server.json" });
              $('.missing-images form.dropzone').last().dropzone({
                url: "/upload_to_server.json",
                init: function(e) {
                  this.on("sending", function(file, xhr, formData) {
                    var element = $(this.element.parentElement).data();
                    formData.append('large', element.large);
                    formData.append('thumb', element.thumb);
                    formData.append('original', element.url);
                    // formData.append("data", "loremipsum");
                    console.log(formData)
                  });
                }
              });
          }
        });
      });


      $('span.created_at').text(booking["quotation"]["created_at"])
      $('span.departure_date').text(booking["quotation"]["departure_date"])
      $('span.model').text(booking["quotation"]["model"])
      $('span.make').text(booking["quotation"]["make"])
      $('span.registration').text(booking["registration"])
      $('span.dropoff').text(booking["dropoff"])
      $('span.colour').text(booking["colour"])
    },
    error: function(data){
      debugger
    }
  });
}
function searchForBookings(e){
    e.preventDefault();
    $('.preloader-container').removeClass('hide');
    var params = {}
    params["container"] = $('input[name="container"]').val();
    params["make"] = $('input[name="make"]').val();
    params["model"] = $('input[name="model"]').val();
    params["vehicle_type"] = $('select#vehicle_type').val();
    params["dropoff_date_min"] = $('input[name="dropoff_date_min"]').val();
    params["dropoff_date_max"] = $('input[name="dropoff_date_max"]').val();
    Object.keys(params).forEach((key) => (params[key] == "") && delete params[key]);
    Object.keys(params).forEach((key) => (params[key] == undefined) && delete params[key]);
    console.log(params);
    $.ajax({
      type: "POST",
      url: "/search.json",
      data: params,
      dataType: 'json',
      success: function(data) {
        data.forEach(function(booking) {
          $('.search-results').removeClass('hide');
          $('.preloader-container').addClass('hide');
          if(booking != null){
            $('.booking-results').append("<a><div class='col s4 booking-card' id='"+booking.id+"'><div class='card blue-grey'><div class='card-content white-text'><p>Dropoff:"+booking.dropoff+"</p><p>Model:"+booking.quotation.model+"</p><p>Make:"+booking.quotation.make+"</p></div></div></div></a>")
          }
        });
      },
    });
}
