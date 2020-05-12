(function() {
	var ready = function () {
		if ($('.grid_detached_filter select[multiple]').length > 0) {
			// Is it iOS?
			var iOS = /iPad|iPhone|iPod/.test(navigator.platform);
			if (iOS) {
				// Make our multiselects NOT multiselects since iOS autoselecting first option reloads page immediately
				// https://discussions.apple.com/thread/5548742?tstart=0
				$('.grid_detached_filter select[multiple]').removeAttr('multiple').addClass('form-control');
				$('.grid_detached_filter select').on('change', function() {
					$(this).closest('form').submit();
				});
			}
		}
	}
	$(document).ready(ready);
	$(document).on('page:load', ready);
})();