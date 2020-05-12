(function($) {
    var ready = function() {
        $('#leave-feedback').on('click', function (e) {
            e.preventDefault();
            $(this).hide();
            $('#feedback-form').slideDown();
        });
        $('#feedback-form .psa-rating').each(function () {
            $(this).raty({
                score: function () {
                    return $(this).attr('data-score');
                },
                targetScore: $(this).siblings('input')
            });
        });
        $('.feedback-form .psa-rating').each(function () {
            $(this).raty({
                score: function () {
                    return $(this).attr('data-score');
                },
                targetScore: $(this).siblings('input')
            });
        });

        /*

        $('.feedback-form form').submit(function(e) {
            e.preventDefault();
            var type = $($(this).children('input[name=type]')[0]).val(),
                data = $(this).serialize(),
                url = $(this).attr('action'),
                $container = $($(this).parents('li')[0]),
                $submit = $($(this).children('input[type=submit]')[0]);

            $submit.attr('disabled', 'disabled');

            $.ajax({
                url: url,
                method: 'POST',
                data: data,
                success: function() {
                    $container.html('Event successfully rated.');
                },
                faillure: function() {
                    alert('An error occurred');
                    $ubmit.sttr('disabled', '');
                }
            })

        });

        */

        updateRatingStars();
    }

	$(document).ready(ready);
	$(document).on('page:load', ready);
})(jQuery);

function updateRatingStars() {
	$('.psa-rating-read-only').each(function () {
		$(this).raty({
			readOnly: true,
			score: function () {
				return $(this).attr('data-score');
			}
		});
	});
    $('.generosity-rating-read-only').each(function () {
        $(this).raty({
            readOnly: true,
            score: function () {
                return $(this).attr('data-score');
            }
        });
    });
}
