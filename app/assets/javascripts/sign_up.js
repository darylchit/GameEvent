
SignUp = { };

SignUp.Validation = {
	ValidateSignUp: function(){
		 if($('#termsAgreed').length == 0) return;
		 var url = $('#user_sign_up').attr('action');
			$("#user_sign_up").validate({
				submit: {
					callback: {
						onSubmit:function(){
							console.log('sign up submit');
							$.post(url, $("#user_sign_up").serialize(),function(){},"script");
						}
					}
				}
			});
	},
  ValidateUserName: function(){
    $('#signup #user_username').on('change', function(){
      $.ajax({
        method: 'POST',
        url: "/check-user",
				dataType: 'script',
        data: {
          username: $(this).val()
				}
        // },
        // success: function(result){
        //   if (result){
        //     $("form#new_user").removeError(["user[username]"]);
        //   }  else {
        //     $("form#new_user").validate();
        //     $("form#new_user").addError({"user[username]": "This Username is taken"});
        //   }
				//
        // }
      })
    });
  },
  ValidateEmail: function() {
    $('#signup #user_email, #signup #user_email_confirmation').on('change', function(){
      var name = $(this).attr('name');
      $.ajax({
        method: 'POST',
        url: "/check-email",
				dataType: 'script',
        data: {
          email: $(this).val()
        // },
        // success: function(result){
        //   if (result){
        //     $("form#new_user").removeError(["user[email]"]);
        //     $("form#new_user").removeError(["user[email_confirmation]"]);
        //   } else {
        //     $("form#new_user").validate();
        //     if(name == 'user[email]'){
        //       $("form#new_user").addError({"user[email]": "This email is taken"});
        //     } else {
        //       $("form#new_user").addError({"user[email_confirmation]": "This email is taken."});
        //     }
        //   }
        }
      })
    });
  }
}

UserConfirmation = {};
UserConfirmation.Validation = {
	validateForm: function(){
		 if($('#confirmation_form').length > 0){
			var url = $('#confirmation_form').attr('action');
			$("#confirmation_form").validate({
				submit: {
					callback: {
						onSubmit:function(){
							$.post(url,$("#confirmation_form").serialize(),function(){},"script")
						}
					}
				}
			});
		 }
	}
}

ForgotPassword = {};
ForgotPassword.Validation  = {
	validateForm: function(){
		if($('#forgot_password_form').length > 0)
		{
			var url = $('#forgot_password_form').attr('action');
			$('#forgot_password_form').validate({
				submit: {
					callback: {
						onSubmit: function(){
							$.post(url,$("#forgot_password_form").serialize(), function(){}, "script")
						}
					}
				}
			});
		}
	}
}

$(document).ready(function(){
  SignUp.Validation.ValidateUserName();
	SignUp.Validation.ValidateEmail();
	SignUp.Validation.ValidateSignUp();
	UserConfirmation.Validation.validateForm();
	ForgotPassword.Validation.validateForm();
});
