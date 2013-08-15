$ ->
  tokenValue = $("meta[name='csrf-token']").attr("content")
  $.ajaxSetup headers:
    "X-CSRF-Token": tokenValue