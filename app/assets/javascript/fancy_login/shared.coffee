
# Shared utilities and document ready that initializes different fancy login objects


# When dealing with page reloads after ajax login or logout the easiest way to notify a user about
# the state change is by passing client side parameters in the URL such as #?=logged-in...
# So when login happens we reload page, but add first #?n=logged-in that fires the notificatin and then deletes the hash
# Logout is not an async funciton so if we set the link to mi.kelisto.es/salir#?n=logged-out we will see the notification ;)
class @Notification

  getText: ()->
    # If has begins with #? that means we have a variable passed
    if window.location.hash.slice(0,2) == "#?"
      if window.location.hash.indexOf("n=logged-in") != -1
        text = "Acabas de entrar en Kelisto"
      else if window.location.hash.indexOf("n=logged-out") != -1
        text = "Acabas de salir de Kelisto"
      else if window.location.hash.indexOf("n=reset-pass") != -1
        text = "Email enviado, consulta la bandeja de entrada de tu correo"
      return text
    return false

  show: (text)->
    $notification = $('<div/>', {
      class: 'js-top-notification'
      html: "<i class='icon-info'></i>#{text}"
    })

    $("body").prepend($notification);

    setTimeout(
      ()->
        $notification.fadeIn(1000)
        setTimeout(
          ()->
            $notification.fadeOut(800)
        , 3000)

      , 500)

    # Remove the param from hash to avoid repetition of notification on refresh
    window.location.hash = '_' # We use _ instead of an empty string to avoid a scroll issue on Chrome




# Used to safely reload the page. It sends a GET request to the current URL
# if notification is given it will be added after the hash in th URL so that when the page
# reloads we can show a notification
window.ReloadPage = (notification)->
  # window.location = window.location.href
  if notification?
    window.location.hash = "?n="+notification
  window.location.reload()

# Process login is called after ajax login has been successful. It allows different
# behaviour depending on the target (i.e. clicked link or input that triggered
# the login):
#
# 1 By default, it reloads the page's current URL, not sending any form
# previously sent when loading current URL. via a GET request.
#
# 2 If the target (link/button) has a data-login-callback attribute such as "window.Campaign11.loginCallback"
# this gets evaluated executed as a callback.
# So, for example, to have a custom callback after successful login you have to provide that callback in the data attribute.
# NOTE: the loginbox (fancybox) will remain shown, but you can close it directly calling to $.fancybox.close().
# NOTE: you can reload safely the page calling to window.ReloadPage() which will take care of not sending any POST data and any other reload
# details that might happen.
#
# 3 In case there's no callback and the target is an input[type="submit"] inside a form, the form will be sent by triggering the form's submit event (form.submit())
#
# 4 If the target has the data-target-url attribute set, then the page will load via a GET request the specified URL.
window.processLogin = () ->
  if LoginBox.target?.data('login-callback')
    $.fancybox.close()
    target    = LoginBox.target # element clicked
    callback  = LoginBox.target.data('login-callback')
    #eval is considered to be EVIL, but in this case is totally appropriate since this code always comes from us to the user http://stackoverflow.com/questions/86513/why-is-using-the-javascript-eval-function-a-bad-idea
    # first arg is the context (it's passed implicitly) and the second one is the element that was clicked
    eval(callback).call(this,target);
  else if LoginBox.target?.prop("nodeName").toLowerCase() == 'input' and LoginBox.target.attr("type").toLowerCase() == 'submit'
    LoginBox.target.closest('form').submit()
  else if LoginBox.target?.data('target-url')
    location.href = LoginBox.target.data('target-url')
  else
    window.ReloadPage("logged-in")


# Custom fancybox open/close animation
do($=jQuery, F=jQuery.fancybox) ->
  F.transitions.dropIn = ()->
    endPos = F._getPosition(true);
    endPos.top = (parseInt(endPos.top, 10) - 300) + 'px';
    F.wrap.css(endPos).show().animate({
      top: '+=300px'
    }, {
      duration: F.current.openSpeed,
      complete: F._afterZoomIn
    })
  F.transitions.dropOut = ()->
    F.wrap.removeClass('fancybox-opened').animate({
      top: '-=300px'
    }, {
      duration: F.current.closeSpeed,
      complete: F._afterZoomOut
    })


$(document).ready ()->
  window.loginBox = new LoginBox
  window.forgotPassBox = new ForgotPassBox
  window.rememberTokenConfirmationBox = new RememberTokenConfirmationBox

  notification = new Notification
  if text = notification.getText()
    notification.show(text)

















