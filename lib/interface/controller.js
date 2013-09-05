(function() {
  var BeeteaOperation, Controller, DatabaseConnection, DeleteCommand, InsertCommand, Model, QueryCommand, UpdateCommand,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  BeeteaOperation = require("./operation");

  QueryCommand = require("../basicCommands/queryCommand");

  InsertCommand = require("../basicCommands/insertCommand");

  UpdateCommand = require("../basicCommands/updateCommand");

  DeleteCommand = require("../basicCommands/deleteCommand");

  DatabaseConnection = require("./databaseConnection");

  Model = require("./model");

  Controller = (function() {
    function Controller(app) {
      this.app = app;
      this.destroy = __bind(this.destroy, this);
      this.update = __bind(this.update, this);
      this.create = __bind(this.create, this);
      this.findAll = __bind(this.findAll, this);
      this.find = __bind(this.find, this);
      this.defineRestRoutes = __bind(this.defineRestRoutes, this);
      this.model = new Model(this.constructor.route, this.constructor.route);
      if (typeof this.defineCustomRoutes === "function") {
        this.defineCustomRoutes();
      }
      this.defineRestRoutes();
      this;
    }

    Controller.prototype.fromJson = function(data) {
      return JSON.parse(data);
    };

    Controller.prototype.defineRestRoutes = function() {
      var parent, response, route;
      parent = this.constructor;
      route = "/bee/" + parent.route;
      response = this.app.get(route + "/*", this.find);
      response = this.app.get(route, this.findAll);
      response = this.app.post(route + "/*", this.update);
      response = this.app.put(route, this.create);
      return response = this.app.del(route + "/*", this.destroy);
    };

    Controller.prototype.find = function(req, res) {
      var operation;
      operation = BeeteaOperation.staticOperation(DatabaseConnection, ["select * from " + this.model.tableName + " where id = " + req.params[0]]);
      return this.handleQueryResponse(operation, req, res, true);
    };

    Controller.prototype.findAll = function(req, res) {
      var operation;
      operation = BeeteaOperation.staticOperation(DatabaseConnection, ["select * from " + this.model.tableName]);
      return this.handleQueryResponse(operation, req, res);
    };

    Controller.prototype.create = function(req, res) {
      var operation;
      this.model.body = req.body;
      operation = BeeteaOperation.staticOperation(DatabaseConnection, [new InsertCommand(this.model)]);
      return this.handleRestResponse(operation, req, res, true);
    };

    Controller.prototype.update = function(req, res) {
      var operation;
      this.model.body = req.body;
      operation = BeeteaOperation.staticOperation(DatabaseConnection, [new UpdateCommand(this.model)]);
      return this.handleRestResponse(operation, req, res, true);
    };

    Controller.prototype.destroy = function(req, res) {
      var operation;
      this.model.body = {
        id: req.params[0]
      };
      operation = BeeteaOperation.staticOperation(DatabaseConnection, [new DeleteCommand(this.model)]);
      return this.handleRestResponse(operation, req, res, true);
    };

    Controller.prototype.handleQueryResponse = function(promise, req, res, single) {
      if (single == null) {
        single = false;
      }
      promise.then(function(response) {
        var results;
        results = response.results[0];
        if (single && results.length === 0) {
          res.status(404);
          return res.send("Record not found");
        } else {
          res.status(200);
          return res.send(single ? results[0] : results);
        }
      });
      return promise.fail(function(error) {
        res.status(500);
        return res.send(error);
      });
    };

    Controller.prototype.handleRestResponse = function(promise, req, res, single) {
      if (single == null) {
        single = false;
      }
      promise.then(function(response) {
        var results;
        results = response.results[0];
        if (single && results.affectedRows === 0 && results.changedRows === 0 && results.insertId === 0) {
          res.status(404);
          return res.send("Record Not Found");
        } else {
          res.status(200);
          if (!req.body.id && results.insertId) {
            req.body.id = results.insertId;
          }
          return res.send(req.body);
        }
      });
      return promise.fail(function(error) {
        res.status(500);
        return res.send(error);
      });
    };

    return Controller;

  })();

  module.exports = Controller;

}).call(this);
