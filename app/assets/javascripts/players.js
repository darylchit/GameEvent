Players = {}
Players.Motto = {
  bindOnchange: function(){
    $('#mobile_user_motto').on('change', function(){
      $('#user_motto').val($(this).val());
    });
		$('#user_motto').on('change', function(){
      $('#mobile_user_motto').val($(this).val());
    });
  }
};

Players.VideoUrl = {
  addFields: function(){
    var count = $('.row.video:visible').length;
    if(count < 10){
      num = new Date().getTime();
      var element = '<div class="row video"><input class="user_video_destroy" type="hidden" value="false" name="user[video_urls_attributes]['+num+'][_destroy]" id="user_video_urls_attributes_'+num+'__destroy"><div class="col-md-4"><div class="form-group"><label for="user_video_urls_attributes_'+num+'_name">Video Name</label><div class="visible-xs pull-right"><div class="remove_user_video cursor_pointer"><i class="fa fa-times"></i></div></div><input class="form-control" placeholder="Video Name" type="text" name="user[video_urls_attributes]['+num+'][name]" id="user_video_urls_attributes_'+num+'_name"></div></div><div class="col-md-7"><div class="form-group"><label for="user_video_urls_attributes_'+num+'_url">Twitch or YouTube or Mixer URL</label><input class="form-control" placeholder="Mixer, Twitch, or YouTube URL" type="text" name="user[video_urls_attributes]['+num+'][url]" id="user_video_urls_attributes_'+num+'_url"></div></div><div class="col-md-1 hidden-xs"><div class="remove_user_video cursor_pointer"><i class="fa fa-times"></i></div></div></div>';
      $('.video_url').append(element);
    }
  },
  removeFields: function(element){
    $(element).find( ".user_video_destroy" ).val(true);
    $(element).find( ".user_video_destroy" ).removeAttr('class');
    $(element).hide();
  },
  bindOnClickOnAddLink: function(){
    $('.user_video_add_button').on('click', function(){
      Players.VideoUrl.addFields();
    });
  },
  bindOnClickOnRemoveLink: function(){
    $('body').on('click', '.remove_user_video', function(){
      Players.VideoUrl.removeFields($(this).closest('.row.video'));
    })
  },
}

Players.BuildProfile = {
  bindOnLocationClick: function(){
      $('.build_location_btn').on('click', function(){
          $('.build_profile_tabs').removeClass('active');
          $('.build_location_tab').addClass('active');
      })
  },
  bindOnActivityClick: function(){
      $('.build_activity_btn').on('click', function(){
          $('.build_profile_tabs').removeClass('active');
          $('.build_activity_tab').addClass('active');
      })
  },
  bindOnInformationClick: function(){
        $('.build_information_btn').on('click', function(){
            $('.build_profile_tabs').removeClass('active');
            $('.build_information_tab').addClass('active');
        })
  }
}

Players.OnScroll = {
  OnAdaptiveScroll: function(){
    $(document).ready(function() {
      if ($('.pagination').length > 0 && $('#players-list').length > 0 ) {
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

ContactUs = {};
ContactUs.Validation  = {
  validateForm: function(){
    if($('#contact_us_id').length > 0)
    {
      var url = $('#contact_us_id').attr('action');
      $('#contact_us_id').validate({
        submit: {
          callback: {
            onSubmit: function(){
              $.post(url,$("#contact_us_id").serialize(), function(){}, "script")
            }
          }
        }
      });
    }
  }
}
Players.OnPlusMenu = {
  OnPlusMenuOptions: function(){
    $(document).on('click', '.player-card .add-icon-top', function() {
      if ($(this).parent().hasClass('add-menu-show')){
          $('.add-menu-show').removeClass('add-menu-show');
        } else {
          $('.add-menu-show').removeClass('add-menu-show');
          $(this).parent().toggleClass('add-menu-show');
        }
    });
  }
}

Players.OnTabClick = {
  OnTabClickOpenSecondTab: function(){
    $('.second_tabs').hide();
    $('#first_tab').on('click', function(){
      $('.first_tabs').hide();
      $('.second_tabs').show();
      $(".tab-data").find('.fade.in.active').removeClass('in active');
      $('#player-games').addClass('fade in active');
      $('.second_tabs').find('li').removeClass('active');
      $('.game-page').addClass('active');
    });

    $('#second_tab').on('click', function(){
      $('.first_tabs').show();
      $('.second_tabs').hide();
      $(".tab-data").find('.fade.in.active').removeClass('in active');
      $('#player-about').addClass('fade in active');
      $('.first_tabs').find('li').removeClass('active');
      $('.about-page').addClass('active');
    });
  }
}

Players.SliderReload = {
    bindOnClickOnPreferenvcesTab: function(){
        $('#player_prefferences_tab').on('click', function(){
            setTimeout(function (){
                $('.input-slider-percent').slider("refresh")
            }, 1000);
        })
    }
}
Players.SkipOnRating = {
    bindOnClickOnSkipBtn: function () {
        $('.rating_skip').on('click', function(){
            $('#rating_form_'+($(this).data('id'))).fadeOut(500, function(){ $(this).remove();});
        })
    }
}

$(document).ready(function() {
	Players.Motto.bindOnchange();
  Players.VideoUrl.bindOnClickOnRemoveLink();
  Players.VideoUrl.bindOnClickOnAddLink();
  Players.BuildProfile.bindOnLocationClick();
  Players.BuildProfile.bindOnActivityClick();
  Players.BuildProfile.bindOnInformationClick();
  Players.OnScroll.OnAdaptiveScroll();
  Players.OnPlusMenu.OnPlusMenuOptions();
  //  default one box open
  Players.OnTabClick.OnTabClickOpenSecondTab();
  Players.SliderReload.bindOnClickOnPreferenvcesTab();
  Players.SkipOnRating.bindOnClickOnSkipBtn();
  $('.user_video_add_button').trigger('click')
});
