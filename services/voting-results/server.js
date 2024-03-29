var express = require('express'),
    async = require('async'),
    pg = require("pg"),
    cookieParser = require('cookie-parser'),
    bodyParser = require('body-parser'),
    methodOverride = require('method-override'),
    app = express(),
    server = require('http').Server(app),
    io = require('socket.io')(server);

io.set('transports', ['polling']);

var port = process.env.PORT || 4000;
var client;

async function setupClient() {
  client = new pg.Client()
  await client.connect()

  console.log("Connected to db");

  getVotes(client)
}

setupClient()


io.sockets.on('connection', function (socket) {
  console.log('connected with socket')
  socket.emit('message', { text : 'Welcome!' });

  socket.on('subscribe', function (data) {
    console.log('joing data.channel')
    socket.join(data.channel);

  });
});

var query = require('./views/config.json');



function getVotes(client) {
  client.query('SELECT vote, COUNT(id) AS count FROM votes GROUP BY vote', [], function(err, result) {
    if (err) {
      console.error("Error performing query: " + err);
    } else {
      var data = result.rows.reduce(function(obj, row) {
        obj[row.vote] = row.count;
        return obj;
      }, {});
      io.sockets.emit("scores", JSON.stringify(data));
    }

    setTimeout(function() {getVotes(client) }, 1000);
  });
}

app.use(cookieParser());
app.use(bodyParser());
app.use(methodOverride('X-HTTP-Method-Override'));
app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  res.header("Access-Control-Allow-Methods", "PUT, GET, POST, DELETE, OPTIONS");
  next();
});

app.use(express.static(__dirname + '/views'));

app.get('/', function (req, res) {
  res.sendFile(path.resolve(__dirname + '/views/index.html'));
});

app.get('/postconfig', function(req,res) {
  res.sendStatus(200);
}
);

app.get('/getconfig', function(req,res){
  res.type('application/json');
  res.status(200);
  res.send(JSON.stringify(query));

});

server.listen(port, function () {
  var port = server.address().port;
  console.log('App running on port ' + port);
});
