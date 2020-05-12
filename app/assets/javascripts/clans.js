Clans = {}
Clans.CustomLinks = {
  addFields: function(){
    var count = $('.row.link:visible').length;
    if(count < 4){
      num = new Date().getTime();
      var element = '<div class="row link" id="remove_'+num+'"> <div class="col-md-4"> <div class="form-group"> <label for="clan_links_attributes_'+num+'_name">Name</label> <input type="text" id="clan_links_attributes_'+num+'_name" name="clan[links_attributes]['+num+'][name]" placeholder="Link Name" class="form-control"> </div> </div> <div class="col-md-7"> <div class="form-group"> <label for="clan_links_attributes_'+num+'_url">URL</label> <input type="text" id="clan_links_attributes_'+num+'_url" name="clan[links_attributes]['+num+'][url]" placeholder="URL" class="form-control"> </div> </div> <div class="col-md-1 remove_link set_close_btn" id="rm_btn_'+num+'"> <input class="show_link" type="hidden" value="false" name="clan[links_attributes]['+num+'][_destroy]" id="clan_links_attributes_'+num+'__destroy"> <i class="fa fa-times set_curson_pointer"></i></div></div>';
      $('.custom_links').append(element);
    }
  },
  removeFields: function(element){

    $(element).find( ".show_link" ).val("true");
    $(element).find( ".show_link" ).removeAttr('class');
    $(element).hide();
  },
  bindOnClickOnAddLink: function(){
    $('.link_add_button').on('click', function(){
      Clans.CustomLinks.addFields();
    });
  },
  bindOnClickOnRemoveLink: function(){
    $('body').on('click', '.remove_link', function(){
      Clans.CustomLinks.removeFields($(this).closest('.row.link'));
    })
  },
};

Clans.VideoUrl = {
  addFields: function(){
    var count = $('.row.video:visible').length;
    if(count < 10){
      num = new Date().getTime();
      var element = '<div class="row video"><div class="col-md-4"> <div class="form-group"> <label for="clan_video_urls_attributes_'+num+'_name">Video Name</label>            <input class="form-control" placeholder="Video Name" type="text" value="" name="clan[video_urls_attributes]['+num+'][name]" id="clan_video_urls_attributes_4_name"></div></div> <div class="col-md-7"> <div class="form-group"> <label for="clan_video_urls_attributes_'+num+'_url">Video URL</label> <input class="form-control" placeholder="Video URL" type="text" name="clan[video_urls_attributes]['+num+'][url]" id="clan_video_urls_attributes_'+num+'_url"> </div> </div> <div class="col-md-1 set_close_btn"> <div class="remove_video"> <input class="show_video" type="hidden" value="false" name="clan[video_urls_attributes]['+num+'][_destroy]" id="clan_video_urls_attributes_'+num+'__destroy"> <i class="fa fa-times set_curson_pointer"></i> </div> </div> </div>';
      $('.video_url').append(element);
    }
  },
  removeFields: function(element){
    $(element).find( ".show_video" ).val("true");
    $(element).find( ".show_video" ).removeAttr('class');
    $(element).hide();
  },
  bindOnClickOnAddLink: function(){
    $('.video_add_button').on('click', function(){
      Clans.VideoUrl.addFields();
    });
  },
  bindOnClickOnRemoveLink: function(){
    $('body').on('click', '.remove_video', function(){
      Clans.VideoUrl.removeFields($(this).closest('.row.video'));
    })
  },
}
Clans.Question = {
  addFields: function(){
    new_id = new Date().getTime();
    var element = '<div class="row questions"> <div class="col-md-11"> <div class="form-group"> <label for="clan_questions_attributes_'+new_id+'_name">Question</label> <input class="form-control" placeholder="Question" type="text" name="clan[questions_attributes]['+new_id+'][name]" id="clan_questions_attributes_'+new_id+'_name"> </div> </div> <div class="col-md-1 set_close_btn"> <div class="remove_question"> <input class="show_question" type="hidden" value="false" name="clan[questions_attributes]['+new_id+'][_destroy]" id="clan_questions_attributes_'+new_id+'__destroy"> <i class="fa fa-times set_curson_pointer"></i></div></div></div>';
    $('.clan_questions').append(element);
  },
  removeFields: function(element){
    $(element).find( ".question_destroy" ).val("true");
    $(element).find( ".question_destroy" ).removeAttr('class');
    $(element).hide();
  },
  bindOnClickOnAddQuestion: function(){
    $('.question_add_button').on('click', function(){
      Clans.Question.addFields();
    });
  },
  bindOnClickOnRemoveQuestion: function(){
    $('body').on('click', '.remove_question', function(){
      Clans.Question.removeFields($(this).closest('.row.questions'));
    })
  }
}

