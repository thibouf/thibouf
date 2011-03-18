-- Yet Another Class Implementation (version 2.0)
--
-- original version by Julien Patte [julien.patte AT gmail DOT com] - 25 Feb 2007
-- version 2 Modifications by Enrique Garcia - oct 2009
--
-- Inspired from code written by Kevin Baca, Sam Lie, Christian Lindig and others
-- Thanks to Damian Stewart and Frederic Thomas for their interest and comments
-----------------------------------------------------------------------------------

do  -- keep local things inside

  -- associations between an object an its meta-informations
  -- e.g its class, its "lower" object (if any), ...
  local metaObj = {}
  setmetatable(metaObj, {__mode = "k"})
  
  -----------------------------------------------------------------------------------
  -- internal function 'callup'
  -- Function used to transfer a method call from a class to its superclass
  local callup_inst
  local callup_target

  local function callup(inst, ...)
    return callup_target(callup_inst, ...)  -- call the superclass' method
  end

    -- return a copy of table t (shallow copy: only level 1 is copied, non-recursive)
  local function duplicate(origin, destination, keys)
    if destination == nil then destination = {} end
    -- no keys provided - duplicate all keys
    if keys==nil then
      for key,value in pairs(origin) do destination[key] = value end
    else
      -- duplicate only the keys provided
      for _,key in pairs(keys) do destination[key] = origin[key] end
    end
    return destination
  end
  
  Object = {
    name = function(self) return 'Object' end,
    super = function(self) return nil end,
    inherits = function(class, other) return false end,
    
    virtual = function(self, fname)
      if type(fname)=='table' then
        for value,_ in pairs(fname) do self:virtual(value) end
      else
        local func = self.static[fname]
        if func == nil then
          func = function() error("Attempt to call an undefined abstract method '"..fname.."'") end
        end
        metaObj[self].virtuals[fname] = func
      end
    end,

    new = function(self, ...)
      local inst = self:makeInstance(metaObj[self].virtuals)
      inst:init(...)
      return inst
    end,
    
    -- try to cast an instance into an instance of one of its super- or subClasses
    -- returns nil if not possible
    tryCast = function(self, inst)
      local meta = metaObj[inst]
      if meta.class==self then return inst end -- is it already the right class?

      while meta~=nil do  -- search lower in the hierarchy
        if meta.class==self then return meta.obj end
        meta = meta.lower
      end

      meta = metaObj[inst].super  -- not found, search through the superclasses
      while meta~=nil do
        if meta.class==self then return meta.obj end
        meta = meta.super
      end
      return nil -- could not execute casting
    end,
    
    -- try to cast an instance into an instance of one of its superclasses or subClasses
    -- throws an exception if not possible
    cast = function(self, inst)
      local casted = self:tryCast(inst)
      if casted == nil then
        error("Failed to cast " .. tostring(inst) .. " to a " .. class:name())
      end
      return casted
    end,
    
    -- returns true if a class made an object, false otherwhise
    made = function(self, obj)
      if metaObj[obj]==nil then return false end -- is this really an object?
      return (self:tryCast(obj) ~= nil) -- check if that class could cast the object
    end,
    
    subClass = function(self, name)
      if type(name)~="string" then name = "Unnamed" end
      
      local baseClass = self
      
      -- the new class
      local theClass = {
        name = function(self) return name end,
        super = function(self) return baseClass end,
        inherits = function(self, other) return (self==other or self:inherits(other)) end,
      }
      
      duplicate(baseClass, theClass, {
        'cast', 'extends', 'made', 'makeInstance', 'newMethod', 'new', 'subClass', 'tryCast', 
        'setDefaultVirtual', 'getDefaultVirtual', 'virtual'
      })

      -- contains instance-related stuff: metamethods, the init method, class method,
      -- and facilites for accessing instance attributes/methods
      theClass.static = {
        --init = function(inst,...) inst.super:init() end,
        class = function() return theClass end,
        __newindex = function(inst,key,value)
          -- First check if this field isn't already
          -- defined higher in the hierarchy
          if inst.super[key] ~= nil then   
            inst.super[key] = value;    -- Update the old value
          else
            rawset(inst,key,value);     -- Create the field
          end
        end
      }
      theClass.static.__index = function(inst, key) -- Look for field 'key' in instance 'inst'
        local res = theClass.static[key]   -- attribute or method already exists?
        if res~=nil then return res end    -- if yes, return it

        res = inst.super[key]          -- Not found; search higher on the hierarchy

        if type(res)=='function' and res ~= callup then  -- If it is a method of the superclass,
          callup_inst = inst.super     -- we will need to do a special forwarding
          callup_target = res          -- to call 'res' with the correct 'class'
          return callup                -- The 'callup' function will do that
        end

        return res
      end
      duplicate(baseClass.static, theClass.static, {
        '__add', '__call', '__concat', '__div', '__eq', '__le', '__len', '__lt',
        '__mod', '__mul', '__pow', '__sub', '__tostring', '__unm'
      })

      setmetatable(theClass, {
        __call = theClass.new,
        __tostring = function() return ("class "..name) end,
        __newindex = theClass.newMethod,
      })
      
      metaObj[theClass] = { virtuals = duplicate(metaObj[baseClass].virtuals) }

      return theClass
    end,
    
    -- extension function - similar to ruby's extend for modules
    -- adds the methods of t to the class
    -- will include the methods as static or virtual, depending on defaultVirtual
    extends = function(self, t)
      duplicate(t, self)
      if t.extended~=nil then t:extended(self) end
    end,
    
    -- internal method used by "new" - do not use
    makeInstance = function(self, virtuals)
      --virtuals defaults to metaObj[self].virtuals if nil
      virtuals = virtuals~=nil and virtuals or metaObj[self].virtuals 
      local inst = duplicate(virtuals)
      metaObj[inst] = { obj = inst, class = self }

      local superClass = self:super()
      if superClass~=nil then
        inst.super = superClass:makeInstance(virtuals)
        metaObj[inst].super = metaObj[inst.super]  -- meta-info about inst
        metaObj[inst.super].lower = metaObj[inst]
      else
        inst.super = {}
      end

      setmetatable(inst, self.static)

      return inst
    end,
    
    setDefaultVirtual= function(self, value)
      self.defaultVirtual = value
    end,
    
    getDefaultVirtual= function(self)
      return self.defaultVirtual
    end,

    -- internal method used by metatables, when creating new methods
    newMethod = function(self, name, meth) --creates new methods
      self.static[name] = meth;
      if self.defaultVirtual==true or metaObj[self].virtuals[name]~=nil then
        metaObj[self].virtuals[name] = meth
      end
    end
  } --end of Object {
  
  Object:setDefaultVirtual(false) -- by default, methods are non-virtual
  
  Object.static = {
    init = function(inst,...) end,
    __tostring = function(inst) return ("a "..inst:class():name()) end,
    class = function() return Object end
  }
  
  Object.static.__index = Object.static
  
  setmetatable(Object, {
    __call = Object.new,
    __tostring = function() return ("class Object") end,
    __newindex = Object.newMethod
  })
  
  metaObj[Object] = { virtuals={} }

  ----------------------------------------------------------------------
  -- function 'class'

  function class(name, baseClass)
    baseClass = baseClass or Object
    return baseClass:subClass(name)
  end

end -- 2 global things remain: 'Object' and 'class'

-- end of code


