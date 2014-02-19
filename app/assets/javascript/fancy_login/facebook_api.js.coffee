window.fbAsyncInit = ->
  FB.init
    appId: app.facebook_app_id
    status: true
    cookie: true
    xfbml: true


((d, s, id) ->
  js = undefined
  fjs = d.getElementsByTagName(s)[0]
  return  if d.getElementById(id)
  js = d.createElement(s)
  js.id = id
  js.async = true
  js.src = "//connect.facebook.net/es_ES/all.js"
  fjs.parentNode.insertBefore js, fjs
) document, "script", "facebook-jssdk"