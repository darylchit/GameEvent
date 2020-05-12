Event = { }
Event.EventType = {

    bindGameSystemIGN: function(){
			$('#game_game_system_discord').change(function(){

        $('.ign-field-discord').addClass('hide');
        $('.ign-field-discord .ign').remove();
        $('.ign-field-discord .error-list').remove();
        $('.ign-field-discord #event_pc_type').val('');

        var system = $(this).find('option:selected').attr('class');

        if(system == 'NSW' || system == 'WU'){
          ign = $('.ign-field-discord #nintendo_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-discord').append("<label class='required ign' for='event_ign'>Nintendo ID</label><input class='form-control ign' type='text' name='event[nintendo_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-discord').removeClass('hide');
          }
        }else if (system == 'PS4' || system == 'PS3') {
          ign = $('.ign-field-discord #psn_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-discord').append("<label class='required ign' for='event_ign'>PSN Online ID</label><input class='form-control ign' type='text' name='event[psn_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-discord').removeClass('hide');
          }
        }else if (system == 'XB1' || system == 'XB360') {
          ign = $('.ign-field-discord #xbox_live_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-discord').append("<label class='required ign' for='event_ign'>Xbox Gamertag</label><input class='form-control ign' type='text' name='event[xbox_live_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-discord').removeClass('hide');
          }
        }else if (system == 'Steam') {
          $('.ign-field-discord #event_pc_type').val('steam');
          ign = $('.ign-field-discord #steam_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-discord').append("<label class='required ign' for='event_ign'>Steam ID</label><input class='form-control ign' type='text' name='event[steam_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-discord').removeClass('hide');
          }
        }else if (system == 'Origin') {
          $('.ign-field-discord #event_pc_type').val('origin');
          ign = $('.ign-field-discord #origins_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-discord').append("<label class='required ign' for='event_ign'>Origin ID</label><input class='form-control ign' type='text' name='event[origins_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-discord').removeClass('hide');
          }
        }else if (system == 'Battletag') {
          $('.ign-field-discord #event_pc_type').val('battletag');
          ign = $('.ign-field-discord #battle_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-discord').append("<label class='required ign' for='event_ign'>Battletag</label><input class='form-control ign' type='text' name='event[battle_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-discord').removeClass('hide');
          }
        }

			})
		},

    bindGameSystemIGNPOPUP: function(){
      $('#event_game_game_system_join_id').change(function(){

        $('.ign-field-event-popup').addClass('hide');
        $('.ign-field-event-popup .ign').remove();
        $('.ign-field-event-popup .error-list').remove();
        $('.ign-field-event-popup #event_pc_type').val('');

        var system = $(this).find('option:selected').attr('class');

        if(system == 'NSW' || system == 'WU'){
          ign = $('.ign-field-event-popup #nintendo_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-event-popup').append("<label class='required ign' for='event_ign'>Nintendo ID</label><input class='form-control ign' type='text' name='event[nintendo_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-event-popup').removeClass('hide');
          }
        }else if (system == 'PS4' || system == 'PS3') {
          ign = $('.ign-field-event-popup #psn_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-event-popup').append("<label class='required ign' for='event_ign'>PSN Online ID</label><input class='form-control ign' type='text' name='event[psn_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-event-popup').removeClass('hide');
          }
        }else if (system == 'XB1' || system == 'XB360') {
          ign = $('.ign-field-event-popup #xbox_live_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-event-popup').append("<label class='required ign' for='event_ign'>Xbox Gamertag</label><input class='form-control ign' type='text' name='event[xbox_live_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-event-popup').removeClass('hide');
          }
        }else if (system == 'Steam') {
          $('.ign-field-event-popup #event_pc_type').val('steam');
          ign = $('.ign-field-event-popup #steam_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-event-popup').append("<label class='required ign' for='event_ign'>Steam ID</label><input class='form-control ign' type='text' name='event[steam_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-event-popup').removeClass('hide');
          }
        }else if (system == 'Origin') {
          $('.ign-field-event-popup #event_pc_type').val('origin');
          ign = $('.ign-field-event-popup #origins_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-event-popup').append("<label class='required ign' for='event_ign'>Origin ID</label><input class='form-control ign' type='text' name='event[origins_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-event-popup').removeClass('hide');
          }
        }else if (system == 'Battletag') {
          $('.ign-field-event-popup #event_pc_type').val('battletag');
          ign = $('.ign-field-event-popup #battle_user_name').val();
          if($.trim(ign)==''){
            $('.ign-field-event-popup').append("<label class='required ign' for='event_ign'>Battletag</label><input class='form-control ign' type='text' name='event[battle_user_name]' data-validation='[NOTEMPTY]' data-validation-message='Required' id='event_ign'>");
            $('.ign-field-event-popup').removeClass('hide');
          }
        }

			})
    },

		bindChangeOnEventType: function () {
				$('#event_event_type').on('change', function(){
						$('.event-note').show();
						if($(this).val() == 'clan_event')
						{
                            $('#clan_select').removeClass('hide');
                            $('.event-note').addClass('hide');
						}
						else if($(this).val() == 'private_event'){
                            // $('.event-note').removeClass('hide');
                            $('#clan_select').addClass('hide');

						}
						else{
                            $('#clan_select').addClass('hide');
                            $('.event-note').addClass('hide');
						}
				})
		},
		bindDateTime: function () {
				// $('.date-time-picker').each(function () {
				// 		$(this).datetimepicker({
				// 				format: 'm/d/Y g:ia',
				// 				formatTime: 'g:ia'
				// 		});
				// });
        //     $("#event_model").scroll(function(){
        //         $(".xdsoft_datetimepicker").hide();
        //     });
				$('#event_start_at_popup, #event_start_at').mobiscroll().datetime({
            theme: 'ios',          // Specify theme like: theme: 'ios' or omit setting to use default
            lang: 'en',            // Specify language like: lang: 'pl' or omit setting to use default
            display: 'bottom',     // Specify display mode like: display: 'bottom' or omit setting to use default
            // min: minDate,          // More info about min: https://docs.mobiscroll.com/datetime#opt-min
            // max: maxDate,          // More info about max: https://docs.mobiscroll.com/datetime#opt-max
            dateWheels: '|D M d|',  // More info about dateWheels: https://docs.mobiscroll.com/datetime#localization-dateWheels
						focusTrap: false
        });

		},
		bind_invite_list: function(){
			$('.event-chosen-select').chosen();
		},
    bindFormSubmitDiscord: function(){
      var url = $('#event_form_discord').attr('action');
 			$("#event_form_discord").validate({
 				submit: {
 					callback: {
 						onSubmit:function(){
              $('#event_form_discord button').attr('disabled', true);
 							$.post(url, $("#event_form_discord").serialize(),function(){},"script");
 						},
            onError: function (node, globalError) {
                document.body.scrollTop = 0;
            }
 					}
 				}
 			});
    },
    bindFormSubmit: function(){
      var url = $('#event_form_popup').attr('action');
 			$("#event_form_popup").validate({
 				submit: {
 					callback: {
 						onSubmit:function(){
              $('#event_form_popup button').attr('disabled', true)
 							$.post(url, $("#event_form_popup").serialize(),function(){},"script");
 						},
            onError: function (node, globalError) {
                $("#event_model").animate({ scrollTop: 0 }, "fast");
            }
 					}
 				}
 			});
    },
		bindEventPopup: function () {

				// this function call all the funtion which is used in new event popup and edit event popup
            // Event.EventType.bindDateTime();
            Event.EventType.bindChangeOnEventType();
            Event.EventType.bindDateTime();
            Event.EventType.bindFormSubmit();
            Event.EventType.bindGameSystemIGNPOPUP();


						// $('#edit_profile_my_games').on('click', function(){
						// 	$('#event_model').hide();
						// 	$('.modal-backdrop').remove();
						// });
		}
}

