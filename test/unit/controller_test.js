(function() {
  var BeeteaController, TestController, express, should, _, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  should = require("should");

  express = require("express");

  BeeteaController = require("../../lib/beetea").Controller;

  _ = require("lodash");

  TestController = (function(_super) {
    __extends(TestController, _super);

    function TestController() {
      _ref = TestController.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    TestController.route = "testController";

    return TestController;

  })(BeeteaController);

  beforeEach(function() {
    return this.app = express();
  });

  describe("AppBot Controller", function() {
    it('should extend an object', function() {
      var controller;
      controller = new TestController(this.app);
      this.app.routes["get"][0].path.should.equal("/bee/testController/*");
      return this.app.routes["get"][1].path.should.equal("/bee/testController");
    });
    it('should contain a POST ROUTE', function() {
      var controller;
      controller = new TestController(this.app);
      return this.app.routes["post"][0].path.should.equal("/bee/testController/*");
    });
    it('should contain a PUT ROUTE', function() {
      var controller;
      controller = new TestController(this.app);
      return this.app.routes["put"][0].path.should.equal("/bee/testController");
    });
    return it('should contain a DEL ROUTE', function() {
      var controller;
      controller = new TestController(this.app);
      return this.app.routes["delete"][0].path.should.equal("/bee/testController/*");
    });
  });

}).call(this);
