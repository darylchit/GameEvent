$(document).ready(function() {
  // https://johnny.github.io/jquery-sortable/
  // Sortable rows

  function is_touch_device() {
    return 'ontouchstart' in window        // works on most browsers 
        || navigator.maxTouchPoints;       // works on IE10/11 and Surface
  };

  if (is_touch_device() === 0) {


    if ($('.sorted_table').length > 0 ) {
      var sortHeight = $('.sorted_table tbody tr').first().height(),
      sortWidth = $('.sorted_table').width();
    }

    $('.sorted_table').sortable({
      containerSelector: 'table',
      itemPath: '> tbody',
      itemSelector: 'tr',
      placeholder: '<tr class="placeholder"><td width="88px" class="avatar-col"><img class="avatar-sm" src=""></td><td class="roster-username">User</td><td class="roster-ign"></td><td class="roster-psa"></td><td class="roster-exp"></td><td class="contract-actions text-right-md"><span class="btn btn-default btn-sm"><span class="fa fa-arrows"></span></span></td></tr>',
      onDrag: function($item) {
        function getStars(psa) {
          if (psa == 0) {
            return "n/a";
          } else {
            var rating = '<span class="psa-rating-read-only" data-score="' + psa + '">';
            for (var star = 1; star <= 5; star++) {
              if (star <= psa) {
                rating += '<img alt="' + star + '" src="/assets/star-on.png">&nbsp;';
              } else {
                rating += '<img alt="' + star + '" src="/assets/star-off.png">&nbsp;';
              }
            }
            rating += '</span>';
            return rating;
          }
        }
        $('.placeholder .avatar-sm').attr('src', $item.find('.avatar-sm').attr('src'));
        $('.placeholder .roster-username').text($item.find('.roster-username a').text());
        $('.placeholder .roster-ign').html($item.find('.roster-ign a').text());
        $('.placeholder .roster-psa').html(getStars(parseFloat($item.find('.roster-psa').attr('data-psa'))));
        $('.placeholder .roster-exp').html($item.find('.roster-exp').text())
      },
      onDragStart: function ($item, container, _super) {
        oldIndex = $item.index();
        $item.addClass('hidden');
        //$item.appendTo($item.parent());
        _super($item, container);
      },
       onDrop: function ($item, container, _super) {
        newIndex = $item.index();
        $item.removeClass('hidden');
        if (newIndex != oldIndex) {
          // send the updated order via ajax
          $.ajax({
              type: "PUT",
              url: '/invites/'+$item.data('id')+'/update_position',
              data: { delta: oldIndex - newIndex  }
          });
        }
        _super($item, container);
      },
    });

    // Sortable column heads
    var oldIndex;
    $('.sorted_head tr').sortable({
      containerSelector: 'tr',
      itemSelector: 'th',
      placeholder: '<th class="placeholder"/>',
      vertical: false,
      onDragStart: function ($item, container, _super) {
        oldIndex = $item.index();
        $item.appendTo($item.parent());
        _super($item, container);
      },
      onDrop: function  ($item, container, _super) {
        var field,
            newIndex = $item.index();

        // TODO: Set the order inputs to represent the new orders of items in the table
        if(newIndex != oldIndex) {
          $item.closest('table').find('tbody tr').each(function (i, row) {
            row = $(row);
            if(newIndex < oldIndex) {
              row.children().eq(newIndex).before(row.children()[oldIndex]);
            } else if (newIndex > oldIndex) {
              row.children().eq(newIndex).after(row.children()[oldIndex]);
            }
          });
        }

        _super($item, container);
      }
    });
  } else {
    $('html').addClass('touch-en');
  }
});

$(document).ready(function() {

  $('.roster-users-table .collapse, .roster-users-table .collapsed').on('show.bs.collapse', function() {
    var target = $(this).attr('id');
    $('.roster-users-table .btn[data-target="#' + target + '"]').text('Close');
  });
  $('.roster-users-table .collapse, .roster-users-table .collapsed').on('hide.bs.collapse', function() {
    var target = $(this).attr('id');
    $('.roster-users-table .btn[data-target="#' + target + '"]').text('Rate');
  });


  $(document).on('click', 'button.invite-type', function(e) {
    e.preventDefault();
    $(this).siblings().removeClass('active').attr('aria-pressed', '');
      switch($(this).attr('data-invite-type')) {
        case 'favorites':
          doFavoritesClick();
          break;
        case 'all':
          doAllClick();
          break;
      }
       
      $('.roster_time_change').tooltip();
      function doFavoritesClick() {
        var searchAll = $("input[name='search_all_users']"),
            searchFave = $("input[name='search_favorites']");
        searchAll.prop('checked', false);
        $('.add_invitees_filter').submit();

      }

      function doAllClick() {
        var searchAll = $("input[name='search_all_users']"),
            searchFave = $("input[name='search_favorites']");
        searchAll.prop('checked', true);
        $('.add_invitees_filter').submit();
      }
    });

  // Merge our existing selected users and all the clan members
  function selectAllPlayers() {
    var arr = $('#roster_user_ids').val().split(/[ ,]+/).join(',').split(','),
      inviteesChecked = arr.slice();

    $.extend(inviteesChecked, members);

    $('#roster_user_ids').val(inviteesChecked);
    $('.invitees-grid input[type="checkbox"]').prop('checked', true);

    console.log(inviteesChecked);
  }

  $(document).on('click', '#add-all-players', function() {
    selectAllPlayers();
  });

  function rosterChecks() {
    var arr = $('#roster_user_ids').val().split(/[ ,]+/).join(',').split(','),
        inviteesChecked = arr.slice();

    $(document).on('change', '.invitees-grid input[type="checkbox"]', function() {
      // Reset our array
      var arr = $('#roster_user_ids').val().split(/[ ,]+/).join(',').split(','),
        inviteesChecked = arr.slice();

      var state = $(this).prop('checked'),
          val = $(this).val().toString();

          console.log($(this));

      if (state == true) {
        console.log('should be checked now');
          if ($.inArray(val, inviteesChecked) == -1) {
            console.log('is already in array');
            inviteesChecked.push(val);
            $('#roster_user_ids').val(inviteesChecked);
          }
      } else {
        console.log('should be unchecked');
          if ($.inArray(val, inviteesChecked) != -1) {
            inviteesChecked = $.grep(inviteesChecked, function(value) {
              return value != val ;
            });
            $('#roster_user_ids').val(inviteesChecked);
          }
      }
      $('#roster_user_ids').val(inviteesChecked);
    });
    $(document).on('click', '.modal-footer button', function () {
      $('.modal').modal('hide');
    });
  }

  // Check for a url hash
  var hash = document.location.hash;
  var prefix = "tab_";
  if (hash) {
      $('.nav-tabs a[href='+hash.replace(prefix,"")+']').tab('show');
  } 

  // Change hash for page-reload
  $('.nav-tabs a').on('shown', function (e) {
      window.location.hash = e.target.hash.replace("#", "#" + prefix);
  });

  if ($('#roster_user_ids').length > 0 ) {
    rosterChecks();
  }

});


