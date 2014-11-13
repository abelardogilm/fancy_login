
class @RememberTokenConfirmationBox
  constructor: () ->
    @initFancybox()

  #initialize fancybox and attach click event on each link with class forgot-pass
  initFancybox: () ->

    $('.resend-email-link').fancybox({

      closeBtn: false,
      enableEscapeButton:true,

      padding:0,

      # Open/close methods are custom defined in shared...
      openMethod : 'dropIn',
      openSpeed : 300,
      closeMethod : 'dropOut',
      closeSpeed : 200

      fitToView: true, # images won't be scaled to fit to browser's height
      maxWidth: "500px", # images won't exceed the browser's width

      afterShow: () =>
        $("#remembertokenbox input").focus()
      href: '#remembertokenbox' }); #which div to show as fancybox

    $('.fancybox-notice').on 'click', '.resend-email-link', (e)=>
      @clear()
      $("#remembertokenbox input").val $("#login_form .email input").val()
      e.preventDefault();

    $('a.remembertokenbox-close').click (e)->
          e.preventDefault();
          $.fancybox.close();

    $("#remembertokenbox input").keyup (e)=>
      if e.keyCode == 27 # close dialog on <Esc>
        $.fancybox.close()
      @clearField e
    $('#remembertokenbox-form').submit (e) =>
      @formSubmit e

  clearField: (e)->
    $(e.target).parent().parent().removeClass('error')

  clear: () ->
    $('#remembertokenbox .email').removeClass('error')
    $('#remembertokenbox .help-inline').html('')
    $('#remembertokenbox input').val('')

  formSubmit: (e)->
    e.preventDefault()
    if window.LoginBox.blocked
      return
    form = $(e.target)

    email = form.find('.email input').val()
    if !@isEmailValid email
      form.find('.email').addClass('error')
      form.find('.email .help-inline').html('El email es incorrecto')
      $.fancybox.update()
      return false
    else
      form.find('.email').removeClass('error')
      form.find('.email .help-inline').html()
      $.fancybox.update()

    # send the request
    form.find('.other').removeClass('error')
    form.find("button").attr('disabled', 'disabled')
    window.LoginBox.block()
    $.ajax({
      url: form.data("url"),
      dataType: "JSONP",
      timeout: 20000,
      data: {user: {email: email}},

      # deals with unknown errors
      error: () =>
        # re-enable the send button after some unhandled error happened
        window.LoginBox.unblock()
        form.find('.other').addClass('error')
        form.find('.other .help-inline').html("Ocurrió un error, por favor vuelva a intentarlo")
        form.find("button").removeAttr('disabled');
        $.fancybox.update()

      # deals with known response types (included errors from server side)
      success: (json, textStatus, xOptions) =>
        # if there was some error, show it to the user and finish
        if json.status != 200
          window.LoginBox.unblock()
          form.find("button").removeAttr('disabled');
          form.find('.other').addClass('error')
          form.find('.other .help-inline').html('Dirección de email no registrada')
          $.fancybox.update()
          return
        window.ReloadPage()
    })

  isEmailValid: (emailAddress) ->
    pattern = new RegExp /// ^
                    [a-z0-9!#$%&'*+/=?^_`{|}~]+(?:[\.-][a-z0-9!#$%&'*+/=?^_`{|}~-]+)*
                    @
                    (?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9][a-z0-9-]*[a-z0-9]
                  $ ///i
    pattern.test emailAddress