Event.RosterChat = {
  OnSendMessage: function(){
    if($('#new_event_message').length == 0) return;
    var url = $('#new_event_message').attr('action');
    $('#new_event_message').validate({
      submit: {
        callback: {
          onSubmit: function(){
            $.post(url, $('#new_event_message').serialize(),function(){}, "script")
          }
        }
      }
    });
  }
}
Event.AdaptiveScroll = {
	onScrollMessage: function(){
		$(document).ready(function() {
      window_scroll = true
      if ($('.event_chat_view_more').length > 0 && $('#chat_event_messages').length > 0) {
        $(window).scroll(function(event) {
          var chat_open = $('#roster_chat').hasClass('in');
          var url = $('.event_chat_view_more').data('url');
          if ( chat_open && window_scroll && url && $(window).scrollTop() > $(document).height() - $(window).height() -5) {
            $('.event_chat_view_more').html('');
            window_scroll = false;

            return $.getScript(url);
            }
        });
        return $(window).scroll();
      }
    });
	}
}

Event.OnScroll = {
  OnAdaptiveScroll: function(){
    $(document).ready(function() {
      if ( ($('.pagination').length > 0) && ( ($('#public-games-list').length > 0 ) || ($('#public-games-list-mobile').length > 0) ))
			{
        $(window).scroll(function() {
          var url = $('.pagination .next a').attr('href');
          if (url && ($(window).scrollTop()) > ($(document).height()/2)) {
            $('.pagination').html('');
            return $.getScript(url);
          }
        });
        return $(window).scroll();
      }
    });
  }
}

