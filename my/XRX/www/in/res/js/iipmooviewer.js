
var initLoad = dojo.subscribe("/xf/ready", function() {{
  dojo.unsubscribe(initLoad);
  fluxProcessor.dispatchEvent('tstart');
}});