$(document).ready(function() {
    function compile_date(year, month, day) {
        var rdate = $('#compiled_release_date');
        var dstring = Date.parse([year, month, day].join(' '));
        var compiled = new Date(dstring);

        rdate.val(compiled);
    }

    if ($('#compiled_release_date').length) {
        $('form').submit(function() {
            var month = $('#game_release_month').val();
            var day = $('#game_release_day').val();
            var year = $('#game_release_year').val();

            compile_date(year, month, day);
        });
    }
});