Clans.Validation = {
  setCharLimit: function(element_selector, limit){
    $(element_selector).on('keyup keypress change', function(event){
      if($(this).val().length > 40){
        event.preventDefault();
      }else{

      }
    });
  },
  validateMotto: function(){
    this.setCharLimit('#clan_motto', 40);
  },
  ValidateClanApplication: function(){
    if($('#new_clan_application').length == 0) return;
    var url = $('#new_clan_application').attr('action');
    $("#new_clan_application").validate({
      submit: {
        callback: {
          onSubmit:function(){
            $.post(url,$("#new_clan_application").serialize(),function(){},"script")
          }
        }
      }
    });
  },
  ValidationClanRestrictedPopup: function(){
    if($('#restricted_popup_form').length == 0) return;
    var url = $('#restricted_popup_form').attr('action');
    $("#restricted_popup_form").validate({
      submit: {
        callback: {
          onSubmit:function(){
            $.post(url,$("#restricted_popup_form").serialize(),function(){},"script")
          }
        }
      }
    });
  }
}

Clans.AnnualDues = {
  bindChangeOnAnnualDues: function(){
    $('#clan_annual_dues').on('change', function(event){
        if($(this).val() == '0' || $(this).val() == '1')
        {
          $('.annual_dues_amount').addClass('hide');
        }
        else{
          $('.annual_dues_amount').removeClass('hide');
        }
    })
  }
}
Clans.MemberRank = {
  bindChangeOnClanRank: function(){
    $('.clan_member_rank_select').on('change', function(event){
      var  clan_member = $(this).data('id');
      var clan = $(this).data('clan')
      var  clan_rank = $(this).val();
      $.ajax({
        method: "PATCH",
        url: "/clans/"+clan+"/clan_members/"+clan_member,
        data: { clan_member: {clan_rank_id: clan_rank} }
      })

    })
  }
}

Clans.MemberUnblock = {
  bindOnClickOnUnblock: function(){
    $('.clan_member_unblock').on('click', function(event){
      clan = $(this).data('clan');
      clan_member = $(this).data('id');
      $.ajax({
        method: "PATCH",
        url: "/clans/"+clan+"/unblock_member/"+clan_member
      })
      $(this).parent().parent().remove();
    })
  }
}

Clans.MemberRemove = {
  bindOnClickRemove: function(){
    $('.clan_member_remove').on('click', function(event){
      clan = $(this).data('clan');
      clan_member = $(this).data('id');
      $.ajax({
        method: "DELETE",
        url: "/clans/"+clan+"/remove_member/"+clan_member
      })
      $(this).parent().parent().remove();
    })
  }
}

Clans.ClickRedirect = {
  onTabClickRedirect: function(){
    // $('.clan_tabs').click(function(){
    //     if(screen.width >= 992){
    //       $('html, body').animate({
    //           // scrollTop: $(".clan-header.set-padding-clan-name").offset().top
    //           scrollTop: $(".clan-header.set-padding-clan-name").offset().top - 150
    //       }, 1000);
    //     } else if(screen.width >= 768 && screen.width <= 991){
    //       $('html, body').animate({
    //           // scrollTop: $(".clan-header.set-padding-clan-name").offset().top
    //           scrollTop: $(".clan-header.set-padding-clan-name").offset().top - 200
    //       }, 1000);
    //     } else  {
    //       $('html, body').animate({
    //           // scrollTop: $(".clan-header.set-padding-clan-name").offset().top
    //           scrollTop: $(".clan-header.set-padding-clan-name").offset().top - 200
    //       }, 1000);
    //     }
    // });
  }
}