Event.RedirectURL = {
  OnClickRedirectPath: function(){
    $('table tr.event_redirect, ul li.event_redirect, div.event_redirect').click(function () {
       window.location.href = $(this).data('link');
    });
  }
}


Event.OnMouseOver = {
  OnEventImageMouseOver: function(){
    if ($('#check_host').length == 1)
    {
      $('.set_game_img_width').mouseover(function(){
        $(this).find('.block_over').css({"display": "block"});
      });

      $('.set_game_img_width').mouseleave(function(){
        $(this).find('.block_over').css({"display": "none"});
      });
    }
  }
}
Event.MyEventSorting = {
  onEventSortChanged: function(){
    $('.my-all-event-sorting').change(function(){
        sort_order = $(this).val();
        var request = $.ajax({
            method: "GET",
            url: "/my_events/my_all_events",
            data: { sort_by: sort_order},
            dataType: "script"
        });
    })

  }
}
Event.CopyText = {
	onClickOnCopyDetails: function(token){
		toastr.options = {
        "closeButton": true,
        "timeOut": "7000",
        "extendedTimeOut": "0",
        "positionClass": "toast-top-center"
    };
    var clip  = new Clipboard('.event-clipboard-btn-'+token, {
      container: document.getElementById('event-copy-data-id')
    });
    clip.on("success", function(event) {
      toastr.success("Event Details Copied");
    });
    clip.on("error", function(event) {
      console.log('Event Details Not Copied');
    });
	}
}

Event.DiscordShare = {
	onClickOnContinueWithDiscord: function(){
    toastr.options = {
      "closeButton": true,
      "timeOut": "7000",
      "extendedTimeOut": "0",
      "positionClass": "toast-top-center"
    };
    var clip  = new Clipboard('.discord-clipboard-btn', {
      container: document.getElementById('discord_share_popup')
    });
    clip.on("success", function() {
      toastr.success("Event Details Copied");
    });
    clip.on("error", function() {
      console.log('Event Details Not Copied');
    });
	}
}

$(document).ready(function() {
  Event.EventType.bindGameSystemIGN();
	Event.EventType.bindChangeOnEventType();
	Event.EventType.bindDateTime();
  Event.EventType.bindFormSubmitDiscord();
	Event.EventType.bind_invite_list();
	Event.RosterChat.OnSendMessage();
	Event.AdaptiveScroll.onScrollMessage();
	Event.OnScroll.OnAdaptiveScroll();
  Event.RedirectURL.OnClickRedirectPath();
  Event.OnMouseOver.OnEventImageMouseOver();
  Event.MyEventSorting.onEventSortChanged();
	// Event.CopyText.onClickOnCopyDetails();
	// Event.DiscordShare.onClickOnContinueWithDiscord();
});
