function debounce(func, wait, immediate) {
	var timeout;
	return function() {
		var context = this, args = arguments;
		var later = function() {
			timeout = null;
			if (!immediate) func.apply(context, args);
		};
		var callNow = immediate && !timeout;
		clearTimeout(timeout);
		timeout = setTimeout(later, wait);
		if (callNow) func.apply(context, args);
	};
};

var chosenResize = debounce(function() {
	$('.chosen-container').css('width', '100%')
}, 150);

var heroNavResize = debounce(function() {
	var viewH = $(window).height() - $('nav.navbar').outerHeight() - 44;
	if ($('.gm-hero-nav').width() < viewH) {
		$('.gm-hero-nav').height($('.gm-hero-nav').width()).css('background-position', '');
	} else {
		if (viewH > 380) {
			$('.gm-hero-nav').height(viewH).css('background-position', '50% 50%');
		} else {
			$('.gm-hero-nav').height('380px').css('background-position', '50% 50%');
		}
	}
}, 150);

var accountToggle = debounce(function() {
	if ($(window).width() > 1200) {
		$('.account-item').removeClass('pull-right-md');
		setTimeout(function() { $('.account-item').addClass('pull-right-md'); }, 120);
	}
}, 150);

$( document ).ready(function() {
	var viewH = $(window).height() - $('nav.navbar').outerHeight() - 44;
	if ($('.gm-hero-nav').width() < viewH) {
		$('.gm-hero-nav').height($('.gm-hero-nav').width()).css('background-position', '');
	}
	else {
		if (viewH > 380) {
			$('.gm-hero-nav').height(viewH).css('background-position', '50% 50%');
		} else {
			$('.gm-hero-nav').height('380px').css('background-position', '50% 50%');
		}
	}
});

var sideNavToggle = debounce(function() {
	if ($(window).width() < 961) {
		$('.expand-sidenav-toggle a').addClass('collapsed');
		$('.expand-sidenav .collapse.in').removeClass('in').addClass('collapsed');
	}
	else {
		if ($('.expand-sidenav-toggle a.collapsed').length > 0) {
			$('.expand-sidenav-toggle a').removeClass('collapsed');
			$('.expand-sidenav .collapse').addClass('in').removeClass('collapsed');
		}
		else {

		}
	}
});

var circularContent = debounce(function() {
	$.each($('.circular-content'), function() {
		$(this).height($(this).width())
	});
}, 100);

window.addEventListener('resize', chosenResize);
window.addEventListener('resize', heroNavResize);
window.addEventListener('resize', accountToggle);
window.addEventListener('resize', circularContent);
//window.addEventListener('resize', sideNavToggle);

var cachedWidth = $(window).width();
$(window).resize(function(){
    var newWidth = $(window).width();
    if(newWidth !== cachedWidth){
        sideNavToggle;
        cachedWidth = newWidth;
    }
});

$(document).ready(circularContent);