Clans.OnScroll = {
  OnScrollTabSticky: function(){
    $(document).ready(function(){
      var isSet = false;
        $(window).bind('scroll', function() {

            if(screen.width >= 992){
              var navHeight = $("#box1").height() - 60 ;
               if (screen.width >=1900){ var scrollvalue = 700 } else { var scrollvalue = 450}
                if($(window).scrollTop() > scrollvalue && isSet == false){
                  // console.log('1111111',$(window).scrollTop());
                  isSet = true;
                  $('.tab_icons').addClass('fixed_menu');
                  $('#image_cover').addClass('set_img_position');
                  // $('#image_cover_mobile').addClass('set_img_position');
                  $('.top_margin').addClass('set_top_margin_content');
                  $('.set_margin_hidden').addClass('hide_content_tabs');

                } else if($(window).scrollTop() < scrollvalue && isSet == true) {
                  isSet = false;
                  // console.log('2222222',$(window).scrollTop());
                  $('.tab_icons').removeClass('fixed_menu');
                  $('#image_cover').removeClass('set_img_position');
                  // $('#image_cover_mobile').removeClass('set_img_position');
                  $('.top_margin').removeClass('set_top_margin_content');
                  $('.set_margin_hidden').removeClass('hide_content_tabs');

                 }
              } else if(screen.width >= 768 && screen.width <= 991){
                if($(window).scrollTop() > 300 && isSet == false){
                  // console.log('1111111',$(window).scrollTop());
                  isSet = true;
                  $('.tab_icons').addClass('fixed_menu');
                  $('#image_cover').addClass('set_img_position');
                  // $('#image_cover_mobile').addClass('set_img_position');
                  $('.top_margin').addClass('set_top_margin_content');
                  $('.set_margin_hidden').addClass('hide_content_tabs');

                } else if($(window).scrollTop() < 300 && isSet == true) {
                  isSet = false;
                  // console.log('2222222',$(window).scrollTop());
                  $('.tab_icons').removeClass('fixed_menu');
                  $('#image_cover').removeClass('set_img_position');
                  // $('#image_cover_mobile').removeClass('set_img_position');
                  $('.top_margin').removeClass('set_top_margin_content');
                  $('.set_margin_hidden').removeClass('hide_content_tabs');

                 }
              } else {
                $('.tab_icons').removeClass('fixed_menu');
                $('#image_cover').removeClass('set_img_position');{
                $('#image_cover_mobile').removeClass('set_img_position');
                $('.top_margin').removeClass('set_top_margin_content');}
                $('.set_margin_hidden').removeClass('hide_content_tabs');

                var navHeight = $("#box1").height() - 20;
                if($(window).scrollTop() > navHeight){
                  $('.tab_icons').addClass('fixed_menu');
                  $('#image_cover').addClass('set_img_position');
                  $('#image_cover_mobile').addClass('set_img_position');
                  $('.top_margin').addClass('set_top_margin_content');
                  $('.set_margin_hidden').addClass('hide_content_tabs');
                } else {
                  $('.tab_icons').removeClass('fixed_menu');
                  $('#image_cover').removeClass('set_img_position');
                  $('#image_cover_mobile').removeClass('set_img_position');
                  $('.top_margin').removeClass('set_top_margin_content');
                  $('.set_margin_hidden').removeClass('hide_content_tabs');
                 }
              }
        });
    });
  },
  OnAdaptiveScroll: function(){
    $(document).ready(function() {
      if ($('.pagination').length > 0 && $('#clans-list').length > 0 ) {
        $(window).scroll(function() {
          var url = $('.pagination .next a').attr('href');
          if (url && $(window).scrollTop() > $(document).height() / 50) {
            $('.pagination').html('');
            return $.getScript(url);
            }
        });
        return $(window).scroll();
      }
    });
  }
}

Clans.OnTabClickActive = {
  OnTabClickActiveClass: function(){
    $('#banned_user').on('click', function(){
       $('.right').find('.active').removeClass('active');
       $('#banned_user').addClass('active');
    });

    $('#pending_app').on('click', function(){
       $('.right').find('.active').removeClass('active');
       $('#pending_app').addClass('active');
    });
  }
}

Clans.OnTabNewSticky = {
  OnTabNewStickyActive: function(){
    $(window).bind('scroll', function() {
      var box_height = $('.set_box').height();
      var tab_height = $('.tab_icons').height();
      var total_height = box_height+tab_height;
      $('.box_height').css({'height': box_height});
      // $('.tab_icons').css({"margin-top" : box_height});
      $('.affix_div').affix({
          offset: {
              top: box_height
          }
      });
    });
  }
}


