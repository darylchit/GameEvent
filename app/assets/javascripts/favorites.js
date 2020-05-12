$(document).ready(function() {
  var favoritesChecked = [];
  $(document).on('change', '.favorites-grid input[type="checkbox"]', function() {

    favoritesChecked = [];
      $('.favorites-grid input[type="checkbox"]:checked').each(function ()
      {
        favoritesChecked.push(parseInt($(this).val()));
      });
      $('input[name="favorites-checked"]').val(favoritesChecked);
  });

});