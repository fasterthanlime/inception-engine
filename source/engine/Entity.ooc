import structs/[ArrayList, HashMap, Stack]
import Property, Update, Message, Engine

Entity: class {
    
    engine: Engine
    
    name: String
    id: Int
    
    props := HashMap<String, Property> new()
    updates : Update[]
    receivers : Receiver[]
    queue : Message[]
    
    idSeed := static 0
    
    init: func ~withName(=name) {
        This idSeed += 1
        id = This idSeed
    }
    
    addUpdate: func (update: Update) { updates add(update) }
    
    update: func {
        
        if(!updates isEmpty()) {
            //printf("[%d] %s got %d updates to run\n", id, name, updates size())
            iter := updates iterator()
            while(iter hasNext()) {
                up := iter next()
                //printf("[%d] %s running update %s\n", id, name, up class name)
                if(!up run(this)) {
                    iter remove()
                }
            }
        }
        
        
        while(!queue isEmpty()) {
            msg := queue get(0)
            queue removeAt(0)
            for(r in receivers) {
                if(r messageType inheritsFrom(msg class)) {
                    r call(msg)
                }
            }
        }
    }
    
    listen: func <T> (T: Class, call: Func (T)) {
        receivers add(Receiver new(T, call))
    }
    
    send: func (target: Entity, msg: Message) {
        //printf("Sending message of type %s from %s to %s\n", msg class name, name, target name)
        msg sender = this
        msg target = target
        target queue add(msg)
    }
    
    sendAll: func (msg: Message) {
        for(entity in engine entities) {
            has := true
            for(receiver in entity receivers) {
                if(receiver messageType inheritsFrom(msg class)) {
                    has = true
                    break
                }
            }
            if(has) {
                send(entity, msg clone())
            }
        }
    }
    
    // Generic properties convenience functions
    
    set: func <T> (name: String, value: T) {
        prop := props get(name)
        if(prop) {
            prop set(value)
        } else {
            prop := GenericProperty new(name, value)
            props put(name, prop)
        }
    }
    
    get: func <T> (name: String, T: Class) -> T {
        prop := props get(name)
        if(!prop) return null
        if(!prop instanceOf(GenericProperty)) {
            Exception new(This, "Attempting to get (%s, %s), but the property isn't generic but a %s" format(name, T name, prop class name)) throw()
        }
        gp := prop as GenericProperty<T>
        if(!gp T inheritsFrom(T)) {
            Exception new(This, "Attempting to get (%s, %s), but the property has incompatible type %s" format(name, T name, gp T name)) throw()
        }
        return gp get()
    }
    
}

Receiver: class {

    messageType: MessageClass
    call: Func (Message)
    
    init: func (=messageType, =call) {}
    
}