Clans.EventsOnScroll = {
  OnAdaptiveScroll: function(){
    $(document).ready(function() {
      if ( ($('.pagination').length > 0) && ( ($('#upcoming_clan_event_desktop').length > 0 ) ))
			{
        $(window).scroll(function() {

          var pre_url = $('.pagination .next a').attr('href');
          var page = pre_url.split("?")[1]
          var uri = pre_url.split("?")[0]
          var url = uri + "/get_more_clan_events_on_scrolling?" + page ;
          // if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 50) {
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
Clans.CopyText = {
	onClickOnCopyDetails: function(){
		toastr.options = {
        "closeButton": true,
        "timeOut": "7000",
        "extendedTimeOut": "0",
        "positionClass": "toast-top-center"
    };
    var clip  = new Clipboard('.clan-clipboard-btn', {
      container: document.getElementById('clan-details-share-id')
    });
    clip.on("success", function() {
      toastr.success("Clan Details Copied");
    });
    clip.on("error", function() {
      console.log('Clan Details Not Copied');
    });
	}
}
Clans.CopyTwitchURL = {
  bindonClickCopyTwitchLink: function(){
    var clipboard = new Clipboard('.twitch-clan-clipboard-btn');
		$('.twitch-clan-clipboard-btn').on('click', function(){
			toastr.options = {
	        "closeButton": true,
	        "timeOut": "7000",
	        "extendedTimeOut": "0",
	        "positionClass": "toast-top-center"
	    };
			toastr.success("Link Copied");
		})
  }
}

RecurringEvent = {}

RecurringEvent.Create = {
  bindDateTime: function () {
    $('#recurring_event_form #recurring_event_start_time').mobiscroll().time({
        theme: 'ios',
        display: 'bottom',
        headerText: false,
        maxWidth: 90
    });
  },
  bindFormSubmit: function(){
    var url = $('#recurring_event_form').attr('action');
    $("#recurring_event_form").validate({
      submit: {
        callback: {
          onSubmit:function(){
            $('#recurring_event_form button').attr('disabled', true)
            $.post(url, $("#recurring_event_form").serialize(),function(){},"script");
          },
          onError: function (node, globalError) {
              console.log('validation error');
          }
        }
      }
    });
  },
  ign_pc: function(){
    $('#recurring_event_game_game_system_join_id').change(function(){

      $('.ign-field-recurring-event').addClass('hide');
      $('.ign-field-recurring-event #recurring_event_pc_type').val('');

      var system = $(this).find('option:selected').attr('class');
      console.log(system);
      if (system == 'Steam') {
        $('.ign-field-recurring-event #recurring_event_pc_type').val('steam');
      }else if (system == 'Origin') {
        $('.ign-field-recurring-event #recurring_event_pc_type').val('origin');
      }else if (system == 'Battletag') {
        $('.ign-field-recurring-event #recurring_event_pc_type').val('battletag');
      }

    })
  }
}

$(document).ready(function(){
  //Twitch copy link
  Clans.CopyTwitchURL.bindonClickCopyTwitchLink();

  //For Link Url
  Clans.CustomLinks.bindOnClickOnAddLink();
  Clans.CustomLinks.bindOnClickOnRemoveLink();

  //For video Url
  Clans.VideoUrl.bindOnClickOnAddLink();
  Clans.VideoUrl.bindOnClickOnRemoveLink();

  // For Question
  Clans.Question.bindOnClickOnAddQuestion();
  Clans.Question.bindOnClickOnRemoveQuestion();

  //For Motto Validation
  Clans.Validation.validateMotto();

  //For AnnualDues
  //Clans.AnnualDues.bindChangeOnAnnualDues();

  //Fro Clan members
  Clans.MemberRank.bindChangeOnClanRank();
  // Clans.MemberUnblock.bindOnClickOnUnblock();
  Clans.MemberRemove.bindOnClickRemove();
  Clans.ClickRedirect.onTabClickRedirect();
  Clans.OnScroll.OnAdaptiveScroll();
  Clans.EventsOnScroll.OnAdaptiveScroll();
  // Clans.OnScroll.OnScrollTabSticky();
  Clans.OnTabClickActive.OnTabClickActiveClass();
  $("#clan-specs").addClass("in active");
  $('.new_clan_donation').validate();
  Clans.Validation.ValidateClanApplication();
  Clans.Validation.ValidationClanRestrictedPopup();
  Clans.OnTabNewSticky.OnTabNewStickyActive();
  // var box_height = $('.set_box').height();
  // $('.tab_icons').css({"margin-top" : box_height});

  $('.set_image_animation_box').mouseover(function(){
    $(this).find('.set_absolute').css({"display": "block"});
  });

  $('.set_image_animation_box').mouseleave(function(){
    $(this).find('.set_absolute').css({"display": "none"});
  });
  // $('li #clan-messages').on('click', function(){ $('.clan-messages.messages-list').scrollTop(5000); });

  RecurringEvent.Create.bindDateTime();
  RecurringEvent.Create.bindFormSubmit();
  RecurringEvent.Create.ign_pc();

});
