

(function() {
	var ready = function () {

		// WIP: This is a quick fix and will need to be cleaned up / checked at a later date
		// detect IE
		var IEversion = detectIE();

		/**
		 * detect IE
		 * returns version of IE or false, if browser is not Internet Explorer
		 */
		function detectIE() {
		  var ua = window.navigator.userAgent;

		  var msie = ua.indexOf('MSIE ');
		  if (msie > 0) {
		    // IE 10 or older => return version number
		    return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
		  }

		  var trident = ua.indexOf('Trident/');
		  if (trident > 0) {
		    // IE 11 => return version number
		    var rv = ua.indexOf('rv:');
		    return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
		  }

		  var edge = ua.indexOf('Edge/');
		  if (edge > 0) {
		    // Edge (IE 12+) => return version number
		    return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
		  }

		  // other browser
		  return false;
		}

		if(detectIE()){
			if ($('.switch').length > 0){
				$('.switch .switch-label, .switch .switch-handle').on('click', function() {
					var checkbox = $(this).parent().find('input[type="checkbox"]');
					if (checkbox.prop('checked') == true) {
						checkbox.prop('checked', false)
					} else {
						checkbox.prop('checked', true)
					}
				});
			}
		}

		$('.chosen-select').chosen();
		$('.chosen-select-plain').chosen({
			disable_search: true
		});
        $('.chosen-select-games').chosen({
            width: "100%"
        });
		$('.date-time-picker').each(function () {
			$(this).datetimepicker({
				format: 'm/d/Y g:ia',
				formatTime: 'g:ia'
			});
		});

		$('#subscription_ends_on').mobiscroll().date({
			theme: 'ios',
			lang: 'en',
			display: 'bottom',
			focusTrap: false
		});
		//Sign up
		$('#user_username').keypress(function(e){
	    if(e.which === 32){
      	return false;
      }
	  });

		$('.date-picker').each(function() {
			$(this).datetimepicker({
				timepicker: false,
				format: 'm/d/Y',
				startDate: $(this).attr('data-start-date'),
				scrollInput: false
			});
		});
        new WOW().init();
		$('.contract-calendar').fullCalendar({
			displayEventStart: false,
			displayEventEnd: false,
			allDaySlot: false,
			timezone: 'local',
			defaultView: 'agendaWeek',
			height: 'auto',
			header: {
				left: 'prev,next ',
				center: 'title',
				right: 'today'
			},
			events: {
				url: '/profiles/' + $('.contract-calendar').attr('data-user-id') + '/contracts',
				startParam: 'start_date_time',
				endParam: 'end_date_time'
			},
			eventClick: function (calEvent, jsEvent, view) {
				var route = calEvent.type == 'Contract' ? '/contracts/' : '/bounties/';
				$.get(route + calEvent.id + '.js');
			}
		});
		$('.start-date-times .close').click(function(){
			$(this).closest('.time-slot').remove();
		});
		$('.input-slider').slider();
		$('.input-slider-percent').slider({
			ticks: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
			ticks_labels: ['0%', '10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%']
		});

		$(document).ready(function () {
			$('body').addClass('body-top');
		});

		// toggles on the contracts or bounties pages
		$('button.contract-type').click(function(e) {
			e.preventDefault();
			$(this).siblings().removeClass('active').attr('aria-pressed', '');
			switch($(this).attr('data-contract-type')) {
				case 'free':
					doFreeClick();
					break;
				case 'paid':
					doPaidClick();
					break;
			}
			$('form.wice_grid_form').submit();

			function doFreeClick() {
				var startTo = $("input[name='grid[f][price_in_cents][to]']").val();
				// check if they're undoing the free filter
				if (startTo === '0') {
					$("input[name='grid[f][price_in_cents][fr]']").val('');
					$("input[name='grid[f][price_in_cents][to]']").val('');
				}
				else {
					$("input[name='grid[f][price_in_cents][fr]']").val(0);
					$("input[name='grid[f][price_in_cents][to]']").val(0);
				}
			}

			function doPaidClick() {
				var startFrom = $("input[name='grid[f][price_in_cents][fr]']").val();
				// check if they're undoing the free filter
				if (startFrom > 0) {
					$("input[name='grid[f][price_in_cents][fr]']").val('');
					$("input[name='grid[f][price_in_cents][to]']").val('');
				}
				else {
					$("input[name='grid[f][price_in_cents][fr]']").val(5);
					$("input[name='grid[f][price_in_cents][to]']").val('');
				}
			}
		});
		if ($('[data-toggle="tooltip"]').length > 0) {
			$(function () {
				$('[data-toggle="tooltip"]').tooltip()
			})
		};
        if ($('[data-toggle="popover"]').length > 0) {
            $(function () {
                $('[data-toggle="popover"]').popover()
            })
        };

		$('#toggle-custom-avatar').on('change', function() {
			if ($(this).prop('checked')) {
				$('.default-avatar').fadeOut(300, function() {
					$('.custom-avatar').fadeIn(300);
				});
			} else {
				$('.custom-avatar').fadeOut(300, function() {
					$('.default-avatar').fadeIn(300);
				});
			}
		});

		$('.btn-facebook').click(function(){
			if ($(this).attr('data-event-id') != 'undefined' ) {
				var url = document.location.origin + '/events/' + $(this).attr('data-event-id');
				console.log(url);
			} else {
				var url = window.location.href;
	   		}
			FB.ui({
				method: 'share',
				href: url
		   }, function(response){});
			if ($('#btn-skip').length > 0) {
				$('#btn-skip').text('Done').removeClass('btn-primary').addClass('btn-success');
			}
		});

		$('.btn-twitter').click(function(event) {
			var url = $(this).attr('href');
		    var width  = 575,
		        height = 400,
		        left   = ($(window).width()  - width)  / 2,
		        top    = ($(window).height() - height) / 2,
		        opts   = 'status=1' +
		                 ',width='  + width  +
		                 ',height=' + height +
		                 ',top='    + top    +
		                 ',left='   + left;

		    window.open(url, 'twitter', opts);
		    if ($('#btn-skip').length > 0) {
				$('#btn-skip').text('Done').removeClass('btn-primary').addClass('btn-success');
			}

		    return false;
		  });

    // swap out players_age date filters with age
	if ($('#grid_f_users\\.date_of_birth_fr').length > 0) {
      $from = $('#grid_f_users\\.date_of_birth_fr').hide();
      $to = $('#grid_f_users\\.date_of_birth_to').hide();


      $('#grid_f_users_from_age')
      	.show()
        .insertAfter($from);

      $('#grid_f_users_to_age')
      	.show()
        .insertAfter($to);
    }

	};

	$(document).ready(ready);
	$(document).on('page:load', ready);
})();