$(document).on('change', '.btn-file :file', function(event) {
    var input = $(this),
        numFiles = input.get(0).files ? input.get(0).files.length : 1,
        label = input.val().replace(/\\/g, '/').replace(/.*\//, ''),
        labelText = input.parent().find($('.file-label'));

    input.trigger('fileselect', [numFiles, label]);
    labelText.text(label);
});


$(document).ready(function() {
	$('#a-expand-sidenav-toggle').on('click', function(e){e.preventDefault();});

	if ($(window).width() < 961) {
		$('.expand-sidenav-toggle a').addClass('collapsed');
		$('.expand-sidenav .collapse.in').removeClass('in').addClass('collapsed');
	}

	configurePriceSwitch('contract');
	configurePriceSwitch('bounty');
	function configurePriceSwitch(type) {
		var id = '#' + type + '_price_in_dollars';
		if ($(id).length === 0) return;
		var $help_text = $('.hidden-help');
		if (!$help_text || $help_text.lenght == 0 || !$help_text.hasClass('help-text')) $help_text = false;
		if ($(id).val() > 0) {
	    	$('#toggle-paid').attr('checked', 'checked');
	    }
	    else {
	        $(id).css('opacity', '0');
			if ($help_text) $help_text.css('opacity', '0');
	    }

	    //show hide logic
	    $('#toggle-paid').change(function() {
	        if($(this).is(":checked")) {
	        	$(id).val('');
	        	$(id).css('opacity', '1');
				if ($help_text) $help_text.css('opacity', '1');
	        }
	        else {
	        	$(id).val('0');
	        	$(id).css('opacity', '0');
				if ($help_text) $help_text.css('opacity', '0');
	        }
	    });
	}

	$('#collapseRatings .psa-rating').each(function () {
		// Set the initial value
		$(this).attr('data-score', $(this).siblings('.hidden').find('input').first().val());

		$(this).siblings('.hidden').find('input').last().val('5');
        $(this).raty({
            score: function () {
                return $(this).attr('data-score');
            },
            targetScore: $(this).parent().find('.range-start').first()
        });
    });

    $('.roster-rating form .psa-rating, .edit_rating .psa-rating, .new_rating .psa-rating').each(function () {
		// Set the initial value
		$(this).attr('data-score', $(this).siblings('input').first().val());

        $(this).raty({
            score: function () {
                return $(this).attr('data-score');
            },
            targetScore: $(this).siblings('input').first()
        });
    });

	if ($('.max-characters').length > 0) {

		$.each($('.max-characters'), function() {
			var maxLength = parseFloat($(this).attr('data-max-num'));
			var textArea = $(this).find('textarea');
			var targetText = $(this).find('.remaining-characters')
			var length = textArea.val().length;
			var length = maxLength-length;
			targetText.text(length);

			textArea.keyup(function() {
				var length = $(this).val().length;
				var length = maxLength-length;
				targetText.text(length);
			});

		})
	}

	var toggle_user_membership = function() {
		var toggle = $('#toggle-lifetime'),
			expiration = toggle.attr('data-expiration');
		if (expiration == '') {
			var now = new Date();
				now.setDate(now.getDate()+30);
			var d = now.getDate(),
				m = now.getMonth();
				m += 1;
				y = now.getFullYear();
		}

		if (expiration) {
			if (toggle.prop('checked') == true) {
				$('.expiration-field input').val('');
			} else {
				$('.expiration-field input').val(expiration);
			}
		} else {
			if (toggle.prop('checked') == true) {
				$('.expiration-field input').val('');
			} else {
				$('.expiration-field input').val(m + '/' + d + '/' + y);
			}
		}
	}

	$('#toggle-lifetime').on('click', function(e) {
		toggle_user_membership();
	});

  var toggle_event_form =  function() {
		var checked = $('.contract-toggle-type input:checked').val().toLowerCase(),
			unchecked = $('.contract-toggle-type input:not(:checked)').val().toLowerCase();

		$('.show-' + unchecked).hide();
		$('.show-' + checked).fadeIn();

		if ($('.contract-toggle-type input[value="Bounty"]:checked').length > 0 && $('.time-slot').length > 0) {
			$('.time-slot').remove();
			$('.duration').show();
			$('.start-date-time').show();
			$('.start-date-times').html('');
		}
	};


	if ($('.show-bounty').length > 0 ) {
    toggle_event_form();
		$('.contract-toggle-type input').change(toggle_event_form);
	}

	$('#new_contract').submit(function(){
		var formAction = $("#contract_contract_type_bounty").is(':checked') ? "/my-posted-bounties" : "/my-posted-events";
		$("#new_contract").attr("action", formAction);
	}); 

	$('#new_bounty').submit(function(){
		var formAction = $("#bounty_contract_type_bounty").is(':checked') ? "/my-posted-bounties" : "/my-posted-events";
		$("#new_bounty").attr("action", formAction);
	});

	$('.modal').on('hide.bs.modal', function() {
		$('.modal-body').scrollTop(0);
	});

	// var chosenSingle = function() {
	// 	var selected = $('.chosen-one-line').find($('.chosen-choices .search-choice'));
	// 	console.log(selected.length);
	// }

	// chosenSingle();

	$('.chosen-one-line select').on('chosen:ready', function() {
		var choices = $(this).parent().find($('.chosen-choices')),
			selected = choices.find($('.search-choice:not(.placeholder-choice)'));

		if (selected.length > 0) {
			if (selected.length > 1) { 
				var item = 'items'
			} else {
				var item = 'item'
			}
			choices.prepend('<li class="search-choice placeholder-choice"><span class="placeholder-amount">' + selected.length + '</span> ' + item + ' selected</li>')
		}
	});

	$('.chosen-one-line select').chosen().change(function() {
		var choices = $(this).parent().find($('.chosen-choices')),
			selected = choices.find($('.search-choice:not(.placeholder-choice)'));

		if ($('.placeholder-choice').length > 0) {
			$('.placeholder-amount').text(selected.length);
		} else {
			if (selected.length > 0) {
				if (selected.length > 1) { 
					var item = 'items'
				} else {
					var item = 'item'
				}
				choices.prepend('<li class="search-choice placeholder-choice"><span class="placeholder-amount">' + selected.length + '</span> ' + item + ' selected</li>')
		}
		}

	});



	// $('.chosen-one-line .chosen-container').on('change', function() {
	// 	var selected = $('.chosen-choices .search-choice');
	// 	console.log(selected.lengt)
	// });

})

$('.toggle-expanding').on('click', function(e) {
	e.preventDefault();
	$($(this).attr('data-expand-target')).slideToggle();
});


$(document).on('click', 'input[type="submit"].disabled', function(e) {
	e.preventDefault();
})
