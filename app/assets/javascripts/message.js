Message = {}


Message.DropDownOptions = {
	OnClickDropDown: function(){
		// $('.sub_menu').css({"display": 'none'});
		// $('#message_menu').css({"display": 'block'});
		$('#main_option').on('change', function(){
			// $('.sub_menu').css({"display": 'none'});
			// $('#message_menu').css({"display": 'block'});
			if($('#main_option').val() == 'User Messages'){
				// $('#message_menu').css({"display": 'block'});
				$('.messages').find('a').trigger('click');
			} else if($('#main_option').val() == 'Clan Messages'){
				// $('#clan_messages_menu').css({"display": 'block'});
				$('.clan_messages').find('a').trigger('click');
			} else if($('#main_option').val() == 'Event Invitations'){
				// $('#event_invitation_menu').css({"display": 'block'});
				$('.event_invitation').find('a').trigger('click');
			} else if($('#main_option').val() == 'Roster Notices'){
				// $('#roster_notice_menu').css({"display": 'block'});
				$('.event_notice').find('a').trigger('click');
			} else if($('#main_option').val() == 'Recently Deleted'){
				$('.recently_deleted').find('a').trigger('click');
			}
		});
	}
}

function HideShowButtons(){
	//  if ($('.checkbox_action:checked').length > 0){
  //   	$('.mark-btn').css({'display': 'block'});
	// 		$('.delete-btn').css({'display': 'block'});
  //   } else {
  //   	$('.mark-btn').css({'display': 'none'});
	// 		$('.delete-btn').css({'display': 'none'});
  //   }

}

Message.CheckBoxChangeEvent = {
	OnCheckBoxChanged: function(){
		// $('.mark-btn').css({'display': 'none'});
		// $('.delete-btn').css({'display': 'none'});

		$('.checkbox_action').change(function() {
	  	HideShowButtons();
	    if(this.checked == false){ //if this item is unchecked
	        $("#select_all_messages")[0].checked = false; //change "select all" checked status to false
	    }
	    //check "select all" if all checkbox items are checked
	    if ($('.checkbox_action:checked').length == $('.checkbox_action').length ){
	        $("#select_all_messages")[0].checked = true; //change "select all" checked status to true
	    }
	  });

	  $("#select_all_messages").on('click', function(){
	    var status = $(this).attr('aria-pressed') == 'false' ? true : false;			
	    $('.checkbox_action').each(function(){
	      // this.checked = status;
				$(this).prop('checked',status);

		  });
	  	HideShowButtons();
		});
	}
}

Message.DeleteSelectedReceipts = {
	OnClickDeleteSeleceted: function(){
		$('#delete_selected').on('click', function(){
			var receipts_ids = []
			$('.checkbox_action:checked').each(function(){
				receipts_ids.push($(this).attr('value'));
			});
		 $.ajax({
	      method: 'DELETE',
	      url: "/receipts/destroy_receipts",
	      dataType: 'script',
	      data: {
	        receipts_ids: receipts_ids
	      }
			});
		});
	}
}

Message.MardReadSelected = {
	OnClickMarkReadSelected: function(){
		$('#mark_read').on('click', function(){
			var receipts_ids = []
			$('.checkbox_action:checked').each(function(){
					receipts_ids.push($(this).attr('value'));
			});
			$.ajax({
				method: 'GET',
				url: '/receipts/mark_read',
				dataType: 'script',
				data: {
					receipts_ids: receipts_ids
				}
			});
		});
	}
}

Message.CompostFormValidation = {
	OnCompostFormValidation: function(){
    if($('#compose_favorite_user_form').length == 0) return;
    var url = $('#compose_favorite_user_form').attr('action');
    $("#compose_favorite_user_form").validate({
      submit: {
        callback: {
          onSubmit:function(){
            $.post(url,$("#compose_favorite_user_form").serialize(),function(){},"script")
          }
        }
      }
    });
  }
}

Message.ReplyMessagePopupForm = {
	OnReplyMessagePopupValidation: function(){
    if($('#new_reply').length == 0) return;
    var url = $('#new_reply').attr('action');
    $("#new_reply").validate({
      submit: {
        callback: {
          onSubmit:function(){
            $.post(url,$("#new_reply").serialize(),function(){},"script")
          }
        }
      }
    });
  }
}

Message.CheckBoxChangedFormSubmit = {
	OnCheckBoxChangedFormSubmit: function(){
		$('#preferences_edit_form_mobile .checkbox_li').on('change', function(){
			$('#preferences_edit_form_mobile').submit();
		});

		$('#preferences_edit_form_desktop .checkbox_li').on('change', function(){
			$('#preferences_edit_form_desktop').submit();
		});
	}
}

$(document).ready(function() {
	Message.DropDownOptions.OnClickDropDown();
	Message.CheckBoxChangeEvent.OnCheckBoxChanged();
	Message.DeleteSelectedReceipts.OnClickDeleteSeleceted();
	Message.MardReadSelected.OnClickMarkReadSelected();
	Message.CompostFormValidation.OnCompostFormValidation();
	Message.CheckBoxChangedFormSubmit.OnCheckBoxChangedFormSubmit();
});
