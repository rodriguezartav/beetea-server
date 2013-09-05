should = require("should")
request = require('supertest')
superagent = require('superagent');
express = require("express")
Session = require("../../lib/session")
assert = require('assert');
Browser = require('zombie');
process.env.NODE_ENV = 'test';

# define server base URL

before ->
  @app = express()
  @app.listen 9999
  Session( @app , { name: "test-session-999" , secret: "secret", secure: false, httpOnly: false } )   #secure:false to allow testing on http
  @app.get "/" , (req,res) ->
    req["test-session-999"].check = "ok"
    res.send 200

  @browser = new Browser({ site: 'http://localhost:9999' });
  @browser.on "error" ,  (err) ->
    console.log err

describe "Use Session", ->

  it 'should use session cookies', (done) -> 
    @browser.visit '/' , =>
      @browser.visit '/' , =>
        @browser.cookies.toString().indexOf("test-session-999").should.be.above(-1)
        done()
      