Session = require "./session"
DatabaseConnection = require "./interface/databaseConnection"
Operation = require "./interface/operation"
Controller = require "./interface/controller"
Command = require "./interface/command"
Model = require "./interface/model"

InsertCommand = require "./basicCommands/insertCommand"
UpdateCommand = require "./basicCommands/updateCommand"
QueryCommand = require "./basicCommands/queryCommand"
DeleteCommand = require "./basicCommands/deleteCommand"
CustomCommand = require "./basicCommands/customCommand"

class Beetea

  constructor: (app) ->


Beetea.Model = Model
Beetea.Command = Command
Beetea.Session = Session
Beetea.DatabaseConnection = DatabaseConnection
Beetea.Operation = Operation
Beetea.Controller = Controller

Beetea.InsertCommand = InsertCommand
Beetea.UpdateCommand = UpdateCommand
Beetea.QueryCommand = QueryCommand
Beetea.DeleteCommand = DeleteCommand
Beetea.CustomCommand = CustomCommand


Beetea.controller = []
Beetea.policies = []

module.exports = Beetea

