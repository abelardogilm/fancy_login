class @LoginBox

  constructor: () ->
    @initFancybox()
    @target = null

  #Initialize fancybox and attach click event on each link with class not-logged-in
  initFancybox: () ->
    @show_into_fancybox()

    @attachSwitchLoginRegisterHandler()

    # Add tracking on signout link
    $(document).on "click", ".signout", (e) =>
      # Track mixpanel events for logout links
      if $(e.currentTarget).data("event")?
        mixingpanel_tracker.track $(e.currentTarget).data('event'),
                                  $(e.currentTarget).data('extraProps')

    #since .not-logged-in can be applied to a link or a button
    $(document).on "click", ".not-logged-in", (e) =>
      # Track mixpanel events for login links
      if $(e.currentTarget).data("event")?
        mixingpanel_tracker.track $(e.currentTarget).data('event'),
                                  $(e.currentTarget).data('extraProps')
      if @blocked
        return

      @target = $(e.target)
      e.preventDefault()
      @clear()

    $('a.loginbox-close').click (e) ->
      e.preventDefault();
      $.fancybox.close();

    $('a.btn-facebook').click (e) =>
      e.preventDefault()
      @clearFacebookError()

      FB.login (response) ->
          if response.authResponse
            $.ajax
              url: $(e.currentTarget).attr('href')
              dataType: "JSONP"
              timeout: 20000
              data: {}
              success: (json) ->
                window.processLogin()
              error: (request, status, error)->
                window.LoginBox.showFacebookError()
          else
            window.LoginBox.showFacebookError()
        ,scope: 'email'
      return false

    $('a.btn-google').click (e) =>
      e.preventDefault()
      @showFancyBoxMessage('¡Ups! Esta función no está disponible ahora. Puedes registrarte con Facebook o tu email.', true)
      return false

    $("#loginbox input").keyup (e) =>
      if e.keyCode == 27 # close dialog on <Esc>
        $.fancybox.close()
        return
      else if e.keyCode == 13 # don't clear error on <Enter>
        return
      @clearField e

    $('#login_form').submit (e) =>
      mixingpanel_tracker.track "Login", {"action":"signin", "location":"login fancybox", "url": document.URL }
      @formSubmit e, $('#login_form').data('url')

    $('#loginbox-sign-in .btn-facebook').click (e) =>
      mixingpanel_tracker.track "Login", {"action":"signin with facebook", "location":"login fancybox", "url": document.URL }

    $('#loginbox-sign-in .btn-google').click (e) =>
      mixingpanel_tracker.track "Login", {"action":"signin with google", "location":"login fancybox", "url": document.URL }

    $('#register_form').submit (e) =>
      @formSubmit e, $('#register_form').data("url")

    $('#loginbox-sign-up .btn-facebook').click (e) =>
      mixingpanel_tracker.track "Register", {"action":"register with facebook", "location":"login fancybox", "url": document.URL }

    $('#loginbox-sign-up .btn-google').click (e) =>
      mixingpanel_tracker.track "Register", {"action":"register with google", "location":"login fancybox", "url": document.URL }

  blocked: false,

  show_into_fancybox: () =>
    @clear()

    $('.not-logged-in').fancybox
      href: '#loginbox'
      closeBtn: false
      enableEscapeButton:true
      padding:0
      autoSize:false
      width: 330
      height: 'auto'
      autoHeight: true
      openMethod: 'dropIn'
      openSpeed: 300
      closeMethod: 'dropOut'
      closeSpeed: 200
      fitToView: true  # images won't be scaled to fit to browser's height
      maxWidth: "500px" # images won't exceed the browser's width
      helpers:
        title: null
      beforeShow: ()->
        if $(@element).hasClass('not-registered')
          $('#loginbox-header h5').text("Regístrate en #{$('#loginbox-header h5').data('appName')}")
          $("#loginbox-sign-in").css("display","none")
          $("#loginbox-sign-up").css("display","block")
        else
          $('#loginbox-header h5').text("Inicia sesión en #{$('#loginbox-header h5').data('appName')}")
          $("#loginbox-sign-up").css("display","none")
          $("#loginbox-sign-in").css("display","block")

  attachSwitchLoginRegisterHandler: ()->
    $(".js-switch-action").on "click", (e) =>
      @clearFancyBoxError()
      target = $(e.target).attr("href")
      if target is "#signup"
        $("#loginbox-sign-in").fadeOut ->
          $('#loginbox-header h5').text("Regístrate en #{$('#loginbox-header h5').data('appName')}")
          $("#loginbox-sign-up").fadeIn()
      else if target is "#signin"
        $("#loginbox-sign-up").fadeOut ->
          $('#loginbox-header h5').text("Inicia sesión en #{$('#loginbox-header h5').data('appName')}")
          $("#loginbox-sign-in").fadeIn()

  @block: =>
    @blocked = true

  @unblock: =>
    @blocked = false

  showFacebookError: ->
    @constructor.unblock()
    $('#loginbox .facebook-notice').addClass('error').html('No pudimos iniciar tu sesión con Facebook').show()
    $.fancybox.update()

  clearFacebookError: ->
    $('#loginbox .facebook-notice').removeClass('error').html('').hide()
    $.fancybox.update()

  showFancyBoxMessage: (message, error) ->
    @constructor.unblock()
    $('#loginbox .fancybox-notice').html(message)
    if error
      $('#loginbox .fancybox-notice').addClass('error')
    $('#loginbox .fancybox-notice').show()
    $.fancybox.update()

  clearFancyBoxError: ->
    $('#loginbox .fancybox-notice').removeClass('error').html('').hide()
    $.fancybox.update()

  # Login form submit VALIDATION SHOULD HAVE BEEN DONE USING jQVALIDATOR!!! :(
  # This form submit is used both for login and registration
  formSubmit: (e, url) =>
      e.preventDefault()
      if @constructor.blocked
        return false
      form = $(e.target)
      form_id = $(form).attr("id")

      has_errors = false
      email = form.find('.email input').val()
      if !@isEmailValid email
        form.find('.email').addClass('error')
        form.find('.email .help-inline').html('El email es incorrecto')
        has_errors = true
      else
        form.find('.email').removeClass('error')
        form.find('.email .help-inline').html()

      password = form.find('.password input').val()
      if password.length == 0
        form.find('.password').addClass('error')
        form.find('.password .help-inline').html('La contraseña es inválida (vacía)')
        has_errors = true
      else if password.length < 8 and form.attr('id') == 'register_form'
        form.find('.password').addClass('error')
        form.find('.password .help-inline').html('La contraseña es demasiado corta (8 caracteres mínimo)')
        has_errors = true
      else
        form.find('.password').removeClass('error')
        form.find('.password .help-inline').html()

      # Register form ask for terms and conditions
      if (form_id == "register_form")
        if ( $("#loginbox-terms-and-conditions").is(':checked') == false )

          # Track that T&C caused not sending the message
          # mixingpanel_tracker.track "Email Capture", {"action":"xxx", "location":"fancybox", "url": document.URL }
          form.find('#terms').addClass('error')
          form.find('#terms .help-inline').html('Por favor, acepta las condiciones')
          has_errors = true
        else
          form.find('#terms').removeClass('error')
          form.find('#terms .help-inline').html()

      if has_errors
        $.fancybox.update()
        
        if (form_id == "register_form")
          mixingpanel_tracker.track "Register", {"action":"register unsuccessful", "location":"login fancybox", "url": document.URL }
        else
          mixingpanel_tracker.track "Login", {"action":"signin unsuccessful", "location":"login fancybox", "url": document.URL }

        return false

      # send the request
      form.find('.other').removeClass('error')
      $.fancybox.update()
      form.find("button").attr('disabled', 'disabled')
      @constructor.block()
      $.ajax({
        url: url,
        dataType: "JSONP",
        timeout: 20000,
        data: {user: {email: email, password: password, "remember_me": true}},

        # deals with unknown errors
        error: () =>
          @constructor.unblock()
          # re-enable the send button after some unhandled error happened
          form.find('.other').addClass('error')
          form.find('.other .help-inline').html("Ocurrió un error, por favor vuelva a intentarlo")
          form.find("button").removeAttr('disabled')
          $.fancybox.update()

        # deals with known response types (included errors from server side)
        success: (json, textStatus, xOptions) =>

          # if there was some error, show it to the user and finish
          if json.status != 200

            # Track unsuccesful login / register
            if $(form).attr("id") == "login_form"
              mixingpanel_tracker.track "Login", {"action":"signin unsuccessful", "location":"login fancybox", "url": document.URL }
            else if $(form).attr("id") == "register_form"
              mixingpanel_tracker.track "Login", {"action":"register unsuccessful", "location":"login fancybox", "url": document.URL }

            @constructor.unblock()
            form.find("button").removeAttr('disabled')
            if json.user?.errors?.email
              form.find('.email').addClass('error')
              form.find('.email .help-inline').html(json.user.errors.email)
            if json.user?.errors?.password
              form.find('.password').addClass('error')
              form.find('.password .help-inline').html(json.user.errors.password)
            if json.message
              form.find('.other').addClass('error')
              form.find('.other .help-inline').html(json.message)
            $.fancybox.update()
            return

          if json.need_confirm
            # Trying to register with unconfirmed aacount
            mixingpanel_tracker.track "Register", {"action":"register needs confirmation", "location":"login fancybox", "url": document.URL }
            form.find("button").removeAttr('disabled')
            @constructor.unblock()
            @clear
            @showFancyBoxMessage(json.message, false)

          else
            # Track succesful login / register
            if $(form).attr("id") == "login_form"
              mixingpanel_tracker.track "Login", {"action":"signin success", "location":"login fancybox", "url": document.URL }
            else if $(form).attr("id") == "register_form"
              mixingpanel_tracker.track "Register", {"action":"register success", "location":"login fancybox", "url": document.URL }
            window.processLogin()

      })

  clear: ()->
    $('#loginbox .email, #loginbox .password').removeClass('error')
    $('#loginbox .help-inline').html('')
    $('#loginbox input').val('')
    @clearFacebookError()
    @clearFancyBoxError()

  clearField: (e)->
    $(e.target).parent().parent().removeClass('error')
    @clearFacebookError()
    @clearFancyBoxError()

  isEmailValid: (emailAddress) ->
    pattern = new RegExp /// ^
                    [a-z0-9!#$%&'*+/=?^_`{|}~]+(?:[\.-][a-z0-9!#$%&'*+/=?^_`{|}~-]+)*
                    @
                    (?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9][a-z0-9-]*[a-z0-9]
                  $ ///i
    pattern.test emailAddress

