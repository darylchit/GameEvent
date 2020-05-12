$(document).ready(function() {
	if ($('.input-group-spinner').length > 0) {
		if ($('mdnzr-no-touchevents').length > 0) {
			$('.input-group-spinner input').prop('type', 'number');
		}
		$('.input-group-spinner input').after('<div class="input-group-addon"><button class="btn btn-default btn-block number-spinner-inc"><span class="fa fa-chevron-up"></span></button><button class="btn btn-default btn-block number-spinner-dec"><span class="fa fa-chevron-down"></span></button></div>')
	}

	// From https://css-tricks.com/number-increment-buttons/
	$(".input-group-spinner .btn").on("click", function(e) {
		e.preventDefault();
		var $btn = $(this),
			field = $btn.parent().parent().find("input")
			oldValue = field.val();

		if (field.attr('data-step') !== undefined ) {
			var step = parseFloat(field.attr('data-step'));
		} else {
			var step = 1;
		}

		if (field.attr('data-min') !== undefined ) {
			var min = parseFloat(field.attr('data-min'));
		} else {
			var min = 0;
		}

		if (oldValue == "") {
			curValue = 0;
		}
		else {
			curValue = oldValue;
		}
		
		if ($btn.hasClass('number-spinner-inc')) {
			var newVal = parseFloat(curValue) + step;
			if (field.attr('data-max') !== undefined && newVal > parseFloat(field.attr('data-max'))) {
				var newVal = parseFloat(field.attr('data-max'));
			}
			
		} else {
			// Don't allow decrementing below zero
			if (oldValue > min) {
				var newVal = parseFloat(curValue) - step;
			} else {
				newVal = min;
		}
		field.change(function() {
			if (parseFloat($(this).val()) < parseFloat($(this).attr('data-min')) ) {
				$(this).val(parseFloat($(this).attr('data-min')));
			}
		})
	}

	field.val(newVal).change();

	});

	$(".input-group-spinner input").change( function() {
		if ($(this).attr('data-step') !== undefined ) {
			var value = parseFloat($(this).val()),
				step = parseFloat($(this).attr('data-step'));
				
			$(this).val((value + (value % 5 == 0 ? 0 : (5 - (value %5)))));
		}

		if (parseFloat($(this).val()) < parseFloat($(this).attr('data-min')) ) {
			$(this).val(parseFloat($(this).attr('data-min')));
		}
		if (parseFloat($(this).val()) > parseFloat($(this).attr('data-max')) ) {
			$(this).val(parseFloat($(this).attr('data-max')));
		}


	});

	$(".input-group-spinner input").bind("keydown", function (event) {
		if ( event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 ||
			// Allow: Ctrl+A
			(event.keyCode == 65 && event.ctrlKey === true) || 

			// Allow: home, end, left, right
			(event.keyCode >= 35 && event.keyCode <= 39)) {
			// let it happen, don't do anything
			return;
		} else {
			// Ensure that it is a number and stop the keypress
			if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
				event.preventDefault();
			}
		}
	});
});
