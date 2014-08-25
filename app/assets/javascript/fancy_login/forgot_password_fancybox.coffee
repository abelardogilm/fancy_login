
# #
# Reset / Forgot password fancy box login
# #
class @ForgotPassBox
  constructor: () ->
    @initFancybox()

  #initialize fancybox and attach click event on each link with class forgot-pass
  initFancybox: () ->

    $('.forgot-pass').fancybox({

      closeBtn: false,
      enableEscapeButton:true,
      padding:0,
      openMethod : 'dropIn',
      openSpeed : 300,
      closeMethod : 'dropOut',
      closeSpeed : 200

      fitToView: true, # images won't be scaled to fit to browser's height
      maxWidth: "500px", # images won't exceed the browser's width

      afterShow: () =>
        $("#forgotpassbox input").focus()
      href: '#forgotpassbox' }); #which div to show as fancybox

    $('.forgot-pass').on "click", (e)=>
      @clear()
      $("#forgotpassbox input").val $("#login_form .email input").val()
      mixingpanel_tracker.track "Login", {"action":"reset password click", "location":"login fancybox", "url": document.URL }
      e.preventDefault();

    $('.js-close').click (e)->
      e.preventDefault();
      $.fancybox.close();

    # !!! Fancybox has on close callback and has ESC close option!!! WTF??? Read the docs!
    $("#forgotpassbox input").keyup (e)=>
      if e.keyCode == 27 # close dialog on <Esc>
        $.fancybox.close()
      @clearField e
    $('#forgotpassbox_form').submit (e) =>
      @formSubmit e

  clearField: (e)->
    $(e.target).parent().parent().removeClass('error')

  clear: () ->
    $('#forgotpassbox .email').removeClass('error')
    $('#forgotpassbox .help-inline').html('')
    $('#forgotpassbox input').val('')

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

      mixingpanel_tracker.track "Login", {"action":"reset password attemp", "location":"login fancybox", "url": document.URL }
      
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
          window.ReloadPage("reset-pass")
      })

  isEmailValid: (emailAddress) ->
    pattern = new RegExp /// ^
                    [a-z0-9!#$%&'*+/=?^_`{|}~]+(?:[\.-][a-z0-9!#$%&'*+/=?^_`{|}~-]+)*
                    @
                    (?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9][a-z0-9-]*[a-z0-9]
                  $ ///i
    pattern.test emailAddress








