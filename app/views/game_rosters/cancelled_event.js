$('#global_model').html("<%= j render(:partial => 'cancelled_event_popup')%>")
$('.canceled_event_msg').html("This Event Has Been Cancelled. This Feature Is Not Accessible On This Roster");
$("#cancelled_popup").modal();
