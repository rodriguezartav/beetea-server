(function() {
  var Beetea, Command, Controller, CustomCommand, DatabaseConnection, DeleteCommand, InsertCommand, Model, Operation, QueryCommand, Session, UpdateCommand;

  Session = require("./session");

  DatabaseConnection = require("./interface/databaseConnection");

  Operation = require("./interface/operation");

  Controller = require("./interface/controller");

  Command = require("./interface/command");

  Model = require("./interface/model");

  InsertCommand = require("./basicCommands/insertCommand");

  UpdateCommand = require("./basicCommands/updateCommand");

  QueryCommand = require("./basicCommands/queryCommand");

  DeleteCommand = require("./basicCommands/deleteCommand");

  CustomCommand = require("./basicCommands/customCommand");

  Beetea = (function() {
    function Beetea(app) {}

    return Beetea;

  })();

  Beetea.Model = Model;

  Beetea.Command = Command;

  Beetea.Session = Session;

  Beetea.DatabaseConnection = DatabaseConnection;

  Beetea.Operation = Operation;

  Beetea.Controller = Controller;

  Beetea.InsertCommand = InsertCommand;

  Beetea.UpdateCommand = UpdateCommand;

  Beetea.QueryCommand = QueryCommand;

  Beetea.DeleteCommand = DeleteCommand;

  Beetea.CustomCommand = CustomCommand;

  Beetea.controller = [];

  Beetea.policies = [];

  module.exports = Beetea;

}).call(this);
