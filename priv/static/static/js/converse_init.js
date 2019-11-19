var request = new XMLHttpRequest();
request.open('GET', '/xmpp/conndata', true);
request.onload = function () {
  if (request.status >= 200 && request.status < 400) {
    console.log("Got JID data: ", request.responseText)
    var data = JSON.parse(request.responseText);
    if (data) {
      converse.initialize({
        debug: true,
        authentication: 'prebind',
        prebind_url: data.prebind_url,
        keepalive: true,
        jid: data.jid,
        auto_away: 300,
        auto_reconnect: true,
        bosh_service_url: data.http_bind_url,
        message_archiving: 'always',
        view_mode: 'overlayed'
      });
    } else {
      console.log("Couldn't get data to connect to XMPP")
    }
  } else {
    console.error("Unexpected response, can't get data to connect to XMPP", request)
  }
};
request.onerror = function () {
  console.error("Connection error, can't get data to connect to XMPP")
};
request.send();