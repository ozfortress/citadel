// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready(function(){
    var league_schedule = $('#league_schedule');
    var OPTIONS = ['weeklies'];

    function update() {
        OPTIONS.forEach(function(option) {
            var attr = $('#' + option);

            if (league_schedule.val() === option) {
                attr.css('display','block');
            } else {
                attr.css('display','none');
            }
        });
    }

    update();
    league_schedule.change(update);
});