$(document).on('change', '#clan-select-input', function() {
  setInviteParams();
});

// Rebuild the invite users link to add a clan param
function setInviteParams() {
  var selectedClan = $("option:selected", $('#clan-select-input')),
      btn = $('#add-invitees'),
      url = btn.attr('data-url');

  if (selectedClan.val() != '') {
    var linkParam = 'clan_id=' + selectedClan.val();

    btn.attr('href', url + '?' + linkParam);
  } 
}

/* ----- create roster ----- */
$(document).ready(function() {
    setInviteParams();
    toggleClan();
    if ($('#new_roster').length) {
        $('#event-type').change(function() {
            toggleClan();
        });
    }

    // evaluate form on submit
    $('#new_roster').submit(function() {
        var clan_input = $('#clan-select-input');
        // @TODO evaluate dropdown & if private val is selected.
        if (clanEventToggled() && $('option:selected', clan_input).val() == '') {
            clan_input.css('border', '2px solid red');
            var label = $('#clan-select-container label');
            label.text('Please Select a Clan');
            label.css('color', 'red');
            // scroll back up to clan select so user can see error
            $(window).scrollTop($('#clan-select-container').offset().top);
            return false;
        }
    });
});

function clanEventToggled() {
    // values of possible options
    var _clan = 0;
    var types = $('#event-type');
    var sel   = $('option:selected', types);

    console.log('clanevent toggled?', $(sel).val());

    return $(sel).val() == _clan ? true : false;
}

function publicToggled() {


    var _pub  = 2;
    var types = $('#event-type');
    var sel   = $('option:selected', types);
    console.log('public toggled?', $(sel).val());

    return $(sel).val() == _pub ? true : false;
}

function toggleClan() {
    var clan_container = $('#clan-select-container');

    var clan_input     = $('#clan-select-input');
    var size           = $('#roster_max_roster_size');
    var invites        = $('#add-invitees');
    var header         = $('#new-roster-header');
    var _private       = $('#private-toggle');

    if ($('#clan_id').length && $('#clan_id').val() != '') {
        var id = $('#clan_id').val();
        $("#event-type option[value='0']").prop('selected', true);
        $("#clan-select-input option[value='" + id + "']").prop('selected', true);
    }

    if (clanEventToggled()) {
        /* show clan form elements */
        clan_container.show();
        if (!clan_input.hasClass("data-disabled")) {
          clan_input.removeProp('disabled')
        }

        // set private to true
        $(_private).val(true);

        size.val(16);
        header.text('CREATE CLAN ROSTER');

        $('.roster-clan-text').show();
        $('.roster-public-text').hide();
       
        // Rebuild the invite users link to add a clan param
        setInviteParams();

        /**
         * Clans = 0: disable clan 'mode' for form and prompt user
         * Clans = 1: automatically select that clan.
         */
        if ($('option', clan_input).length == 0) {
            $('option:selected', clan_input).text('Join a clan to create a clan event.');
            clan_input.css('background-color', 'grey');
            returnFromClan(clan_input, size, invites, header);
        }

        if ($('option', clan_input).length == 1) {
            $('#clan-select-input :nth-child(1)').prop('selected', true);
        }
    } else {
        $('.roster-clan-text').hide();
        $('.roster-public-text').show();

        /* hide clan form elements */
        $('#add-invitees').attr('href', $('#add-invitees').attr('data-url'));
        clan_container.hide();

        // set private value based on selection
        if (publicToggled()) {
            $(_private).val(false);
        } else {
            $(_private).val(true);
        }

        returnFromClan(clan_input, size, invites, header);
    }
}

function returnFromClan(clan_input, size, invites, header) {
    clan_input.prop('disabled', true);
    size.val(2);
    header.text('CREATE ROSTER');
}
