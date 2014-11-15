// A utility function to log information to the console
var log = function(message) {
  var timestamp = (new Date()).toTimeString();
  console.log('[' + timestamp + ']  ' + message);
};

var deleteMessageOnSubmit = function() {
  $('.messages').on('submit', 'form[name="delete_message"]', function(evt) {
    log("Delete message form submitted");

    evt.preventDefault();

    var $deleteMessageForm = $(this);

    // Use the destination path defined in the form's 'action'
    // attribute, i.e. `/jobs/:job_id`
    var actionPath = $deleteMessageForm.attr('action');
    var deleteMessageFormData = $deleteMessageForm.serialize();

    // Grab the containing <li> element so that we can remove
    // it when the delete request completes
    var $jobContainerElem = $(this).closest('li');

    log("Sending DELETE request to " + actionPath);

    // Sending a DELETE request requires using the jQuery
    // .ajax() function and configuring the url, type,
    // data, and complete options
    $.ajax({
      url: actionPath,
      type: 'DELETE',
      data: deleteJobMessageData
    }).done(function() {
      log("Received response from DELETE request to " + actionPath);

      log("Removing deleted message element");
      $jobContainerElem.remove();
    });
  });
};

$(document).ready(function() {
  deleteMessageOnSubmit();
});
