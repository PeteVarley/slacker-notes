var log = function(message) {
  var timestamp = (new Date()).toTimeString();
  console.log('[' + timestamp + ']  ' + message);
};


var createNoteOnSubmit = function() {
  $('.Note').on('submit', 'form[note_name="new_note"]', function(evt) {
    log("New Note form submitted");
    evt.preventDefault();

    var $newNoteForm = $(this);

    var actionPath = $newNoteForm.attr('action');
    var newNoteFormData = $(this).serialize();

    log("Sending POST request to " + actionPath);

    $.post(actionPath, newNoteFormData, function(NoteHTML) {
      log("Recieved responst from POST request to " + actionPath);

      log("Adding new Note element to list");
      $newNoteForm.parent('li').before(NoteHTML);

      $newNoteForm.get(0).reset();
    });
  });
};

var showEditNoteFormOnClick = function() {
  $('.note').on('click', '.js_edit_note', function(evt) {
    log("Show edit Note form link clicked");

    evt.preventDefault();

    var $NoteElem = $(this).parent('.note');
    var $editNoteForm = $NoteElem.siblings('form[name="edit_note"]');

    log("Hiding Note element and showing Note form");
    $NoteElem.addClass('hidden');
    $editNoteForm.removeClass('hidden');
  });
};

var updateNoteOnSubmit = function() {
  $('.note').on('submit', 'form[name="edit_note"]', function(evt) {
    log("Edit Note form submitted");

    evt.preventDefault();

    var $editNoteForm = $(this);

    var actionPath = $editNoteForm.attr('action');
    var editNoteFormData = $editNoteForm.serialize();

    var $NoteElem = $editNoteForm.siblings('.note')

    log("sending PUT request to " + actionPath);

    $.ajax({
      url: actionPath,
      type: 'PUT',
      data: editNoteFormData
    }).done(function(responseData) {
      log("Recieved response from PUT request to " + actionPath);

      var newNoteHTML = responseData;

      log("Hiding Note form and showing Note element");
      $NoteElem.removeClass('hidden');
      $editNoteForm.addClass('hidden');

      log("Replacing old Note info with updated info");
      $NoteElem.replaceWith(newNoteHTML);
    });
  });
};

var deleteNoteOnSubmit = function() {
  $('.notes').on('submit', 'form[name="delete_note"]', function(evt) {
    log("Edit Note form submitted");

    evt.preventDefault();

    var $deleteNoteForm = $(this);

    var actionPath = $deleteNoteForm.attr('action');
    var deleteNoteFormData = $deleteNoteForm.serialize();

    var $NoteContainerElem = $(this).closest('li');

    log("Sending DELETE request to " + actionPath);

    $.ajax({
      url: actionPath,
      type: 'DELETE',
      data: deleteNoteFormData
    }).done(function() {
      log("Recieved response from DELETE request to " + actionPath);

      log("Removing deleted Note element");
      $NoteContainerElem.remove();
    });
  });
};

$(document).ready(function() {
  createNoteOnSubmit();

  showEditNoteFormOnClick();
  updateNoteOnSubmit();

  deleteNoteOnSubmit();
});