
var initLoad = dojo.subscribe("/xf/ready", function() {{
  dojo.unsubscribe(initLoad);
  fluxProcessor.dispatchEvent('tgotoact');
  fluxProcessor.dispatchEvent('first-image');
}});