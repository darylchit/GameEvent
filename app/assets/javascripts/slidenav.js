$(document).on('ready', function() {
	function openNav() {
	    $(".slidenav").addClass('slidenav-open');
	    $(".toggle-slidenav").addClass('nav-open');
	}

	function closeNav() {
	    $(".slidenav").removeClass('slidenav-open');
	    $(".toggle-slidenav").removeClass('nav-open');
	}

	$('.toggle-slidenav').on('click', function() {
		if ($('.slidenav-open').length > 0) {
			closeNav();
		} else {
			openNav();
		}
	});
});