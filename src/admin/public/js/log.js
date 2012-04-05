jQuery(function(){
  socket = io.connect();
  socket.on('log-data', function(data){
    $('#log').append(document.createTextNode(data));
  });
  socket.emit('tail-log')
})
