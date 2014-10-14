ioc        = require "simple-ioc"
requireAll = require "require-all"
_          = require "underscore"

module.exports = ()->
  ioc.reset()
  ioc.setLogLevel(5)
  ioc.registerDirectory = (rootDir, dir)->
    libs = requireAll({
      dirname     :  rootDir + dir
      filter      :  /(.+)\.(js|json|coffee)$/
    })
    ioc.registerRequiresObject(libs)
    ioc

  ioc.registerDirectories = (rootDir, dirs)->
    _.each dirs, (dir)->
      ioc.registerDirectory(rootDir, dir)
    ioc
  ioc.registerRequiresObject = (ob)->
    for k,v of ob
      if _.isFunction(v)
        ioc.registerRequired(k,v)
      else
        ioc.registerRequiresObject(v)
    ioc

  ioc.registerSettingsFolder = (folder)->
    defaultConfig = require "#{folder}/default"
    envConfig = require "#{folder}/#{process.env.NODE_ENV}"
    mergedConfig = _.extend({}, defaultConfig, envConfig)
    ioc.setSettings("config", mergedConfig)
    ioc.registerDependency("$#{k}", v) for k,v of mergedConfig
    return mergedConfig

  ioc.registerDependencies = (dependencies)->
    for k,v of dependencies
      ioc.registerDependency k,v


  ioc.registerLibraries = (libraries)->
    for k,v of libraries
      ioc.registerLibraryAs k,v


  ioc.registerLibraryAs = (name, libraryName)->
    ioc.registerDependency name, require(libraryName)

  return ioc